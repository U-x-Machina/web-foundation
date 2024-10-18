import configPromise from '@payload-config'
import { getPayloadHMR } from '@payloadcms/next/utilities'
import { Metadata } from 'next'
import { unstable_setRequestLocale } from 'next-intl/server'
import { draftMode } from 'next/headers'

import type { LandingPage } from '@/payload-types'
import { getABData } from '@/utilities/abTesting'
import { generateMeta } from '@/utilities/generateMeta'
import { getCachedGlobal } from '@/utilities/getGlobals'
import LandingPageClient from './page.client'

export async function generateMetadata({ params: { locale } }): Promise<Metadata> {
  const payload = await getPayloadHMR({ config: configPromise })
  const pageData = await payload.findGlobal({ slug: 'landing-page', locale })

  return generateMeta({ doc: pageData })
}

export default async function LandingPage({ params: { locale } }) {
  unstable_setRequestLocale(locale)
  const { isEnabled: draft } = draftMode()
  const data: LandingPage = await getCachedGlobal('landing-page', 1, locale, draft)()
  const { activeTests, data: variantData } = await getABData<{ header: string; paragraph: string }>(
    data,
  )

  return <LandingPageClient activeTests={activeTests} {...variantData} />
}
