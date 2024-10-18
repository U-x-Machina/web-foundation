import type { GlobalAfterChangeHook } from 'payload'

import { revalidateTag } from 'next/cache'

export const revalidateHeader: GlobalAfterChangeHook = ({ doc, req: { payload } }) => {
  try {
    revalidateTag('global_header')
    payload.logger.info(`Revalidating header`)
  } catch (e) {
    // This happens e.g. if we modify Footer within a migration, outside of React
  }

  return doc
}
