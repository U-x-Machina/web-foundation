import { cookies } from 'next/headers'
import type React from 'react'

import { cookiesToGAUserProperties } from '@/utilities/abTesting/abTesting.utils'

interface Props {
  trackingId: string | undefined
}

export const GoogleAnalytics: React.FC<Props> = async ({ trackingId }) => {
  const userProperties = cookiesToGAUserProperties(cookies().getAll())

  return (
    <>
      {!!trackingId ? (
        <>
          <script async src={`https://www.googletagmanager.com/gtag/js?id=${trackingId}`} />
          <script
            dangerouslySetInnerHTML={{
              __html: `
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('set', 'user_properties', ${JSON.stringify(userProperties)})
            gtag('js', new Date());
            gtag('config', '${trackingId}');
          `,
            }}
          />
        </>
      ) : (
        <script
          dangerouslySetInnerHTML={{
            __html: `
          console.warn('[GoogleAnalytics] GOOGLE_ANALYTICS_TRACKING_ID environment variable not set')
        `,
          }}
        />
      )}
    </>
  )
}
