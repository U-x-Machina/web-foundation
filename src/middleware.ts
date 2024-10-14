import createMiddleware from 'next-intl/middleware'
import { NextRequest, NextResponse } from 'next/server'
import { routing } from './i18n/routing'

export const config = {
  matcher: ['/((?!_next|api|admin).*)'],
}

const i18nMiddleware = createMiddleware(routing)

const routeLocalized = (req: NextRequest) => {
  console.log(req.nextUrl.pathname)
  if (req.nextUrl.pathname.indexOf('.') === -1) {
    return i18nMiddleware(req as any)
  }
  return NextResponse.next()
}

export function middleware(req: NextRequest) {
  const basicAuthEnabled = process.env.BASIC_AUTH_ENABLED === 'true'

  if (!basicAuthEnabled) {
    return routeLocalized(req)
  }

  const basicAuth = req.headers.get('authorization')

  if (basicAuth) {
    const authValue = basicAuth.split(' ')[1]
    const [user, pwd] = atob(authValue).split(':')

    const validUser = process.env.BASIC_AUTH_USER
    const validPassWord = process.env.BASIC_AUTH_PASSWORD

    if (user === validUser && pwd === validPassWord) {
      return routeLocalized(req)
    }
  }

  const res = NextResponse.json({ error: 'Authentication required' }, { status: 401 })
  res.headers.set('WWW-authenticate', 'Basic realm="Secure Area"')

  return res
}
