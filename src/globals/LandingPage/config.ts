import type { GlobalConfig } from 'payload'

export const LandingPage: GlobalConfig = {
  slug: 'landing-page',
  access: {
    read: () => true,
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
  admin: {
    group: 'Pages',
  },
}
