import type { GlobalAfterChangeHook } from 'payload'

import { revalidateTag } from 'next/cache'

export const revalidateFooter: GlobalAfterChangeHook = ({ doc, req: { payload } }) => {
  try {
    revalidateTag('global_footer')
    payload.logger.info(`Revalidating footer`)
  } catch (e) {
    // This happens e.g. if we modify Footer within a migration, outside of React
  }

  return doc
}
