import { downloadFile } from '@/utilities/migrations'
import { MigrateDownArgs, MigrateUpArgs } from '@payloadcms/db-mongodb'

/**
 * Creates and uploads a media file for the logo
 * Links the logo in the header and footer;
 * Sets landing page strings;
 */
export async function up({ payload, req }: MigrateUpArgs): Promise<void> {
  const logoFilePath = await downloadFile(
    'https://storage.googleapis.com/uxm-web-foundation-eb51-migrations/20241004_204432_landing/logo-uxmachina-black.svg',
  )

  const logo = await payload.create({
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

  await payload.updateGlobal({
    slug: 'header',
    data: {
      logo: logo.id,
    },
  })

  await payload.updateGlobal({
    slug: 'footer',
    data: {
      logo: logo.id,
    },
  })

  await payload.updateGlobal({
    slug: 'landing-page',
    data: {
      header: 'Web Foundation',
      paragraph: 'Demo Project',
    },
  })
}

/**
 * Deletes the media file with the logo (will remain on GCS though)
 * Unlinks the logo in the header and footer;
 * Unsets landing page strings;
 */
export async function down({ payload, req }: MigrateDownArgs): Promise<void> {
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

  await payload.updateGlobal({
    slug: 'header',
    data: {
      logo: null,
    },
  })

  await payload.updateGlobal({
    slug: 'footer',
    data: {
      logo: null,
    },
  })

  await payload.updateGlobal({
    slug: 'landing-page',
    data: {
      header: null,
      paragraph: null,
    },
  })
}
