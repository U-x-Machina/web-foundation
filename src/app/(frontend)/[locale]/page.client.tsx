'use client'
import React from 'react'

import { useABTests } from '@/utilities/abTesting.client'
import { ActiveABTestsInfo } from '@/utilities/abTesting/abTesting.types'

interface Props {
  activeTests: ActiveABTestsInfo
  header: string
  paragraph: string
}

const LandingPageClient: React.FC<Props> = ({ activeTests, header, paragraph }: Props) => {
  const vA = activeTests['landing1'] === 'variantA'

  useABTests(activeTests)

  return (
    <React.Fragment>
      <div className="container py-28">
        <div className={`prose max-w-none ${vA ? 'text-orange-400' : 'text-blue-300'}`}>
          <h1 style={{ marginBottom: 0 }}>{header}</h1>
          <p className="mb-4">{paragraph}</p>
        </div>
      </div>
    </React.Fragment>
  )
}

export default LandingPageClient
