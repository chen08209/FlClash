import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { runInNewContext } from 'node:vm';

const [out, siteArg] = process.argv.slice(2);
if (!out || !siteArg) {
  console.error('usage: render_site.mjs <site dir> <site url>');
  process.exit(64);
}
const siteUrl = new URL(siteArg.replace(/\/*$/, '/')).href;

const PAGES = [
  // The head script in index.html keeps the English root from redirecting to zh/ when it sees ?lang=en.
  { lang: 'en', locale: 'en', ogLocale: 'en_US', path: '', toggle: '?lang=en' },
  { lang: 'zh', locale: 'zh-CN', ogLocale: 'zh_CN', path: 'zh/', toggle: 'zh/' },
];

const sandbox = {};
runInNewContext(readFileSync(join(out, 'assets/shared.js'), 'utf8'), sandbox);
const { REPO, FIRST_PAGE, STRINGS, parseChangelog, changelogMeta, escapeHtml: escape, timelineHtml } =
  sandbox.FlClashSite;

const template = readFileSync(join(out, 'index.html'), 'utf8');
const versions = parseChangelog(readFileSync(join(out, 'CHANGELOG.md'), 'utf8'));
const releasePath = join(out, 'release.json');
const release = existsSync(releasePath) ? JSON.parse(readFileSync(releasePath, 'utf8')) : null;
const latest = release?.tag
  ? { version: release.tag.replace(/^v/, ''), date: (release.publishedAt || '').slice(0, 10) }
  : versions.find((v) => !v.tag.includes('-'));

function replaceOnce(html, pattern, replacement) {
  if (!pattern.test(html)) throw new Error(`index.html no longer matches ${pattern}`);
  return html.replace(pattern, replacement);
}

function structuredData(t, page) {
  return {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: 'FlClash',
    url: siteUrl + page.path,
    description: t.pageDescription,
    inLanguage: page.locale,
    applicationCategory: 'UtilitiesApplication',
    operatingSystem: 'Android, Windows, macOS, Linux',
    image: `${siteUrl}preview.png`,
    downloadUrl: `${REPO}/releases/latest`,
    ...(latest ? { softwareVersion: latest.version, dateModified: latest.date || undefined } : {}),
    license: 'https://www.gnu.org/licenses/gpl-3.0.html',
    isAccessibleForFree: true,
    offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
    sameAs: [REPO],
  };
}

function render(page) {
  const t = STRINGS[page.lang];
  const text = (key) => escape(t[key]);
  const up = '../'.repeat(page.path.split('/').length - 1);
  const other = PAGES.find((p) => p !== page);
  let html = template;

  html = replaceOnce(html, /<html lang="[^"]*">/, `<html lang="${page.locale}" data-page-lang="${page.lang}">`);
  html = replaceOnce(html, /<title>[^<]*<\/title>/, `<title>${text('pageTitle')}</title>`);
  html = replaceOnce(html, /(<meta name="description" content=")[^"]*/, `$1${text('pageDescription')}`);
  html = replaceOnce(html, /(<meta property="og:description" content=")[^"]*/, `$1${text('heroLede')}`);
  html = replaceOnce(html, /(<meta property="og:image" content=")[^"]*/, `$1${siteUrl}preview.png`);
  const alternates = PAGES.map(
    (p) => `  <link rel="alternate" hreflang="${p.locale}" href="${siteUrl}${p.path}">`,
  ).join('\n');
  const head = [
    `  <link rel="canonical" href="${siteUrl}${page.path}">`,
    alternates,
    `  <link rel="alternate" hreflang="x-default" href="${siteUrl}">`,
    `  <meta property="og:url" content="${siteUrl}${page.path}">`,
    `  <meta property="og:locale" content="${page.ogLocale}">`,
    `  <script type="application/ld+json">${JSON.stringify(structuredData(t, page)).replace(/</g, '\\u003c')}</script>`,
  ].join('\n');
  html = replaceOnce(html, /(<meta name="twitter:card"[^>]*>\n)/, `$1${head}\n`);

  html = html.replace(
    /(<(\w+)\b[^>]*\bdata-i18n="(\w+)"[^>]*>)[^<]*(<\/\2>)/g,
    (_, open, _tag, key, close) => `${open}${text(key)}${close}`,
  );
  html = html.replace(/(\balt=")[^"]*("[^>]*data-i18n-alt="(\w+)")/g, (_, a, b, key) => `${a}${text(key)}${b}`);
  html = html.replace(
    /(\bplaceholder=")[^"]*("[^>]*data-i18n-placeholder="(\w+)")/g,
    (_, a, b, key) => `${a}${text(key)}${b}`,
  );

  // With the count in the page, the GitHub link has its final width from the first paint instead of growing when
  // release.json arrives.
  if (typeof release?.stars === 'number') {
    const stars = new Intl.NumberFormat(page.locale, { notation: 'compact', maximumFractionDigits: 1 });
    html = replaceOnce(
      html,
      /<span id="stars" class="stars" hidden><\/span>/,
      `<span id="stars" class="stars" data-count="${release.stars}">${escape(stars.format(release.stars))}</span>`,
    );
  }

  if (versions.length) {
    const meta = escape(changelogMeta(versions, page.lang));
    html = replaceOnce(html, /(<p class="section-sub" id="cl-meta">)(<\/p>)/, (_, open, close) => open + meta + close);
    const releases = timelineHtml(
      versions.slice(0, FIRST_PAGE).map((version) => ({ version, groups: version.groups })),
      { lang: page.lang, latestTag: versions[0].tag },
    ).html;
    html = replaceOnce(
      html,
      /(<div class="timeline" id="timeline">)(<\/div>)/,
      (_, open, close) => `${open}\n${releases}\n${close}`,
    );
  }

  if (up) html = html.replace(/\b(href|src|srcset)="(?![a-z]+:|#|\/)/g, `$1="${up}`);
  return replaceOnce(
    html,
    /<button class="tool" id="lang-toggle" type="button">[^<]*<\/button>/,
    `<a class="tool" id="lang-toggle" href="${up}${other.toggle}" hreflang="${other.locale}" lang="${other.locale}" ` +
      `aria-label="${text('langLabel')}">${text('langToggle')}</a>`,
  );
}

for (const page of PAGES) {
  const dir = join(out, page.path);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, 'index.html'), render(page));
}

const lastmod = latest?.date ? `<lastmod>${latest.date}</lastmod>` : '';
const links = PAGES.map(
  (p) => `<xhtml:link rel="alternate" hreflang="${p.locale}" href="${siteUrl}${p.path}"/>`,
).join('');
writeFileSync(
  join(out, 'sitemap.xml'),
  '<?xml version="1.0" encoding="UTF-8"?>\n' +
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">\n' +
    PAGES.map((p) => `  <url><loc>${siteUrl}${p.path}</loc>${lastmod}${links}</url>\n`).join('') +
    '</urlset>\n',
);
