import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Validasi Docs",
  description: "Validasi Documentation Website",
  base: '/validasi/',
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Quick Start', link: '/quick-start' },
    ],

    sidebar: [
      {text: 'Quick Start', link: '/quick-start'},
      {
        text: 'Guide',
        items: [
          {text: 'Execution Flow', link: '/guide/execution-order'},
          {text: 'Basic Concept', link: '/guide/basic-concept'},
          {text: 'Transformer', link: '/guide/transformer'},
          {text: 'Custom Rule', link: '/guide/custom-rule'},
          {text: 'Helpers', link: '/guide/helpers'},
        ]
      },
      {
        text: 'Types',
        items: [
          {text: 'String', link: '/types/string'},
          {text: 'Number', link: '/types/number'},
          {text: 'Date', link: '/types/date'},
          {text: 'Array', link: '/types/array'},
          {text: 'Object', link: '/types/object'},
          {text: 'Generic', link: '/types/generic'},
        ]
      },
      {
        text: 'Extending',
        items: [
          {text: 'New Validation', link: '/extending/new-validation'},
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/albetnov/validasi' },
    ]
  }
})
