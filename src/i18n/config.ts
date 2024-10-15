export interface LocaleInfo {
  label: string
  code: string
}

export const SUPPORTED_LOCALES: LocaleInfo[] = [
  {
    label: 'English',
    code: 'en',
  },
  {
    label: 'Polski',
    code: 'pl',
  },
]
export const DEFAULT_LOCALE = 'en'
