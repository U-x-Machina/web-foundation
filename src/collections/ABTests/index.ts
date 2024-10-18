import type { CollectionConfig } from 'payload'

import { anyone } from '../../access/anyone'
import { authenticated } from '../../access/authenticated'

const ABTests: CollectionConfig = {
  slug: 'ab-tests',
  access: {
    create: authenticated,
    delete: authenticated,
    read: anyone,
    update: authenticated,
  },
  admin: {
    useAsTitle: 'testId',
  },
  fields: [
    {
      name: 'testId',
      type: 'text',
      required: true,
      unique: true,
    },
    {
      name: 'description',
      type: 'text',
      required: true,
    },
    {
      name: 'split',
      type: 'number',

      required: true,
      min: 0.1,
      max: 0.9,
      defaultValue: 0.5,
      admin: {
        step: 0.1,
        description:
          'Ratio of A/B variants. E.g. 0.3 means that variant A will be served to 30% of visitors and variant B to 70%.',
      },
    },
    {
      name: 'active',
      type: 'checkbox',
      required: true,
      defaultValue: true,
    },
  ],
}

export default ABTests
