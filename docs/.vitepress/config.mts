import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Validasi",
  description: "A flexible, composable, and type-safe validation library for Dart & Flutter",
  head: [
    ['link', { rel: 'icon', type: 'image/png', href: '/logo.png' }],
    ['meta', { name: 'theme-color', content: '#1e88e5' }],
    ['meta', { name: 'og:type', content: 'website' }],
    ['meta', { name: 'og:title', content: 'Validasi - Type-Safe Validation for Dart & Flutter' }],
    ['meta', { name: 'og:description', content: 'A flexible, composable, and type-safe validation library for Dart & Flutter' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
  ],
  themeConfig: {
    logo: '/logo.png',

    nav: [
      { text: 'Home', link: '/' },
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Examples', link: '/examples/string-validation' },
      {
        text: 'API Docs',
        link: 'https://pub.dev/documentation/validasi/latest'
      }
    ],

    sidebar: [
      {
        text: 'Getting Started',
        items: [
          { text: 'Introduction', link: '/guide/getting-started' },
          { text: 'Installation', link: '/guide/installation' },
          { text: 'Quick Start', link: '/guide/quick-start' }
        ]
      },
      {
        text: 'Core Concepts',
        items: [
          { text: 'Validation Schemas', link: '/guide/schemas' },
          { text: 'Built-in Rules', link: '/guide/rules' },
          { text: 'Transformations', link: '/guide/transformations' },
          { text: 'Error Handling', link: '/guide/error-handling' }
        ]
      },
      {
        text: 'Rule Reference',
        items: [
          { text: 'String Rules', link: '/rules/string' },
          { text: 'Number Rules', link: '/rules/number' },
          { text: 'Iterable Rules', link: '/rules/iterable' },
          { text: 'Map Rules', link: '/rules/map' }
        ]
      },
      {
        text: 'Examples',
        items: [
          { text: 'String Validation', link: '/examples/string-validation' },
          { text: 'Number Validation', link: '/examples/number-validation' },
          { text: 'List Validation', link: '/examples/list-validation' },
          { text: 'Map Validation', link: '/examples/map-validation' },
          { text: 'Complex Structures', link: '/examples/complex-structures' }
        ]
      },
      {
        text: 'Advanced',
        items: [
          { text: 'Custom Rules', link: '/advanced/custom-rule' },
          { text: 'Engine', link: '/advanced/engine' },
          { text: 'Cache', link: '/advanced/cache' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/albetnov/validasi' }
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2024-present Albet Novendo'
    },

    search: {
      provider: 'local'
    },

    editLink: {
      pattern: 'https://github.com/albetnov/validasi/edit/main/docs/:path',
      text: 'Edit this page on GitHub'
    }
  }
})
