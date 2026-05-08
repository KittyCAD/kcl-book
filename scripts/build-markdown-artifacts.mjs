import { mkdir, readFile, rm, writeFile } from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath, pathToFileURL } from 'node:url'

export const DOCS_MARKDOWN_PUBLIC_ROUTE = '/__docs-markdown'
export const DOCS_MARKDOWN_ACCEPT_HEADER_VALUE =
  '(^|.*,\\s*)text/markdown(\\s*;[^,]*)?(\\s*,.*|$)'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const repoRoot = path.resolve(__dirname, '..')
const defaultBookSourceDir = path.join(repoRoot, 'kcl-book', 'src')
const defaultOutputRoot = path.join(
  repoRoot,
  'kcl-book',
  'book',
  DOCS_MARKDOWN_PUBLIC_ROUTE,
  'docs',
  'kcl-book'
)

export function parseSummaryFiles(summaryMarkdown) {
  const files = []
  const seen = new Set()
  const pageLinkRegexp = /\]\(\.\/([^)#?]+\.md)(?:[#?][^)]*)?\)/g

  for (const match of summaryMarkdown.matchAll(pageLinkRegexp)) {
    const file = match[1]
    if (file === 'SUMMARY.md' || seen.has(file)) continue
    seen.add(file)
    files.push(file)
  }

  return files
}

export function routePathForSourceFile(relativeSourcePath) {
  const normalized = relativeSourcePath.replace(/\\/g, '/')
  if (!/\.md$/i.test(normalized)) return null
  if (normalized.toLowerCase() === 'summary.md') return null

  return normalized.replace(/\.md$/i, '.html')
}

export function normalizeBookMarkdown(source) {
  const markdown = source
    .replace(/^\s*<!--\s*toc\s*-->\s*$/gim, '')
    .replace(/\]\(\.\/([^)#?]+)\.md(#[^)]*)?\)/g, ']($1.html$2)')
    .trim()

  return `${markdown}\n`
}

async function writeMarkdown(outputRoot, routePath, markdown) {
  const outputPath = path.join(outputRoot, routePath, 'index.md')
  await mkdir(path.dirname(outputPath), { recursive: true })
  await writeFile(outputPath, markdown, 'utf8')
}

export async function buildMarkdownArtifacts({
  bookSourceDir = defaultBookSourceDir,
  outputRoot = defaultOutputRoot,
} = {}) {
  await rm(outputRoot, { force: true, recursive: true })
  await mkdir(outputRoot, { recursive: true })

  const summary = await readFile(path.join(bookSourceDir, 'SUMMARY.md'), 'utf8')
  const sourceFiles = parseSummaryFiles(summary)

  for (const sourceFile of sourceFiles) {
    const routePath = routePathForSourceFile(sourceFile)
    if (!routePath) continue

    const source = await readFile(path.join(bookSourceDir, sourceFile), 'utf8')
    const markdown = normalizeBookMarkdown(source)
    await writeMarkdown(outputRoot, routePath, markdown)

    if (routePath === 'intro.html') {
      await writeFile(path.join(outputRoot, 'index.md'), markdown, 'utf8')
    }
  }
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  await buildMarkdownArtifacts()
}
