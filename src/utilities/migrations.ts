import { MigrateDownArgs } from '@payloadcms/db-mongodb'
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

/**
 * Performs a custom transaction by running an array of inidividual steps and by monitoring which one fails.
 * Upon step failure, it will call the `down` function passing it the failure step for partial reversal.
 * @param args the original payload migration args
 * @param steps individual steps to run
 * @param down a function reversing the above steps
 */
export async function transaction<ContextType>(
  args: MigrateDownArgs,
  steps: ((ctx: ContextType) => Promise<void>)[],
  down: (
    args: MigrateDownArgs,
    ctx: ContextType | undefined,
    successfulSteps: number | undefined,
  ) => Promise<void>,
) {
  let successfulSteps = 0
  let ctx: ContextType = {} as ContextType
  try {
    console.log('[transaction] begin')
    for (let i = 0; i < steps.length; ++i) {
      console.log(`[transaction] [step ${i + 1}]...`)
      await steps[i](ctx as any)
      console.log(`[transaction] [step ${i + 1}] success`)
      ++successfulSteps
    }
    console.log('[transaction] commit')
  } catch (e) {
    console.warn('[transaction] error', e)
    await down(args, ctx, successfulSteps)
  }
}

/**
 * Performs a full or partial reversal of the transaction by running a subset of passed steps
 * @param steps functions performing individual rollback steps
 * @param ctx the original payload context
 * @param successfulSteps index of the last successful step. `undefined` if all steps succeeded (for full rollback)
 */
export async function reverseTransaction<ContextType>(
  steps: ((ctx: ContextType) => Promise<void>)[],
  ctx: ContextType | undefined,
  successfulSteps: number | undefined,
) {
  // By default (if we run from `payload migrate:down`) failStep will be undefined and we run full rollback
  let startFrom = steps.length - 1
  let success = true
  if (successfulSteps !== undefined) {
    // Ran inside of a transaction, partial rollback
    startFrom = successfulSteps - 1
    console.log('[transaction] rollback')
  } else {
    console.log('[transaction] performing full rollback (payload migrate:down)')
  }
  try {
    for (let i = startFrom; i > -1; --i) {
      console.log(`[transaction] [step ${i + 1}] rollback...`)
      await steps[i](ctx!)
      console.log(`[transaction] [step ${i + 1}] rollback success`)
    }
    console.log('[transaction] rollback success')
    success = false
  } catch (e) {
    console.error('[transaction] rollback error', e)
  }
  if (!success && successfulSteps !== undefined) {
    console.log('[transaction] throwing error to inform Payload about the rollback')
    throw new Error('[transaction] rollback')
  }
}
