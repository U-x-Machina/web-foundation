import { AbTest } from '@/payload-types'
import { reverseTransaction, transaction } from '@/utilities/migrations'
import { MigrateDownArgs, MigrateUpArgs } from '@payloadcms/db-mongodb'

interface MigrationContext {
  backup: any
  abTestLanding1: AbTest
}

/**
 * TODO: fill in a description of this migration.
 */
export async function up({ payload, req }: MigrateUpArgs): Promise<void> {
  await transaction<MigrationContext>(
    { payload, req },
    [
      // Delete collections

      // Create collections
      // Create ab-tests (id: 67127467fb335a348cdd7ad7)
      async (ctx: MigrationContext) => {
        ctx.backup = ctx.backup || { collections: {}, globals: {} }
        const entity = await payload.create({
          req,
          collection: 'ab-tests',
          data: {
            testId: 'landing1',
            description: 'LandingPage header variants',
            split: 0.5,
            active: true,
          },
        })
        ctx.abTestLanding1 = entity
        ctx.backup.collections['created:0'] = {
          collection: 'ab-tests',
          data: entity,
        }
      },

      // Update collections

      // Update globals
      // Update global landing-page
      async (ctx: MigrationContext) => {
        // Save old value for reversal purposes
        ctx.backup = ctx.backup || { collections: [], globals: {} }
        const data = await payload.findGlobal({ req, slug: 'landing-page', locale: 'all' })
        ctx.backup.globals['landing-page'] = {
          header: data['header'],
          meta: data['meta'],
        }
        // Perform changes
        await payload.updateGlobal({
          req,
          slug: 'landing-page',
          locale: 'en',
          data: {
            header: {
              test: {
                relationTo: 'ab-tests',
                value: ctx.abTestLanding1.id,
              },
              variantA: 'Header variant A',
              variantB: 'Header variant B',
            },
            paragraph: 'Demo project v. 0.0.2',
            meta: {
              title: 'Web Foundation | U x Machina',
              description: 'State of the art web projects foundation',
            },
          },
        })
        await payload.updateGlobal({
          req,
          slug: 'landing-page',
          locale: 'pl',
          data: {
            header: {
              variantA: 'Nagłówek wariant A',
              variantB: 'Nagłówek wariant B',
            },
            paragraph: 'Projekt demonstracyjny v. 0.0.2',
            meta: {
              title: 'Web Foundation | U x Machina',
              description:
                'Produkcyjna baza projektów webowych z użyciem najnowocześniejszych technologii',
            },
          },
        })
      },
    ],
    down,
  )
}

/**
 * Reverses changes performed by the `up` function
 */
export async function down(
  { payload, req }: MigrateDownArgs,
  ctx: MigrationContext | undefined,
  successfulSteps: number | undefined,
): Promise<void> {
  return await reverseTransaction<MigrationContext>(
    [
      // Reverse collection deletions

      // Reverse collection creations
      // Reverse creation of ab-tests (id: 67127467fb335a348cdd7ad7)
      async (ctx: MigrationContext) => {
        const backup = ctx.backup.collections['created:0']
        await payload.delete({
          req,
          collection: backup.collection,
          id: backup.data.id,
        })
      },

      // Reverse collection updates

      // Reverse global updates
      async (ctx: MigrationContext) => {
        // Reverse updates to `landing-page`
        await payload.updateGlobal({
          req,
          slug: 'landing-page',
          data: {
            header: ctx.backup?.globals?.['landing-page']?.['header'] || null,
            meta: ctx.backup?.globals?.['landing-page']?.['meta'] || null,
          },
        })
      },
    ],
    ctx,
    successfulSteps,
  )
}
