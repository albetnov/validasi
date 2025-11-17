// https://vitepress.dev/guide/custom-theme
import { h } from 'vue'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import './style.css'

// Import custom components
import GradientText from './components/GradientText.vue'
import CodeShowcase from './components/CodeShowcase.vue'
import VersionBanner from './components/VersionBanner.vue'

export default {
  extends: DefaultTheme,
  Layout: () => {
    return h(DefaultTheme.Layout, null, {
      // https://vitepress.dev/guide/extending-default-theme#layout-slots
    })
  },
  enhanceApp({ app, router, siteData }) {
    // Register custom components globally
    app.component('GradientText', GradientText)
    app.component('CodeShowcase', CodeShowcase)
    app.component('VersionBanner', VersionBanner)
  }
} satisfies Theme
