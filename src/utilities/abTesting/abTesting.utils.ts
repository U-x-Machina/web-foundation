export const ABTEST_COOKIE_PREFIX = 'uxm-abtest-'

export const generateABTestCookieKey = (testId: string) => `${ABTEST_COOKIE_PREFIX}${testId}`

export const cookiesToGAUserProperties = (cookies: { name: string; value: string }[]) => {
  return cookies
    .filter((cookie) => cookie.name.startsWith(ABTEST_COOKIE_PREFIX))
    .reduce((prev, curr) => {
      prev[curr.name] = curr.value
      return prev
    }, {})
}
