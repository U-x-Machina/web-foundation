'use client'

import React from 'react'

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { LocaleInfo } from '@/i18n/config'
import { usePathname, useRouter } from '@/i18n/routing'

interface Props {
  currentLocale: string
  supportedLocales: LocaleInfo[]
}

export const LanguageSelector: React.FC<Props> = ({ currentLocale, supportedLocales }: Props) => {
  const pathname = usePathname()
  const router = useRouter()

  const onValueChange = (value: string) => {
    router.replace(pathname, { locale: value })
  }

  return (
    <Select onValueChange={onValueChange} value={currentLocale}>
      <SelectTrigger className="w-auto bg-transparent gap-2 pl-0 md:pl-3 border-none">
        <SelectValue placeholder="Language" />
      </SelectTrigger>
      <SelectContent>
        {supportedLocales.map((localeInfo) => (
          <SelectItem key={localeInfo.code} value={localeInfo.code}>
            {localeInfo.label}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  )
}
