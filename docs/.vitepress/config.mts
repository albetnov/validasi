import { defineConfig } from 'vitepress'
import llmstxt, { copyOrDownloadAsMarkdownButtons } from 'vitepress-plugin-llms'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  vite: {
    plugins: [llmstxt()],
  },
  title: "Validasi",
  description: "A flexible, composable, and type-safe validation library for Dart & Flutter",
  base: '/validasi/',
  head: [
    ['link', { rel: 'icon', type: 'image/png', href: '/logo.png' }],
    ['meta', { name: 'theme-color', content: '#1e88e5' }],
    ['meta', { name: 'og:type', content: 'website' }],
    ['meta', { name: 'og:title', content: 'Validasi - Type-Safe Validation for Dart & Flutter' }],
    ['meta', { name: 'og:description', content: 'A flexible, composable, and type-safe validation library for Dart & Flutter' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
  ],
  markdown: {
    config(md) {
      md.use(copyOrDownloadAsMarkdownButtons)
    },
  },
  themeConfig: {
    logo: '/logo.png',

    nav: [
      { text: 'Home', link: '/' },
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Examples', link: '/examples/string-validation' },
      {
        text: 'v1.0.0-dev',
        items: [
          { text: 'v1 Documentation (Current)', link: '/guide/getting-started' },
          { text: 'v0 Documentation', link: '/v0/' }
        ]
      },
      {
        text: 'API Docs',
        link: 'https://pub.dev/documentation/validasi/latest'
      }
    ],

    sidebar: {
      '/v0/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Introduction', link: '/v0/' },
            { text: 'Quick Start', link: '/v0/quick-start' }
          ]
        },
        {
          text: 'Guide',
          items: [
            { text: 'Basic Concept', link: '/v0/guide/basic-concept' },
            { text: 'Custom Rule', link: '/v0/guide/custom-rule' },
            { text: 'Execution Order', link: '/v0/guide/execution-order' },
            { text: 'Helpers', link: '/v0/guide/helpers' },
            { text: 'Transformer', link: '/v0/guide/transformer' }
          ]
        },
        {
          text: 'Types',
          items: [
            { text: 'String', link: '/v0/types/string' },
            { text: 'Number', link: '/v0/types/number' },
            { text: 'Array', link: '/v0/types/array' },
            { text: 'Object', link: '/v0/types/object' },
            { text: 'Date', link: '/v0/types/date' },
            { text: 'Generic', link: '/v0/types/generic' }
          ]
        },
        {
          text: 'Extending',
          items: [
            { text: 'New Validation', link: '/v0/extending/new-validation' }
          ]
        }
      ],
      '/': [
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
            { text: 'Built-in Modifier Rules', link: '/guide/modifier-rules' },
            { text: 'Transformations', link: '/guide/transformations' },
            { text: 'Error Handling', link: '/guide/error-handling' }
          ]
        },
        {
          text: 'Schemas',
          items: [
            { text: 'String Schema', link: '/schemas/string' },
            { text: 'Number Schema', link: '/schemas/number' },
            { text: 'List Schema', link: '/schemas/list' },
            { text: 'Map Schema', link: '/schemas/map' },
            { text: 'Generic/Any Schema', link: '/schemas/any' }
          ]
        },
        {
          text: 'Advanced',
          items: [
            { text: 'Custom Rules', link: '/advanced/custom-rule' },
            { text: 'Engine', link: '/advanced/engine' }
          ]
        },
        {
          text: 'Integration',
          items: [
            { text: 'MCP Server', link: '/guide/mcp-server' }
          ]
        }
      ]
    },

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
