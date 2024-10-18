import Cookies from 'js-cookie'
import { useEffect } from 'react'
import { ActiveABTestsInfo } from './abTesting/abTesting.types'
import { generateABTestCookieKey } from './abTesting/abTesting.utils'

export const useABTests = (tests: ActiveABTestsInfo) => {
  useEffect(() => {
    Object.keys(tests).forEach((testId) => {
      const variant = tests[testId]
      Cookies.set(generateABTestCookieKey(testId), variant)
      const gtag: any = window['gtag']
      gtag('set', 'user_properties', {
        [`abtest-${testId}`]: variant,
      })
    })
  }, [tests])
}
