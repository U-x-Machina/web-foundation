import { cookies } from 'next/headers'

import { ABValue, ABVariant, ActiveABTestsInfo } from './abTesting/abTesting.types'
import { generateABTestCookieKey } from './abTesting/abTesting.utils'

function log(...args) {
  console.log.apply(console, ['[ABTesting]', ...args])
}

function process<DataType>(
  data: object,
  activeTestsLocal: { [testId: string]: ABVariant } | undefined = undefined,
): { activeTests: ActiveABTestsInfo; data: DataType } {
  let result = {}
  let activeTests: ActiveABTestsInfo = activeTestsLocal || {}
  const cookieStore = cookies()

  Object.keys(data).forEach((key) => {
    let value = data[key]
    if (
      typeof value === 'object' &&
      typeof value.variantA !== 'undefined' &&
      typeof value.variantB !== 'undefined' &&
      typeof value.test !== 'undefined'
    ) {
      const abValue = value as ABValue<typeof value.variantA>
      let variant: ABVariant = 'variantA'
      if (abValue.test.value.active) {
        if (!activeTests[abValue.test.value.testId]) {
          const cookieKey = generateABTestCookieKey(abValue.test.value.testId)
          if (cookieStore.has(cookieKey)) {
            activeTests[abValue.test.value.testId] =
              cookieStore.get(cookieKey)?.value === 'variantB' ? 'variantB' : 'variantA'
            log(
              `restoring test ${abValue.test.value.testId} to ${activeTests[abValue.test.value.testId]}`,
            )
          } else {
            activeTests[abValue.test.value.testId] =
              Math.random() > abValue.test.value.split ? 'variantB' : 'variantA'
            log(
              `initiating test ${abValue.test.value.testId} to ${activeTests[abValue.test.value.testId]}`,
            )
          }
        }
        variant = activeTests[abValue.test.value.testId]
      }
      value = abValue[variant]
    } else if (typeof value === 'object') {
      const { data: nestedProcessedValue } = process(value, activeTests)
      value = nestedProcessedValue
    }
    result[key] = value
  })

  return {
    activeTests,
    data: result as DataType,
  }
}

export async function getABData<DataType>(
  fullData: object,
): Promise<{ activeTests: ActiveABTestsInfo; data: DataType }> {
  return process<DataType>(fullData)
}
