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
          'Ratio of people who should get this experiment active. E.g. 0.3 means this experiment will be served to 30% of visitors.',
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
