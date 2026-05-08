import assert from 'node:assert/strict'
import { mkdir, mkdtemp, readFile, writeFile } from 'node:fs/promises'
import os from 'node:os'
import path from 'node:path'
import test from 'node:test'

import {
  buildMarkdownArtifacts,
  normalizeBookMarkdown,
  parseSummaryFiles,
  routePathForSourceFile,
} from './build-markdown-artifacts.mjs'

test('parses mdBook summary page links in order', () => {
  assert.deepEqual(
    parseSummaryFiles(`
# Contents

[Introduction](./intro.md)

- [Install](./installation.md)
- [Install again](./installation.md)
- [Not a local page](https://example.com/nope.md)
`),
    ['intro.md', 'installation.md']
  )
})

test('maps source pages to public html route paths', () => {
  assert.equal(routePathForSourceFile('installation.md'), 'installation.html')
  assert.equal(routePathForSourceFile('advanced/page.md'), 'advanced/page.html')
  assert.equal(routePathForSourceFile('SUMMARY.md'), null)
  assert.equal(routePathForSourceFile('images/static/part.png'), null)
})

test('normalizes mdBook-only markdown for curl output', () => {
  assert.equal(
    normalizeBookMarkdown(`
<!-- toc -->

# Page

Read [next](./next.md#section).
`),
    '# Page\n\nRead [next](next.html#section).\n'
  )
})

test('builds markdown artifacts for book pages and the intro alias', async () => {
  const root = await mkdtemp(path.join(os.tmpdir(), 'kcl-book-markdown-'))
  const bookSourceDir = path.join(root, 'src')
  const outputRoot = path.join(root, 'out')

  await mkdir(bookSourceDir, { recursive: true })
  await writeFile(
    path.join(bookSourceDir, 'SUMMARY.md'),
    '[Introduction](./intro.md)\n\n- [Install](./installation.md)\n',
    'utf8'
  )
  await writeFile(path.join(bookSourceDir, 'intro.md'), '# Intro\n', 'utf8')
  await writeFile(
    path.join(bookSourceDir, 'installation.md'),
    '<!-- toc -->\n\n# Installation\n',
    'utf8'
  )

  await buildMarkdownArtifacts({ bookSourceDir, outputRoot })

  assert.equal(
    await readFile(path.join(outputRoot, 'index.md'), 'utf8'),
    '# Intro\n'
  )
  assert.equal(
    await readFile(path.join(outputRoot, 'intro.html', 'index.md'), 'utf8'),
    '# Intro\n'
  )
  assert.equal(
    await readFile(
      path.join(outputRoot, 'installation.html', 'index.md'),
      'utf8'
    ),
    '# Installation\n'
  )
})

test('declares markdown headers for deployed artifacts', async () => {
  const vercelConfig = JSON.parse(
    await readFile(new URL('../vercel.json', import.meta.url), 'utf8')
  )

  assert.deepEqual(vercelConfig.headers, [
    {
      source: '/__docs-markdown/:path*',
      headers: [
        {
          key: 'Content-Type',
          value: 'text/markdown; charset=utf-8',
        },
        {
          key: 'X-Content-Type-Options',
          value: 'nosniff',
        },
        {
          key: 'X-Robots-Tag',
          value: 'noindex',
        },
      ],
    },
  ])
})
