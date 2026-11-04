// https://vitepress.dev/guide/custom-theme
import { h } from 'vue'
import { useData, useRoute, withBase } from 'vitepress'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'

import './style.css'

// Import custom components
import GradientText from './components/GradientText.vue'
import CodeShowcase from './components/CodeShowcase.vue'
import VersionBanner from './components/VersionBanner.vue'
import CopyOrDownMd from './components/CopyOrDownMd.vue'

const versionBanner = (isV0: boolean) =>
  h('div', { class: 'global-version-banner' }, [
    h(
      'span',
      isV0
        ? 'You are viewing v0 documentation'
        : 'Validasi v1 documentation',
    ),
    h(
      'a',
      { href: withBase(isV0 ? '/' : '/v0/') },
      isV0 ? 'View v1 docs →' : 'View v0 docs →',
    ),
  ])

export default {
  extends: DefaultTheme,
  Layout: () => {
    const route = useRoute()
    const { site } = useData()
    const base = site.value.base.replace(/\/$/, '')
    const path = route.path.startsWith(base)
      ? route.path.slice(base.length)
      : route.path
    const isV0 = path.startsWith('/v0')
    return h(DefaultTheme.Layout, null, {
      'layout-top': () => versionBanner(isV0),
    })
  },
  enhanceApp({ app, router, siteData }) {
    // Register custom components globally
    app.component('GradientText', GradientText)
    app.component('CodeShowcase', CodeShowcase)
    app.component('VersionBanner', VersionBanner)
    app.component('CopyOrDownloadAsMarkdownButtons', CopyOrDownMd)
  }
} satisfies Theme
