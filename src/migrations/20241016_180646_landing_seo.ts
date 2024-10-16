import { reverseTransaction, transaction } from '@/utilities/migrations'
import { MigrateDownArgs, MigrateUpArgs } from '@payloadcms/db-mongodb'

interface MigrationContext {
  backup: any
}

/**
 * Sets localized content for LandingPage texts and its SEO
 */
export async function up({ payload, req }: MigrateUpArgs): Promise<void> {
  await transaction<MigrationContext>(
    { payload, req },
    [
      // Delete collections

      // Create collections

      // Update collections

      // Update globals
      // Update global landing-page
      async (ctx: MigrationContext) => {
        // Save old value for reversal purposes
        ctx.backup = ctx.backup || { collections: [], globals: {} }
        const data = await payload.findGlobal({ req, slug: 'landing-page', locale: 'all' })
        ctx.backup.globals['landing-page'] = {
          paragraph: data['paragraph'],
          meta: data['meta'],
        }
        // Perform changes
        await payload.updateGlobal({
          req,
          slug: 'landing-page',
          data: {
            header: 'Web Foundation',
            paragraph: 'Demo Project v. 0.0.2',
            meta: {
              title: 'Web Foundation | U x Machina',
              description: 'State of the art web projects foundation',
            },
          },
          locale: 'en',
        })
        await payload.updateGlobal({
          req,
          slug: 'landing-page',
          data: {
            header: 'Web Foundation',
            paragraph: 'Projekt Demonstracyjny v. 0.0.2',
            meta: {
              title: 'Web Foundation | U x Machina',
              description:
                'Produkcyjna baza projektów webowych z użyciem najnowocześniejszych technologii',
            },
          },
          locale: 'pl',
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

      // Reverse collection updates

      // Reverse global updates
      async (ctx: MigrationContext) => {
        // Reverse updates to `landing-page`
        await payload.updateGlobal({
          req,
          slug: 'landing-page',
          data: {
            header: ctx.backup?.globals?.['landing-page']?.['header'] || null,
            paragraph: ctx.backup?.globals?.['landing-page']?.['paragraph'] || null,
            meta: ctx.backup?.globals?.['landing-page']?.['meta'] || null,
          },
        })
      },
    ],
    ctx,
    successfulSteps,
  )
}
