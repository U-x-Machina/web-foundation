import type { GlobalAfterChangeHook } from 'payload'

import { revalidateTag } from 'next/cache'

export const revalidateLandingPage: GlobalAfterChangeHook = ({ doc, req: { payload } }) => {
  try {
    revalidateTag('global_landing-page_draft') // draft version
    revalidateTag('global_landing-page') // published version
    payload.logger.info(`Revalidating LandingPage`)
  } catch (e) {
    // This happens e.g. if we modify LandingPage within a migration, outside of React
  }

  return doc
}
