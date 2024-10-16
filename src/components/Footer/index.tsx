import { getCachedGlobal } from '@/utilities/getGlobals'
import Link from 'next/link'

import type { Footer, Media } from '@/payload-types'

import { LanguageSelector } from '@/components/LanguageSelector'
import { CMSLink } from '@/components/Link'
import { SUPPORTED_LOCALES } from '@/i18n/config'
import { ThemeSelector } from '@/providers/Theme/ThemeSelector'

interface Props {
  locale: string
}

export async function Footer({ locale }: Props) {
  const footer: Footer = await getCachedGlobal('footer', 1)()

  const navItems = footer?.navItems || []

  return (
    <footer className="border-t border-border bg-black dark:bg-card text-white">
      <div className="container py-8 gap-8 flex flex-col md:flex-row md:justify-between">
        <Link className="flex items-center" href="/">
          <picture>
            {footer.logo && (
              <img
                alt={(footer.logo as Media).alt}
                className="max-w-[6rem] invert-0"
                src={(footer.logo as Media).url!}
              />
            )}
          </picture>
        </Link>

        <div className="flex flex-col-reverse items-start md:flex-row gap-4 md:items-center">
          <LanguageSelector currentLocale={locale} supportedLocales={SUPPORTED_LOCALES} />
          <ThemeSelector />
          <nav className="flex flex-col md:flex-row gap-4">
            {navItems.map(({ link }, i) => {
              return <CMSLink className="text-white" key={i} {...link} />
            })}
          </nav>
        </div>
      </div>
    </footer>
  )
}
