import { render } from '@testing-library/react'
import { NextIntlClientProvider } from 'next-intl'
import { expect, test, vi } from 'vitest'

import { LanguageSelector } from '.'

test('LanguageSelector', () => {
  const mocks = vi.hoisted(() => {
    return {
      usePathname: vi.fn(),
      useRouter: vi.fn(),
    }
  })

  vi.mock('@/i18n/routing', () => {
    return {
      usePathname: mocks.usePathname,
      useRouter: mocks.useRouter,
    }
  })

  const currentLocale = 'en'

  const result = render(
    <NextIntlClientProvider locale={currentLocale}>
      <LanguageSelector
        currentLocale={currentLocale}
        supportedLocales={[
          { label: 'English', code: 'en' },
          { label: 'Polski', code: 'pl' },
        ]}
      />
    </NextIntlClientProvider>,
  )

  expect(result.getAllByText('English').length).toBe(1)
})
