import type { GlobalAfterChangeHook } from 'payload'

import { revalidateTag } from 'next/cache'

export const revalidateHeader: GlobalAfterChangeHook = ({ doc, req: { payload } }) => {
  payload.logger.info(`Revalidating header`)

  try {
    revalidateTag('global_header')
  } catch (e) {
    // This happens e.g. if we modify Footer within a migration, outside of React
  }

  return doc
}
