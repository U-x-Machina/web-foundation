import { DEFAULT_LOCALE, SUPPORTED_LOCALES } from '@/i18n.config'
import { createSharedPathnamesNavigation } from 'next-intl/navigation'
import { defineRouting } from 'next-intl/routing'

export const routing = defineRouting({
  locales: SUPPORTED_LOCALES,
  defaultLocale: DEFAULT_LOCALE,
})

export const { Link, redirect, usePathname, useRouter } = createSharedPathnamesNavigation(routing)
