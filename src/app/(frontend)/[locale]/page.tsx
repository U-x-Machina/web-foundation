import configPromise from '@payload-config'
import { getPayloadHMR } from '@payloadcms/next/utilities'
import { Metadata } from 'next'
import { unstable_setRequestLocale } from 'next-intl/server'
import { draftMode } from 'next/headers'

import type { LandingPage } from '@/payload-types'
import { generateMeta } from '@/utilities/generateMeta'
import { getCachedGlobal } from '@/utilities/getGlobals'

export async function generateMetadata({ params: { locale } }): Promise<Metadata> {
  const payload = await getPayloadHMR({ config: configPromise })
  const pageData = await payload.findGlobal({ slug: 'landing-page', locale })

  return generateMeta({ doc: pageData })
}

export default async function LandingPage({ params: { locale } }) {
  unstable_setRequestLocale(locale)
  const { isEnabled: draft } = draftMode()
  const landingPage: LandingPage = await getCachedGlobal('landing-page', 0, locale, draft)()

  return (
    <div className="container py-28">
      <div className="prose max-w-none">
        <h1 style={{ marginBottom: 0 }}>{landingPage.header}</h1>
        <p className="mb-4">{landingPage.paragraph}</p>
      </div>
    </div>
  )
}
