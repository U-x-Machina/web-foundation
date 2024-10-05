import { getCachedGlobal } from '@/utilities/getGlobals'

import type { LandingPage } from '@/payload-types'
import { getMeUser } from '@/utilities/getMeUser'

type Props = {
  searchParams: { draft: boolean | undefined }
}

export default async function LandingPage({ searchParams }: Props) {
  const landingPage: LandingPage = await getCachedGlobal(
    'landing-page',
    0,
    !!searchParams.draft && !!(await getMeUser()).user,
  )()

  return (
    <div className="container py-28">
      <div className="prose max-w-none">
        <h1 style={{ marginBottom: 0 }}>{landingPage.header}</h1>
        <p className="mb-4">{landingPage.paragraph}</p>
      </div>
    </div>
  )
}
