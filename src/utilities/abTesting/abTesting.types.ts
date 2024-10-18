import { AbTest } from '@/payload-types'

export type ABVariant = 'variantA' | 'variantB'

export interface ABValue<ValueType> {
  test: {
    value: AbTest
  }
  variantA: ValueType
  variantB: ValueType
}

export interface ActiveABTestsInfo {
  [testId: string]: ABVariant
}
