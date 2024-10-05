import { createWriteStream, existsSync } from 'fs'
import { mkdir } from 'fs/promises'
import https from 'https'
import path, { dirname } from 'path'
import { fileURLToPath } from 'url'

export const downloadFile = async (url: string): Promise<string> => {
  return new Promise(async (resolve, reject) => {
    const __filename = fileURLToPath(import.meta.url)
    const __dirname = dirname(__filename)
    const downloadDir = path.resolve(__dirname, '../migrations/.tmp')
    if (!existsSync(downloadDir)) {
      await mkdir(downloadDir)
    }

    const fileName = url.split('/').pop()!
    const destination = path.resolve(downloadDir, fileName)
    const file = createWriteStream(destination)
    const request = https.get(url, (response) => {
      response.pipe(file)
      file.on('finish', () => {
        file.close()
        return resolve(destination)
      })
    })
    request.on('error', () => {
      return reject()
    })
  })
}
