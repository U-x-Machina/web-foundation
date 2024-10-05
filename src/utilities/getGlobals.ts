import type { Config } from 'src/payload-types'

import configPromise from '@payload-config'
import { getPayloadHMR } from '@payloadcms/next/utilities'
import { unstable_cache } from 'next/cache'

type Global = keyof Config['globals']

async function getGlobal(slug: Global, depth = 0, draft = false) {
  const payload = await getPayloadHMR({ config: configPromise })

  const global = await payload.findGlobal({
    slug,
    depth,
    draft,
  })

  return global
}

/**
 * Returns a unstable_cache function mapped with the cache tag for the slug
 */
export const getCachedGlobal = (slug: Global, depth = 0, draft = false) => {
  const tagSlug = draft ? `${slug}_draft` : slug
  return unstable_cache(async () => getGlobal(slug, depth, draft), [tagSlug], {
    tags: [`global_${tagSlug}`],
  })
}
