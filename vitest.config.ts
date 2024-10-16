import react from '@vitejs/plugin-react'
import path from 'path'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
  },
  resolve: {
    alias: {
      '@payload-config': path.resolve(__dirname, './src/payload.config.ts'),
      '@': path.resolve(__dirname, './src'),
    },
  },
})
