import type {
  ArrayField,
  CheckboxField,
  CodeField,
  DateField,
  EmailField,
  GroupField,
  JSONField,
  NumberField,
  PointField,
  RadioField,
  RelationshipField,
  RichTextField,
  SelectField,
  TextareaField,
  TextField,
  UploadField,
} from 'payload'

type ABCapableField =
  | ArrayField
  | CheckboxField
  | CodeField
  | DateField
  | EmailField
  | GroupField
  | JSONField
  | NumberField
  | PointField
  | RadioField
  | RelationshipField
  | RichTextField
  | SelectField
  | TextareaField
  | TextField
  | UploadField

export function ABGroupField<FieldType extends ABCapableField>(
  name: string,
  options: FieldType,
): GroupField {
  return {
    name,
    type: 'group',
    fields: [
      {
        name: 'test',
        type: 'relationship',
        relationTo: ['ab-tests'],
      },
      {
        type: 'tabs',
        label: 'variants',
        tabs: [
          {
            label: 'variantA',
            fields: [
              {
                ...options,
                name: 'variantA',
              },
            ],
          },
          {
            label: 'variantB',
            fields: [
              {
                ...options,
                name: 'variantB',
              },
            ],
          },
        ],
      },
    ],
  }
}
