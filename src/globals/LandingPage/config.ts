import { authenticatedOrPublished } from '@/access/authenticatedOrPublished'
import { generatePreviewPath } from '@/utilities/generatePreviewPath'
import type { GlobalConfig } from 'payload'
import { revalidateLandingPage } from './hooks/revalidateLandingPage'

export const LandingPage: GlobalConfig = {
  slug: 'landing-page',
  access: {
    read: (args) => authenticatedOrPublished(args),
  },
  fields: [
    {
      name: 'header',
      type: 'text',
      localized: true,
    },
    {
      name: 'paragraph',
      type: 'text',
      localized: true,
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
