import type { GlobalAfterChangeHook } from 'payload'

import { revalidateTag } from 'next/cache'

export const revalidateFooter: GlobalAfterChangeHook = ({ doc, req: { payload } }) => {
  payload.logger.info(`Revalidating footer`)

  try {
    revalidateTag('global_footer')
  } catch (e) {
    // This happens e.g. if we modify Footer within a migration, outside of React
  }

  return doc
}
