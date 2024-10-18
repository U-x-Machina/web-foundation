import type { Config } from 'src/payload-types'

import configPromise from '@payload-config'
import { getPayloadHMR } from '@payloadcms/next/utilities'
import { unstable_cache } from 'next/cache'

type Global = keyof Config['globals']

async function getGlobal(slug: Global, depth = 0, locale: string | null = null, draft = false) {
  const payload = await getPayloadHMR({ config: configPromise })

  const global = await payload.findGlobal({
    slug,
    depth,
    locale: locale as any,
    draft,
  })

  return global
}

/**
 * Returns a unstable_cache function mapped with the cache tag for the slug
 */
export const getCachedGlobal = (
  slug: Global,
  depth = 0,
  locale: string | null = null,
  draft = false,
) => {
  const localizedSlug = locale ? `${slug}_${locale}` : slug
  const tagSlug = draft ? `${localizedSlug}_draft` : localizedSlug
  return unstable_cache(async () => getGlobal(slug, depth, locale, draft), [tagSlug], {
    tags: [`global_${tagSlug}`],
  })
}
