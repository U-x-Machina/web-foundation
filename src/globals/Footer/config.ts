import type { GlobalConfig } from 'payload'

import { link } from '@/fields/link'
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
      url: 'http://localhost:3000?draft=true',
    },
    preview: (doc, options) => 'http://localhost:3000?draft=true',
  },
}
