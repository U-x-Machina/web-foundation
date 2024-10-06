import { createRequire } from "module"
import { dirname, resolve } from 'path'
const require = createRequire(import.meta.url)

import 'dotenv/config'
import { existsSync } from "fs"
import { writeFile } from "fs/promises"
import { fileURLToPath } from "url"
const config = require('../db-observer.config.json')
const { MongoClient } = require("mongodb")

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
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

}

const onGlobalChange = async (change) => {
  changes.globals.updated[change.fullDocument.globalType] = changes.globals.updated[change.fullDocument.globalType] || {}
  Object.keys(change.updateDescription.updatedFields).forEach(field => {
    if (SKIP_FIELDS.indexOf(field) === -1) {
      const value = change.updateDescription.updatedFields[field]
      log(`[change] [global:${change.fullDocument.globalType}] [field:${field}] ${value}`)
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

  const globals = await db.collection('globals')
  const globalsPipeline = [
    { $match: { $or: config.globals.map(globalName => ({ 'fullDocument.globalType': globalName })) } },
  ];
  const globalsChangeStream = globals.watch(globalsPipeline, { fullDocument: 'updateLookup' });
  globalsChangeStream.on('change', onGlobalChange);
}
run().catch(console.dir)