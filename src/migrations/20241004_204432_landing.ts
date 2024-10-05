import { Media } from '@/payload-types'
import { downloadFile, reverseTransaction, transaction } from '@/utilities/migrations'
import { MigrateDownArgs, MigrateUpArgs } from '@payloadcms/db-mongodb'

interface MigrationContext {
  logo: Media
}

/**
 * Creates and uploads a Media with the logo
 * Links the logo in the Header and Hooter
 * Sets LandingPage strings
 */
export async function up({ payload, req }: MigrateUpArgs): Promise<void> {
  await transaction<MigrationContext>(
    { payload, req },
    [
      // Create logo Media
      async (ctx: MigrationContext) => {
        const logoFilePath = await downloadFile(
          'https://storage.googleapis.com/uxm-web-foundation-eb51-migrations/20241004_204432_landing/logo-uxmachina-black.svg',
        )

        ctx.logo = await payload.create({
          collection: 'media',
          data: {
            alt: 'U x Machina logo',
            caption: {
              root: {
                children: [
                  {
                    children: [
                      {
                        detail: 0,
                        format: 0,
                        mode: 'normal',
                        style: '',
                        text: 'Black U x Machina logo',
                        type: 'text',
                        version: 1,
                      },
                    ],
                    direction: 'ltr',
                    format: '',
                    indent: 0,
                    type: 'paragraph',
                    version: 1,
                    textFormat: 0,
                    textStyle: '',
                  },
                ],
                direction: 'ltr',
                format: '',
                indent: 0,
                type: 'root',
                version: 1,
              },
            },
          },
          filePath: logoFilePath,
        })
      },
      // Link logo in the Header
      async (ctx: MigrationContext) => {
        await payload.updateGlobal({
          req,
          slug: 'header',
          data: {
            logo: ctx.logo.id,
          },
        })
      },
      // Link logo in the Footer
      async (ctx: MigrationContext) => {
        await payload.updateGlobal({
          req,
          slug: 'footer',
          data: {
            logo: ctx.logo.id,
          },
        })
      },
      // Update LandingPage texts
      async (ctx: MigrationContext) => {
        await payload.updateGlobal({
          req,
          slug: 'landing-page',
          data: {
            header: 'Web Foundation',
            paragraph: 'Demo Project',
          },
        })
      },
    ],
    down,
  )
}

/**
 * Deletes the Media with the logo
 * Unlinks the logo in the Header and Footer
 * Unsets LandingPage strings
 */
export async function down(
  { payload }: MigrateDownArgs,
  ctx: MigrationContext | undefined,
  successfulSteps: number | undefined,
): Promise<void> {
  return await reverseTransaction<MigrationContext>(
    [
      // Delete created media
      async (ctx: MigrationContext) => {
        const medias = await payload.find({
          collection: 'media',
          where: {
            filename: { equals: 'logo-uxmachina-black.svg' },
          },
        })
        if (medias.totalDocs !== 0) {
          for (let i = 0; i < medias.docs.length; ++i) {
            await payload.delete({ collection: 'media', id: medias.docs[0].id })
          }
        }
      },
      // Unlink logo from Header
      async (ctx: MigrationContext) => {
        await payload.updateGlobal({
          slug: 'header',
          data: {
            logo: null,
          },
        })
      },
      // Unlink logo from Footer
      async (ctx: MigrationContext) => {
        await payload.updateGlobal({
          slug: 'footer',
          data: {
            logo: null,
          },
        })
      },
      // Unset LandingPage texts
      async (ctx: MigrationContext) => {
        await payload.updateGlobal({
          slug: 'landing-page',
          data: {
            header: null,
            paragraph: null,
          },
        })
      },
    ],
    ctx,
    successfulSteps,
  )
}
