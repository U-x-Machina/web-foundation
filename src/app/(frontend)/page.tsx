import { getCachedGlobal } from '@/utilities/getGlobals'

import type { LandingPage } from '@/payload-types'

export default async function LandingPage() {
  const landingPage: LandingPage = await getCachedGlobal('landing-page')()

  return (
    <div className="container py-28">
      <div className="prose max-w-none">
        <h1 style={{ marginBottom: 0 }}>{landingPage.header}</h1>
        <p className="mb-4">{landingPage.paragraph}</p>
      </div>
    </div>
  )
}
