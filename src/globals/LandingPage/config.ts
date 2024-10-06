import { generatePreviewPath } from '@/utilities/generatePreviewPath'
import type { GlobalConfig } from 'payload'
import { revalidateLandingPage } from './hooks/revalidateLandingPage'

export const LandingPage: GlobalConfig = {
  slug: 'landing-page',
  access: {
    read: ({ req }) => {
      // If there is a user logged in,
      // let them retrieve all documents
      if (req.user) return true

      // If there is no user,
      // restrict the documents that are returned
      // to only those where `_status` is equal to `published`
      return {
        _status: {
          equals: 'published',
        },
      }
    },
  },
  fields: [
    {
      name: 'header',
      type: 'text',
    },
    {
      name: 'paragraph',
      type: 'text',
    },
  ],
  versions: {
    drafts: {
      autosave: {
        interval: 200,
      },
    },
  },
  hooks: {
    afterChange: [revalidateLandingPage],
  },
  admin: {
    group: 'Pages',
    livePreview: {
      url: `${process.env.NEXT_PUBLIC_SERVER_URL}${generatePreviewPath({ path: '/' })}`,
    },
    preview: (doc, options) =>
      `${process.env.NEXT_PUBLIC_SERVER_URL}${generatePreviewPath({ path: '/' })}`,
  },
}
