import { getCachedGlobal } from '@/utilities/getGlobals'

import type { LandingPage } from '@/payload-types'
import { draftMode } from 'next/headers'

export default async function LandingPage() {
  const { isEnabled: draft } = draftMode()
  const landingPage: LandingPage = await getCachedGlobal('landing-page', 0, draft)()

  return (
    <div className="container py-28">
      <div className="prose max-w-none">
        <h1 style={{ marginBottom: 0 }}>{landingPage.header}</h1>
        <p className="mb-4">{landingPage.paragraph}</p>
      </div>
    </div>
  )
}
