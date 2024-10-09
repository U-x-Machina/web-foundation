import { createRequire } from "module"
import { dirname, resolve } from 'path'
const require = createRequire(import.meta.url)
const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

import 'dotenv/config'
import { existsSync } from "fs"
import { writeFile } from "fs/promises"
import { fileURLToPath } from "url"
const config = require('../db-observer.config.json')
const { MongoClient } = require("mongodb")

const TMP_DIR = resolve(__dirname, '../src/migrations/.tmp')
const CHANGES_FILE_NAME = 'observed-changes.json'
const SKIP_FIELDS = [
  '_id',
  '__v',
  'createdAt',
  'updatedAt'
]
const uri = process.env.DATABASE_URI

const client = new MongoClient(uri)

const log = (...args) => {
  console.log.apply(console, ['[db:observe]', ...args])
}

let changes = {
  collections: {
    created: [],
    updated: [],
    deleted: []
  },
  globals: {
    updated: {},
  }
}

try {
  changes = require(resolve(TMP_DIR, CHANGES_FILE_NAME))
  log('previous changes loaded')
} catch (e) {
  log('no previous changes found, starting new change log')
}

const writeChanges = async () => {
  await writeFile(resolve(TMP_DIR, CHANGES_FILE_NAME), JSON.stringify(changes, null, 2))
}

const onCollectionChange = (change) => {
  if (change.operationType === 'insert') {
    log(`[insert] [collection:${change.ns.coll}]`, change.fullDocument)
    changes.collections.created.push({
      collection: change.ns.coll,
      id: change.fullDocument._id.toString(),
      data: change.fullDocument
    })
  } else if (change.operationType === 'delete') {
    log(`[delete] [collection:${change.ns.coll}]`, change.documentKey._id.toString())
    const createdIndex = changes.collections.created.findIndex(obj => obj.id === change.documentKey._id.toString())
    const updatedIndex = changes.collections.updated.findIndex(obj => obj.id === change.documentKey._id.toString())
    if (createdIndex !== -1) {
      changes.collections.created = changes.collections.created.filter(obj => obj.id !== change.documentKey._id.toString())
    }
    if (updatedIndex !== -1) {
      changes.collections.updated = changes.collections.updated.filter(obj => obj.id !== change.documentKey._id.toString())
    }
    if (createdIndex === -1) {
      // Means the object existed in the database prior to observation. We add it for deletion.
      changes.collections.deleted.push({
        collection: change.ns.coll,
        id: change.documentKey._id.toString()
      })
    }
  } else if (change.operationType === 'update') {
    log(`[update] [collection:${change.ns.coll}] [id: ${change.fullDocument._id.toString()}]`, change.updateDescription.updatedFields)
    const createdIndex = changes.collections.created.findIndex(obj => obj.id === change.fullDocument._id.toString())
    const updatedIndex = changes.collections.updated.findIndex(obj => obj.id === change.fullDocument._id.toString())
    if (createdIndex !== -1) {
      // Document created during this observation, so we can just create its final version.
      changes.collections.created[createdIndex].data = {
        ...changes.collections.created[createdIndex].data,
        ...change.updateDescription.updatedFields
      }
    } else if (updatedIndex !== -1) {
      // Document existed before observation but has already been updated during observation. We merge the updates.
      changes.collections.updated[updatedIndex].data = {
        ...changes.collections.updated[updatedIndex].data,
        ...change.updateDescription.updatedFields
      }
    } else {
      // Document existed prior to observation and it is its first update.
      changes.collections.updated.push({
        collection: change.ns.coll,
        id: change.fullDocument._id.toString(),
        data: change.updateDescription.updatedFields
      })
    }
  }

  console.log(JSON.stringify(changes, null, 2))
}

const onGlobalChange = async (change) => {
  changes.globals.updated[change.fullDocument.globalType] = changes.globals.updated[change.fullDocument.globalType] || {}
  Object.keys(change.updateDescription.updatedFields).forEach(field => {
    if (SKIP_FIELDS.indexOf(field) === -1) {
      const value = change.updateDescription.updatedFields[field]
      log(`[update] [global:${change.fullDocument.globalType}] [field:${field}] ${value}`)
      changes.globals.updated[change.fullDocument.globalType][field] = value
    }
  });
  await writeChanges()
}

async function run() {
  if (!existsSync(TMP_DIR)) {
    await mkdir(TMP_DIR)
  }

  const db = client.db()

  log('start')

  const globals = db.collection('globals')
  const globalsPipeline = [
    { $match: { $or: config.globals.map(globalName => ({ 'fullDocument.globalType': globalName })) } },
  ];
  const globalsChangeStream = globals.watch(globalsPipeline, { fullDocument: 'updateLookup' });
  globalsChangeStream.on('change', onGlobalChange);

  config.collections.forEach(collectionName => {
    const collection = db.collection(collectionName)
    const collectionChangeStream = collection.watch([], { fullDocument: 'updateLookup' });
    collectionChangeStream.on('change', onCollectionChange);
  });
}
run().catch(console.dir)