import type React from 'react'

export const trackEvent = (eventName: string, eventData: any) => {
  const gtag = window['gtag'] as any
  gtag('event', eventName, eventData)
}

interface Props {
  trackingId: string | undefined
}

export const GoogleAnalytics: React.FC<Props> = async ({ trackingId }) => {
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
