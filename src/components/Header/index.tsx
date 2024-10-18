import { getCachedGlobal } from '@/utilities/getGlobals'
import { HeaderClient } from './index.client'

import type { Header } from '@/payload-types'

export async function Header() {
  const header: Header = await getCachedGlobal('header', 1)()

  return <HeaderClient header={header} />
}
