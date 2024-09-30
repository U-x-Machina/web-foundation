import { NextRequest, NextResponse } from 'next/server'

export const config = {
  matcher: ['/((?!_next|api|admin).*)'],
}

export function middleware(req: NextRequest) {
  const basicAuthEnabled = process.env.BASIC_AUTH_ENABLED === 'true'

  if (!basicAuthEnabled) {
    return NextResponse.next()
  }

  const basicAuth = req.headers.get('authorization')

  if (basicAuth) {
    const authValue = basicAuth.split(' ')[1]
    const [user, pwd] = atob(authValue).split(':')

    const validUser = process.env.BASIC_AUTH_USER
    const validPassWord = process.env.BASIC_AUTH_PASSWORD

    if (user === validUser && pwd === validPassWord) {
      return NextResponse.next()
    }
  }

  const res = NextResponse.json({ error: 'Authentication required' }, { status: 401 })
  res.headers.set('WWW-authenticate', 'Basic realm="Secure Area"')

  return res
}
