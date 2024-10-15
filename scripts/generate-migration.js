import { dirname, resolve } from 'path'
import { fileURLToPath } from "url"
const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

import ejs from 'ejs'
import { existsSync, readFileSync } from "fs"
import { readFile, rm, writeFile } from "fs/promises"

const TMP_DIR = resolve(__dirname, '../src/migrations/.tmp')
const CHANGES_FILE_NAME = 'observed-changes.json'
const CHANGEFILE = resolve(TMP_DIR, CHANGES_FILE_NAME)
const fileNameSuffix = process.argv.length > 2 ? `_${process.argv[2]}` : '_migration'
const TEMPLATE_PATH = resolve(__dirname, './migration.tpl.ejs')

const generateMigrationFileName = (suffix) => {
  const dateString = new Date().toISOString().split('.')[0]
  return `${dateString.replace(/-/g, '').replace(/:/g, '').replace('T', '_')}${suffix}.ts`
}

const main = async () => {
  if (!existsSync(CHANGEFILE)) {
    console.warn(`No db changelog found at ${CHANGEFILE}. Quitting.`)
    return
  }

  const changes = JSON.parse((await readFile(CHANGEFILE)).toString())
  const template = readFileSync(TEMPLATE_PATH).toString()
  const migrationContents = await ejs.render(template, changes)
  const outputFile = resolve(__dirname, '../src/migrations/', generateMigrationFileName(fileNameSuffix))
  await writeFile(outputFile, migrationContents)
  console.log(`Migration generated at ${outputFile}`)

  await rm(CHANGEFILE)
  console.log(`Change log removed ${CHANGEFILE}`)
}

main()