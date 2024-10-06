import type { GlobalConfig } from 'payload'

import { link } from '@/fields/link'
import { generatePreviewPath } from '@/utilities/generatePreviewPath'
import { revalidateFooter } from './hooks/revalidateFooter'

export const Footer: GlobalConfig = {
  slug: 'footer',
  access: {
    read: () => true,
  },
  fields: [
    {
      name: 'logo',
      type: 'upload',
      relationTo: 'media',
      hasMany: false,
      filterOptions: {
        mimeType: { contains: 'image' },
      },
    },
    {
      name: 'navItems',
      type: 'array',
      fields: [
        link({
          appearances: false,
        }),
      ],
      maxRows: 6,
    },
  ],
  hooks: {
    afterChange: [revalidateFooter],
  },
  admin: {
    livePreview: {
      url: `${process.env.NEXT_PUBLIC_SERVER_URL}${generatePreviewPath({ path: '/' })}`,
    },
    preview: (doc, options) =>
      `${process.env.NEXT_PUBLIC_SERVER_URL}${generatePreviewPath({ path: '/' })}`,
  },
}
