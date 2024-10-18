import Cookies from 'js-cookie'
import { useEffect } from 'react'

import { trackEvent } from '@/components/GoogleAnalytics'

import { ActiveABTestsInfo } from '../abTesting.types'
import { generateABTestCookieKey } from '../abTesting.utils'

export const useABTests = (tests: ActiveABTestsInfo) => {
  useEffect(() => {
    Object.keys(tests).forEach((testId) => {
      const variant = tests[testId]
      Cookies.set(generateABTestCookieKey(testId), variant)
      trackEvent(`ab_test_${testId}`, { variant })
    })
  }, [tests])
}
