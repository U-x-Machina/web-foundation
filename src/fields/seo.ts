import {
  MetaDescriptionField,
  MetaImageField,
  MetaTitleField,
  OverviewField,
  PreviewField,
} from '@payloadcms/plugin-seo/fields'

export const SEO_FIELDS = {
  name: 'meta',
  label: 'SEO',
  fields: [
    OverviewField({
      titlePath: 'meta.title',
      descriptionPath: 'meta.description',
      imagePath: 'meta.image',
    }),
    MetaTitleField({
      hasGenerateFn: true,
      overrides: {
        localized: true,
        minLength: 10,
      },
    }),
    MetaImageField({
      relationTo: 'media',
      overrides: {
        localized: true,
      },
    }),

    MetaDescriptionField({
      overrides: {
        localized: true,
        minLength: 10,
      },
    }),
    PreviewField({
      // if the `generateUrl` function is configured
      hasGenerateFn: true,

      // field paths to match the target field for data
      titlePath: 'meta.title',
      descriptionPath: 'meta.description',
    }),
  ],
}
