globalThis.FlClashSite = (() => {
  'use strict';

  const REPO = 'https://github.com/chen08209/FlClash';
  const FIRST_PAGE = 6;
  const MAX_STAGGER = 16;
  const TYPE_BY_TITLE = {
    'Breaking Changes': 'breaking',
    Features: 'feat',
    'Bug Fixes': 'fix',
    Performance: 'perf',
    Reverts: 'revert',
  };
  const TYPE_KEYS = { breaking: 'typeBreaking', feat: 'typeFeat', fix: 'typeFix', perf: 'typePerf', revert: 'typeRevert' };
  const ICON_EXTERNAL =
    '<svg viewBox="0 0 16 16" width="12" height="12" aria-hidden="true"><path d="M6 3.5h6.5V10M12.25 3.75 4 12" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  const STRINGS = {
    en: {
      pageTitle: 'FlClash – Clash Meta (mihomo) proxy client for Android, Windows, macOS and Linux',
      pageDescription:
        'FlClash is a free, open-source Clash Meta (mihomo) proxy client for Android, Windows, macOS and Linux, with rule routing, TUN mode and subscription import. No ads.',
      skip: 'Skip to downloads',
      navDownload: 'Download',
      navChangelog: 'Changelog',
      langToggle: '中文',
      langLabel: '切换到中文',
      themeLabel: 'Toggle dark mode',
      heroFor: 'for',
      reelLabel: 'Switch platform',
      heroLede: 'A multi-platform proxy client based on Clash Meta (mihomo). Simple to use, open source and ad-free.',
      heroOther: 'Other platforms',
      heroReleaseLoading: 'Latest release',
      heroRelease: (v) => `${v} is out · See what’s new`,
      ctaDownload: (p) => `Download for ${p}`,
      ctaChoose: 'Choose a download',
      ctaIos: 'FlClash does not run on iOS. Pick a build for another device below.',
      previewAlt: 'FlClash dashboard on a MacBook and a phone',
      fact1Title: 'mihomo core',
      fact1: 'Rule routing, proxy groups and TUN mode.',
      fact2Title: 'Subscriptions',
      fact2: 'Import a profile from a subscription link.',
      fact3Title: 'WebDAV sync',
      fact3: 'Back up and restore your data across devices.',
      fact4Title: 'Open source',
      fact4: 'Licensed under GPL-3.0, with no ads.',
      dlTitle: 'Download',
      dlMeta: (v, d) => `Version ${v} · Released ${d}`,
      dlLead: 'The build for this device is already selected. Each file says which devices it is for.',
      dlAll: 'All releases on GitHub',
      dlError: 'Release details could not be loaded. Download from GitHub Releases instead.',
      platformLabel: 'Platform',
      archLabel: 'Architecture',
      recommended: 'Recommended',
      copied: 'Copied',
      copy: 'Copy',
      copySha: (name) => `Copy the SHA-256 of ${name}`,
      hintAndroid: 'Not sure which one? Pick arm64-v8a.',
      hintWindows: 'ARM64 is for Snapdragon and other ARM laptops.',
      hintMacos: 'Apple menu › About This Mac shows your chip.',
      hintLinux: 'Pick the package format your distribution uses.',
      noteAndroidArm64: 'Most phones and tablets from recent years',
      noteAndroidArm32: 'Older 32-bit devices',
      noteAndroidX64: 'Emulators and x86 devices',
      winSetup: 'Installer',
      noteWinSetup: 'Adds a Start menu entry and an uninstaller',
      winPortable: 'Portable',
      noteWinPortable: 'Unzip and run, nothing to install',
      noteMacArm: 'Macs with an M-series chip',
      noteMacIntel: 'Macs with an Intel processor',
      noteDeb: '.deb package for Debian, Ubuntu and their derivatives',
      noteRpm: '.rpm package for Fedora, openSUSE and their derivatives',
      noteAppImage: 'Runs on most distributions without installing',
      tipFdroidTitle: 'F-Droid',
      tipFdroid: 'Add the FlClash repository to your F-Droid client to get updates there.',
      tipFdroidLink: 'Open the F-Droid repository',
      tipIntentTitle: 'Automation',
      tipIntent: 'Other apps can start, stop or toggle the proxy with these intent actions.',
      tipBrewTitle: 'Homebrew',
      tipBrew: 'Install from the terminal, and upgrade with brew later.',
      tipTrayTitle: 'Tray icon',
      tipTray:
        'The .deb package installs its own dependencies. With the AppImage or the .rpm, install the AyatanaAppIndicator library so the tray icon can show.',
      clTitle: 'Changelog',
      clMeta: (n, d) => `${n} releases since ${d}`,
      clSearch: 'Search changes or versions',
      clLatest: 'Latest',
      clMore: (n) => `Show earlier releases (${n} more)`,
      clResults: (e, v) => `${e} ${e === 1 ? 'change' : 'changes'} in ${v} ${v === 1 ? 'release' : 'releases'}`,
      clNone: (q) => `Nothing matches “${q}”.`,
      clClear: 'Clear',
      clEmpty: 'Internal improvements only.',
      clError: 'The changelog could not be loaded.',
      clErrorLink: 'Read CHANGELOG.md on GitHub',
      clOnGithub: 'GitHub',
      clOnGithubLabel: (v) => `Release ${v} on GitHub`,
      typeBreaking: 'Breaking changes',
      typeFeat: 'Features',
      typeFix: 'Fixes',
      typePerf: 'Performance',
      typeRevert: 'Reverts',
      footLicense: 'Free and open source under GPL-3.0.',
      footUpdated: 'This page updates with every release.',
      footReleases: 'Releases',
      footTelegram: 'Telegram channel',
      stars: (n) => `${n} stars on GitHub`,
    },
    zh: {
      pageTitle: 'FlClash – 基于 Clash Meta（mihomo）的多平台代理客户端，支持 Android、Windows、macOS、Linux',
      pageDescription:
        'FlClash 是免费开源的 Clash Meta（mihomo）代理客户端，支持 Android、Windows、macOS 与 Linux，提供规则分流、TUN 模式与订阅导入，没有广告。',
      skip: '跳到下载',
      navDownload: '下载',
      navChangelog: '更新日志',
      langToggle: 'EN',
      langLabel: 'Switch to English',
      themeLabel: '切换深色模式',
      heroFor: '适用于',
      reelLabel: '切换平台',
      heroLede: '基于 Clash Meta（mihomo）内核的多平台代理客户端。简单易用，开源，无广告。',
      heroOther: '其他平台',
      heroReleaseLoading: '最新版本',
      heroRelease: (v) => `${v} 已发布 · 查看更新`,
      ctaDownload: (p) => `下载 ${p} 版`,
      ctaChoose: '选择下载版本',
      ctaIos: 'FlClash 不支持 iOS，可以在下方选择其他设备的版本。',
      previewAlt: 'FlClash 仪表盘在 MacBook 与手机上的界面',
      fact1Title: 'mihomo 内核',
      fact1: '规则分流、代理组与 TUN 模式。',
      fact2Title: '订阅导入',
      fact2: '通过订阅链接导入配置。',
      fact3Title: 'WebDAV 同步',
      fact3: '在设备之间备份与恢复数据。',
      fact4Title: '开源',
      fact4: '以 GPL-3.0 协议开源，没有广告。',
      dlTitle: '下载',
      dlMeta: (v, d) => `版本 ${v} · ${d}发布`,
      dlLead: '已为当前设备选好安装包，每个文件都注明了适用的设备。',
      dlAll: '在 GitHub 查看全部版本',
      dlError: '未能读取版本信息，请前往 GitHub Releases 下载。',
      platformLabel: '平台',
      archLabel: '架构',
      recommended: '推荐',
      copied: '已复制',
      copy: '复制',
      copySha: (name) => `复制 ${name} 的 SHA-256`,
      hintAndroid: '不确定选哪个？选 arm64-v8a。',
      hintWindows: 'ARM64 适用于骁龙等 ARM 架构笔记本。',
      hintMacos: '在苹果菜单 › 关于本机中可以查看芯片类型。',
      hintLinux: '按发行版使用的软件包格式选择。',
      noteAndroidArm64: '近几年的绝大多数手机与平板',
      noteAndroidArm32: '较老的 32 位设备',
      noteAndroidX64: '模拟器与 x86 设备',
      winSetup: '安装版',
      noteWinSetup: '添加开始菜单入口与卸载程序',
      winPortable: '便携版',
      noteWinPortable: '解压即用，无需安装',
      noteMacArm: '搭载 M 系列芯片的 Mac',
      noteMacIntel: '搭载 Intel 处理器的 Mac',
      noteDeb: '.deb 安装包，也适用于其衍生版',
      noteRpm: '.rpm 安装包，也适用于其衍生版',
      noteAppImage: '适用于多数发行版，无需安装',
      tipFdroidTitle: 'F-Droid',
      tipFdroid: '在 F-Droid 客户端中添加 FlClash 仓库，即可在那里接收更新。',
      tipFdroidLink: '打开 F-Droid 仓库',
      tipIntentTitle: '自动化',
      tipIntent: '其他应用可以通过以下 Intent Action 启动、停止或切换代理。',
      tipBrewTitle: 'Homebrew',
      tipBrew: '在终端中安装，之后用 brew 升级。',
      tipTrayTitle: '托盘图标',
      tipTray: '.deb 安装包会自动安装所需依赖。使用 AppImage 或 .rpm 时，需要先安装 AyatanaAppIndicator 库，托盘图标才能显示。',
      clTitle: '更新日志',
      clMeta: (n, d) => `自 ${d}以来共 ${n} 个版本`,
      clSearch: '搜索更新内容或版本',
      clLatest: '最新',
      clMore: (n) => `显示更早的版本（还有 ${n} 个）`,
      clResults: (e, v) => `${v} 个版本中有 ${e} 条匹配`,
      clNone: (q) => `没有与「${q}」相关的更新。`,
      clClear: '清除',
      clEmpty: '仅内部改进。',
      clError: '未能加载更新日志。',
      clErrorLink: '在 GitHub 查看 CHANGELOG.md',
      clOnGithub: 'GitHub',
      clOnGithubLabel: (v) => `在 GitHub 查看 ${v} 发布页`,
      typeBreaking: '不兼容变更',
      typeFeat: '新功能',
      typeFix: '问题修复',
      typePerf: '性能',
      typeRevert: '回退',
      footLicense: '以 GPL-3.0 协议免费开源。',
      footUpdated: '本页随每次发布自动更新。',
      footReleases: '发布页',
      footTelegram: 'Telegram 频道',
      stars: (n) => `GitHub 上有 ${n} 个星标`,
    },
  };

  function parseChangelog(markdown) {
    const versions = [];
    let version = null;
    let group = null;
    let entry = null;
    for (const raw of markdown.split(/\r?\n/)) {
      const line = raw.trimEnd();
      let match = line.match(/^## (v?\d[^\s(]*)(?: \((\d{4}-\d{2}-\d{2})\))?$/);
      if (match) {
        version = { tag: match[1], version: match[1].replace(/^v/, ''), date: match[2] || '', groups: [], empty: false };
        versions.push(version);
        group = null;
        entry = null;
        continue;
      }
      if (!version) continue;
      match = line.match(/^\*\*(.+)\*\*$/);
      if (match) {
        group = { type: TYPE_BY_TITLE[match[1]] || 'other', title: match[1], entries: [] };
        version.groups.push(group);
        entry = null;
        continue;
      }
      match = line.match(/^[-*] (.+)$/);
      if (match) {
        if (!group) {
          group = { type: null, title: '', entries: [] };
          version.groups.push(group);
        }
        entry = parseEntry(match[1]);
        group.entries.push(entry);
        continue;
      }
      if (entry && /^\s+\S/.test(raw)) {
        entry.text += ` ${raw.trim()}`;
        continue;
      }
      if (line === 'Internal improvements only.') version.empty = true;
    }
    return versions;
  }

  function parseEntry(source) {
    let text = source;
    let scope = null;
    let id = null;
    const scoped = text.match(/^\*\*([^*]+)\*\* (.+)$/);
    if (scoped) {
      scope = scoped[1];
      text = scoped[2];
    }
    const hashed = text.match(/^(.*) \(([0-9a-f]{7,40})\)$/);
    if (hashed) {
      text = hashed[1];
      id = hashed[2];
    }
    return { scope, text, id };
  }

  function translate(lang, key, ...args) {
    const value = STRINGS[lang][key] ?? STRINGS.en[key] ?? key;
    return typeof value === 'function' ? value(...args) : value;
  }

  function formatDate(iso, lang) {
    if (!iso) return '';
    return new Intl.DateTimeFormat(lang === 'zh' ? 'zh-CN' : 'en', {
      year: 'numeric',
      month: lang === 'zh' ? 'long' : 'short',
      day: 'numeric',
      timeZone: 'UTC',
    }).format(new Date(`${iso}T00:00:00Z`));
  }

  function changelogMeta(versions, lang) {
    const oldest = versions.filter((version) => version.date).pop();
    return oldest ? translate(lang, 'clMeta', versions.length, formatDate(oldest.date, lang)) : '';
  }

  function escapeHtml(text) {
    return String(text).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[c]);
  }

  function highlight(text, query) {
    if (!query) return escapeHtml(text);
    const lower = text.toLowerCase();
    let html = '';
    let from = 0;
    for (let at = lower.indexOf(query); at !== -1; at = lower.indexOf(query, from)) {
      html += `${escapeHtml(text.slice(from, at))}<mark>${escapeHtml(text.slice(at, at + query.length))}</mark>`;
      from = at + query.length;
    }
    return html + escapeHtml(text.slice(from));
  }

  function releaseHtml(version, groups, { lang, query, isLatest, ago }) {
    const t = (key, ...args) => translate(lang, key, ...args);
    const tag = escapeHtml(version.tag);
    let row = 0;
    const order = () => ` style="--i:${Math.min(row++, MAX_STAGGER)}"`;
    const sections = groups.map((group) => {
      const title = group.type ? (TYPE_KEYS[group.type] ? t(TYPE_KEYS[group.type]) : group.title) : '';
      const heading = title
        ? `<h3 class="group-title"${order()}><span class="mark" aria-hidden="true"></span>${escapeHtml(title)}</h3>`
        : '';
      const entries = group.entries.map((entry) => {
        const scope = entry.scope ? `<span class="scope">${highlight(entry.scope, query)}</span>` : '';
        const hash = entry.id ? `<a class="hash" href="${REPO}/commit/${entry.id}">${entry.id.slice(0, 7)}</a>` : '';
        return `<li class="entry"${order()}><span class="entry-text">${scope}${highlight(entry.text, query)}</span>${hash}</li>`;
      });
      return (
        `<section class="${group.type ? 'group' : 'group plain'}" data-type="${escapeHtml(group.type || 'plain')}">` +
        `${heading}<ul class="entries">${entries.join('')}</ul></section>`
      );
    });
    const empty = version.empty && !groups.length ? `<p class="empty">${escapeHtml(t('clEmpty'))}</p>` : '';
    const title = ago ? ` title="${escapeHtml(ago(version.date))}"` : '';
    const date = version.date
      ? `<span class="when"><time datetime="${version.date}"${title}>${formatDate(version.date, lang)}</time></span>`
      : '';
    return (
      `<article class="release" id="${tag}"><header class="release-head"><div class="ver-row">` +
      `<a class="ver" href="#${tag}">${highlight(version.version, query)}</a>` +
      (isLatest ? `<span class="latest">${escapeHtml(t('clLatest'))}</span>` : '') +
      `</div>${date}<span class="when"><a href="${REPO}/releases/tag/${tag}" ` +
      `aria-label="${escapeHtml(t('clOnGithubLabel', version.tag))}">${escapeHtml(t('clOnGithub'))} ${ICON_EXTERNAL}</a>` +
      `</span></header><div class="release-body">${empty}${sections.join('')}</div></article>`
    );
  }

  function timelineHtml(items, { lang, query = '', latestTag, ago, year = null }) {
    let html = '';
    for (const { version, groups } of items) {
      const releaseYear = version.date.slice(0, 4);
      if (releaseYear && releaseYear !== year) {
        html += `<div class="year">${releaseYear}</div>`;
        year = releaseYear;
      }
      html += releaseHtml(version, groups, { lang, query, isLatest: version.tag === latestTag, ago });
    }
    return { html, year };
  }

  return { REPO, FIRST_PAGE, STRINGS, parseChangelog, translate, formatDate, changelogMeta, escapeHtml, timelineHtml };
})();
