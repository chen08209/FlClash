(() => {
  'use strict';

  const REPO = 'https://github.com/chen08209/FlClash';
  const PLATFORMS = ['android', 'windows', 'macos', 'linux'];
  const PLATFORM_NAMES = { android: 'Android', windows: 'Windows', macos: 'macOS', linux: 'Linux' };
  const TYPE_BY_TITLE = {
    'Breaking Changes': 'breaking',
    Features: 'feat',
    'Bug Fixes': 'fix',
    Performance: 'perf',
    Reverts: 'revert',
  };
  const FIRST_PAGE = 6;
  const PAGE = 15;

  const STRINGS = {
    en: {
      skip: 'Skip to downloads',
      navDownload: 'Download',
      navChangelog: 'Changelog',
      langToggle: '中文',
      langLabel: '切换到中文',
      themeLabel: 'Toggle dark mode',
      heroFor: 'for',
      reelLabel: 'Switch platform',
      heroLede: 'A multi-platform proxy client based on ClashMeta. Simple to use, open source and ad-free.',
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
      skip: '跳到下载',
      navDownload: '下载',
      navChangelog: '更新日志',
      langToggle: 'EN',
      langLabel: 'Switch to English',
      themeLabel: '切换深色模式',
      heroFor: '适用于',
      reelLabel: '切换平台',
      heroLede: '基于 ClashMeta 的多平台代理客户端。简单易用，开源，无广告。',
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

  const root = document.documentElement;
  const $ = (selector, scope = document) => scope.querySelector(selector);
  const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
  const springEasing = CSS.supports('transition-timing-function', 'linear(0, 1)')
    ? getComputedStyle(root).getPropertyValue('--spring').trim()
    : 'cubic-bezier(0.22, 1, 0.36, 1)';

  const state = {
    lang: root.lang.startsWith('zh') ? 'zh' : 'en',
    platform: 'android',
    arch: 'x64',
    detected: { platform: null, arch: 'x64', ios: false },
    platformChosen: false,
    release: null,
    releaseFailed: false,
    versions: [],
    changelogFailed: false,
    shown: FIRST_PAGE,
    query: '',
  };

  function t(key, ...args) {
    const value = STRINGS[state.lang][key] ?? STRINGS.en[key] ?? key;
    return typeof value === 'function' ? value(...args) : value;
  }

  function el(tag, props, ...children) {
    const node = document.createElement(tag);
    if (props) {
      for (const [key, value] of Object.entries(props)) {
        if (value == null || value === false) continue;
        if (key === 'class') node.className = value;
        else if (key === 'text') node.textContent = value;
        else if (key === 'dataset') Object.assign(node.dataset, value);
        else if (key.startsWith('on')) node.addEventListener(key.slice(2), value);
        else node.setAttribute(key, value === true ? '' : value);
      }
    }
    for (const child of children.flat()) {
      if (child == null || child === false) continue;
      node.append(child);
    }
    return node;
  }

  function svg(markup) {
    const template = document.createElement('template');
    template.innerHTML = markup.trim();
    return template.content.firstChild;
  }

  const ICON_DOWN =
    '<svg viewBox="0 0 20 20" width="18" height="18" aria-hidden="true"><path d="M10 3.5v11m0 0-4.5-4.5m4.5 4.5 4.5-4.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>';
  const ICON_COPY =
    '<svg class="ico-copy" viewBox="0 0 20 20" width="16" height="16" aria-hidden="true"><rect x="6.75" y="6.75" width="9.5" height="9.5" rx="2.25" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M13.25 4.75v-.5a1.5 1.5 0 0 0-1.5-1.5h-6.5a2.5 2.5 0 0 0-2.5 2.5v6.5a1.5 1.5 0 0 0 1.5 1.5h.5" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>';
  const ICON_CHECK =
    '<svg class="ico-check" viewBox="0 0 20 20" width="16" height="16" aria-hidden="true"><path d="m4.5 10.5 3.5 3.5 7.5-8" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>';
  const ICON_EXTERNAL =
    '<svg viewBox="0 0 16 16" width="12" height="12" aria-hidden="true"><path d="M6 3.5h6.5V10M12.25 3.75 4 12" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  const FOCUS_IN = [
    { opacity: 0, transform: 'translateY(10px)', filter: 'blur(6px)' },
    { opacity: 1, transform: 'none', filter: 'blur(0px)' },
  ];

  function animate(node, keyframes, options) {
    if (reducedMotion.matches || !node.animate) return null;
    return node.animate(keyframes, options);
  }

  function locale() {
    return state.lang === 'zh' ? 'zh-CN' : 'en';
  }

  function formatDate(iso) {
    if (!iso) return '';
    const date = new Date(`${iso}T00:00:00Z`);
    return new Intl.DateTimeFormat(locale(), {
      year: 'numeric',
      month: state.lang === 'zh' ? 'long' : 'short',
      day: 'numeric',
      timeZone: 'UTC',
    }).format(date);
  }

  function formatAgo(iso) {
    if (!iso) return '';
    const days = Math.round((Date.now() - Date.parse(`${iso}T00:00:00Z`)) / 86400000);
    const rtf = new Intl.RelativeTimeFormat(locale(), { numeric: 'auto' });
    if (days < 7) return rtf.format(-Math.max(days, 0), 'day');
    if (days < 30) return rtf.format(-Math.round(days / 7), 'week');
    if (days < 365) return rtf.format(-Math.round(days / 30.4), 'month');
    return rtf.format(-Math.round(days / 365), 'year');
  }

  function formatSize(bytes) {
    return `${(bytes / 1048576).toFixed(1)} MB`;
  }

  function goArch(arch) {
    return arch === 'arm64' ? 'arm64' : 'amd64';
  }

  function buildsFor(platform, arch) {
    switch (platform) {
      case 'android':
        return [
          { id: 'android-arm64-v8a.apk', kind: 'APK', title: 'arm64-v8a', note: 'noteAndroidArm64', rec: true },
          { id: 'android-armeabi-v7a.apk', kind: 'APK', title: 'armeabi-v7a', note: 'noteAndroidArm32' },
          { id: 'android-x86_64.apk', kind: 'APK', title: 'x86_64', note: 'noteAndroidX64' },
        ];
      case 'windows':
        return [
          { id: `windows-${goArch(arch)}-setup.exe`, kind: 'EXE', titleKey: 'winSetup', note: 'noteWinSetup', rec: true },
          { id: `windows-${goArch(arch)}.zip`, kind: 'ZIP', titleKey: 'winPortable', note: 'noteWinPortable' },
        ];
      case 'macos':
        return [
          { id: 'macos-arm64.dmg', kind: 'DMG', title: 'Apple Silicon', note: 'noteMacArm', rec: arch === 'arm64' },
          { id: 'macos-amd64.dmg', kind: 'DMG', title: 'Intel', note: 'noteMacIntel', rec: arch !== 'arm64' },
        ];
      case 'linux':
        return [
          { id: `linux-${goArch(arch)}.deb`, kind: 'DEB', title: 'Debian / Ubuntu', short: '.deb', note: 'noteDeb', rec: true },
          { id: `linux-${goArch(arch)}.rpm`, kind: 'RPM', title: 'Fedora / openSUSE', short: '.rpm', note: 'noteRpm' },
          { id: `linux-${goArch(arch)}.AppImage`, kind: 'APPIMAGE', title: 'AppImage', note: 'noteAppImage' },
        ];
      default:
        return [];
    }
  }

  function resolveBuilds(platform, arch) {
    const release = state.release;
    if (!release) return [];
    return buildsFor(platform, arch)
      .map((build) => {
        const name = `FlClash-${release.version}-${build.id}`;
        const asset = release.assets ? release.assets.get(name) : null;
        if (release.assets && !asset) return null;
        return {
          ...build,
          name,
          title: build.titleKey ? t(build.titleKey) : build.title,
          href: `${REPO}/releases/download/${release.tag}/${name}`,
          size: asset ? asset.size : null,
          digest: asset && asset.digest ? asset.digest.replace(/^sha256:/, '') : null,
        };
      })
      .filter(Boolean);
  }

  async function detectDevice() {
    const ua = navigator.userAgent;
    const result = { platform: null, arch: null, ios: false };
    if (/android/i.test(ua)) result.platform = 'android';
    else if (/iphone|ipad|ipod/i.test(ua) || (/macintosh/i.test(ua) && navigator.maxTouchPoints > 1)) result.ios = true;
    else if (/windows/i.test(ua)) result.platform = 'windows';
    else if (/macintosh|mac os x/i.test(ua)) result.platform = 'macos';
    else if (/linux|x11|cros/i.test(ua)) result.platform = 'linux';
    if (/aarch64|arm64/i.test(ua)) result.arch = 'arm64';
    try {
      const hints = await navigator.userAgentData?.getHighEntropyValues(['architecture']);
      if (hints?.architecture === 'arm') result.arch = 'arm64';
      else if (hints?.architecture === 'x86') result.arch = 'x64';
    } catch {}
    if (result.platform === 'macos' && !result.arch) result.arch = guessMacArch();
    if (!result.arch) result.arch = result.platform === 'macos' ? 'arm64' : 'x64';
    return result;
  }

  function guessMacArch() {
    try {
      const gl = document.createElement('canvas').getContext('webgl');
      const info = gl && gl.getExtension('WEBGL_debug_renderer_info');
      const renderer = info ? gl.getParameter(info.UNMASKED_RENDERER_WEBGL) : '';
      if (/intel|amd|radeon|nvidia/i.test(renderer)) return 'x64';
    } catch {}
    return 'arm64';
  }

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

  async function loadData() {
    const [markdown, release] = await Promise.allSettled([
      fetch('CHANGELOG.md', { cache: 'no-cache' }).then((r) => (r.ok ? r.text() : Promise.reject(r.status))),
      fetch('release.json', { cache: 'no-cache' }).then((r) => (r.ok ? r.json() : null)),
    ]);

    if (markdown.status === 'fulfilled') state.versions = parseChangelog(markdown.value);
    else state.changelogFailed = true;

    const meta = release.status === 'fulfilled' ? release.value : null;
    if (meta && meta.tag) {
      state.release = {
        tag: meta.tag,
        version: meta.tag.replace(/^v/, ''),
        date: (meta.publishedAt || '').slice(0, 10),
        assets: new Map((meta.assets || []).map((asset) => [asset.name, asset])),
        stars: meta.stars,
      };
    } else {
      const stable = state.versions.find((v) => !v.tag.includes('-'));
      if (stable) {
        state.release = { tag: stable.tag, version: stable.version, date: stable.date, assets: null, stars: null };
      } else {
        state.releaseFailed = true;
      }
    }
  }

  function applyStaticText() {
    root.lang = state.lang === 'zh' ? 'zh-CN' : 'en';
    for (const node of document.querySelectorAll('[data-i18n]')) node.textContent = t(node.dataset.i18n);
    for (const node of document.querySelectorAll('[data-i18n-alt]')) node.alt = t(node.dataset.i18nAlt);
    for (const node of document.querySelectorAll('[data-i18n-placeholder]')) {
      node.placeholder = t(node.dataset.i18nPlaceholder);
    }
    const langToggle = $('#lang-toggle');
    langToggle.textContent = t('langToggle');
    langToggle.setAttribute('aria-label', t('langLabel'));
    langToggle.lang = state.lang === 'zh' ? 'en' : 'zh-CN';
    $('#theme-toggle').setAttribute('aria-label', t('themeLabel'));
    $('#reel').setAttribute('aria-label', `${t('reelLabel')}: ${PLATFORM_NAMES[state.platform]}`);
    $('#platform-seg').setAttribute('aria-label', t('platformLabel'));
    $('#arch-seg').setAttribute('aria-label', t('archLabel'));
  }

  function renderReleaseMeta() {
    const release = state.release;
    const heroText = $('#hero-release-text');
    if (release) {
      heroText.textContent = t('heroRelease', release.tag);
      $('#hero-release').href = `#${release.tag}`;
      $('#dl-meta').textContent = t('dlMeta', release.version, formatDate(release.date));
      $('#sums-link').href = `${REPO}/releases/download/${release.tag}/SHA256SUMS`;
      $('#sums-link').hidden = !release.assets || !release.assets.has('SHA256SUMS');
    } else {
      heroText.textContent = t('heroReleaseLoading');
    }
    const stars = $('#stars');
    if (release && typeof release.stars === 'number') {
      const compact = new Intl.NumberFormat(locale(), { notation: 'compact', maximumFractionDigits: 1 }).format(
        release.stars,
      );
      stars.textContent = compact;
      stars.hidden = false;
      $('#gh-link').setAttribute('aria-label', `GitHub, ${t('stars', compact)}`);
    }
  }

  function renderCta() {
    const cta = $('#cta');
    const title = $('#cta-title');
    const sub = $('#cta-sub');
    const note = $('#cta-note');
    note.hidden = !state.detected.ios;
    note.textContent = state.detected.ios ? t('ctaIos') : '';
    const builds = state.detected.ios && !state.platformChosen ? [] : resolveBuilds(state.platform, state.arch);
    const pick = builds.find((b) => b.rec) || builds[0];
    if (!pick) {
      title.textContent = t('ctaChoose');
      sub.hidden = true;
      cta.href = '#download';
      return;
    }
    title.textContent = t('ctaDownload', PLATFORM_NAMES[state.platform]);
    const parts = [pick.short || pick.title];
    if (state.platform === 'windows' || state.platform === 'linux') parts.unshift(state.arch === 'arm64' ? 'ARM64' : 'x64');
    if (pick.size) parts.push(formatSize(pick.size));
    sub.textContent = parts.join(' · ');
    sub.hidden = false;
    cta.href = pick.href;
  }

  function moveInk(seg, withMotion) {
    const ink = $('.seg-ink', seg);
    const active = $('[aria-selected="true"]', seg);
    if (!ink || !active) return;
    if (!withMotion) ink.style.transition = 'none';
    ink.style.width = `${active.offsetWidth}px`;
    ink.style.transform = `translateX(${active.offsetLeft}px)`;
    if (!withMotion) {
      void ink.offsetWidth;
      ink.style.transition = '';
    }
  }

  function selectTab(seg, value, withMotion) {
    for (const button of seg.querySelectorAll('[role="tab"]')) {
      const selected = button.dataset.value === value;
      button.setAttribute('aria-selected', String(selected));
      button.tabIndex = selected ? 0 : -1;
    }
    moveInk(seg, withMotion);
  }

  function wireTabs(seg, onSelect) {
    seg.addEventListener('click', (event) => {
      const button = event.target.closest('[role="tab"]');
      if (button) onSelect(button.dataset.value);
    });
    seg.addEventListener('keydown', (event) => {
      if (!['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) return;
      const tabs = [...seg.querySelectorAll('[role="tab"]')];
      const index = tabs.indexOf(document.activeElement);
      if (index < 0) return;
      event.preventDefault();
      let next = index;
      if (event.key === 'ArrowLeft') next = (index - 1 + tabs.length) % tabs.length;
      if (event.key === 'ArrowRight') next = (index + 1) % tabs.length;
      if (event.key === 'Home') next = 0;
      if (event.key === 'End') next = tabs.length - 1;
      tabs[next].focus();
      onSelect(tabs[next].dataset.value);
    });
  }

  function fileRow(build) {
    const sha = build.digest
      ? el('button', {
          class: 'sha',
          type: 'button',
          text: 'SHA-256',
          title: build.digest,
          'aria-label': t('copySha', build.name),
          onclick: (event) => copyText(build.digest, event.currentTarget),
        })
      : null;
    return el(
      'li',
      { class: build.rec ? 'file rec' : 'file' },
      el('span', { class: build.kind.length > 4 ? 'kind long' : 'kind', 'aria-hidden': 'true', text: build.kind }),
      el(
        'div',
        { class: 'file-main' },
        el('a', { class: 'file-title', href: build.href, title: build.name, text: build.title }),
        build.rec ? el('span', { class: 'rec-tag', text: t('recommended') }) : null,
        el('p', { class: 'note', text: t(build.note) }),
      ),
      el('div', { class: 'meta' }, build.size ? el('span', { text: formatSize(build.size) }) : null, sha),
      el('span', { class: 'go', 'aria-hidden': 'true' }, svg(ICON_DOWN)),
    );
  }

  function commandBlock(text) {
    return el(
      'div',
      { class: 'cmd' },
      el('pre', {}, el('code', { text })),
      el(
        'button',
        {
          class: 'copy',
          type: 'button',
          'aria-label': t('copy'),
          onclick: (event) => copyText(text, event.currentTarget),
        },
        svg(ICON_COPY),
        svg(ICON_CHECK),
      ),
    );
  }

  function tip(titleKey, textKey, ...extra) {
    return el('div', { class: 'tip' }, el('h3', { text: t(titleKey) }), el('p', { text: t(textKey) }), ...extra);
  }

  function extrasFor(platform) {
    switch (platform) {
      case 'android':
        return [
          tip(
            'tipFdroidTitle',
            'tipFdroid',
            el(
              'p',
              {},
              el('a', {
                href: 'https://chen08209.github.io/FlClash-fdroid-repo/repo?fingerprint=789D6D32668712EF7672F9E58DEEB15FBD6DCEEC5AE7A4371EA72F2AAE8A12FD',
                text: t('tipFdroidLink'),
              }),
            ),
          ),
          tip(
            'tipIntentTitle',
            'tipIntent',
            commandBlock(
              ['com.follow.clash.action.START', 'com.follow.clash.action.STOP', 'com.follow.clash.action.TOGGLE'].join(
                '\n',
              ),
            ),
          ),
        ];
      case 'macos':
        return [tip('tipBrewTitle', 'tipBrew', commandBlock('brew tap chen08209/tap\nbrew install --cask flclash'))];
      case 'linux':
        return [
          tip(
            'tipTrayTitle',
            'tipTray',
            commandBlock('sudo apt-get install libayatana-appindicator3-1   # Debian, Ubuntu'),
            commandBlock('sudo dnf install libayatana-appindicator-gtk3     # Fedora'),
          ),
        ];
      default:
        return [];
    }
  }

  function renderPanel(withMotion) {
    const panel = $('#panel');
    const startHeight = panel.offsetHeight;
    const hints = { android: 'hintAndroid', windows: 'hintWindows', macos: 'hintMacos', linux: 'hintLinux' };
    $('#panel-hint').textContent = t(hints[state.platform]);
    panel.setAttribute('aria-labelledby', `tab-${state.platform}`);

    const archSeg = $('#arch-seg');
    const archWasHidden = archSeg.hidden;
    archSeg.hidden = !(state.platform === 'windows' || state.platform === 'linux');
    if (!archSeg.hidden) selectTab(archSeg, state.arch, withMotion && !archWasHidden);

    const files = $('#files');
    const builds = resolveBuilds(state.platform, state.arch);
    files.replaceChildren(...builds.map(fileRow));
    $('#dl-error').hidden = !state.releaseFailed;
    $('#dl-error').textContent = state.releaseFailed ? t('dlError') : '';
    $('#extras').replaceChildren(...extrasFor(state.platform));

    if (!withMotion) return;
    const endHeight = panel.offsetHeight;
    if (startHeight && startHeight !== endHeight) {
      panel.style.overflow = 'clip';
      const resize = animate(panel, [{ height: `${startHeight}px` }, { height: `${endHeight}px` }], {
        duration: 520,
        easing: springEasing,
      });
      if (resize) resize.onfinish = resize.oncancel = () => (panel.style.overflow = '');
      else panel.style.overflow = '';
    }
    [...files.children, ...$('#extras').children].forEach((node, index) => {
      animate(node, FOCUS_IN, {
        duration: 560,
        delay: 35 * index,
        easing: 'cubic-bezier(0.22, 1, 0.36, 1)',
        fill: 'backwards',
      });
    });
  }

  const reel = {
    index: 0,
    build() {
      const words = [];
      for (let cycle = 0; cycle < 3; cycle++) {
        for (const platform of PLATFORMS) words.push(el('span', { text: PLATFORM_NAMES[platform] }));
      }
      $('#reel-track').replaceChildren(...words);
      this.apply(0);
    },
    apply(duration) {
      const button = $('#reel');
      const track = $('#reel-track');
      const motion = duration > 0 && !reducedMotion.matches;
      track.style.transition = motion ? `transform ${duration}ms ${springEasing}` : 'none';
      button.style.transition = motion ? `width ${duration}ms ${springEasing}` : 'none';
      track.style.transform = `translateY(${-this.index * 1.12}em)`;
      button.style.width = `${track.children[this.index].getBoundingClientRect().width}px`;
      $('#reel-current').textContent = PLATFORM_NAMES[PLATFORMS[this.index % PLATFORMS.length]];
      if (!motion) {
        void track.offsetWidth;
        return;
      }
      const blur = (parseFloat(getComputedStyle(track).fontSize) * (duration > 1000 ? 0.06 : 0.035)).toFixed(1);
      animate(
        track,
        [{ filter: 'blur(0px)' }, { filter: `blur(${blur}px)`, offset: 0.3 }, { filter: 'blur(0px)' }],
        { duration: duration * 0.7, easing: 'ease-in-out' },
      );
    },
    roll(platform, { full = false } = {}) {
      const n = PLATFORMS.length;
      let steps = (PLATFORMS.indexOf(platform) - (this.index % n) + n) % n;
      if (full) steps += n;
      if (!steps) return;
      if (this.index + steps >= n * 3) {
        this.index -= n;
        this.apply(0);
      }
      this.index += steps;
      this.apply(full ? 1500 : 700);
      if (reducedMotion.matches) this.settle();
    },
    settle() {
      const n = PLATFORMS.length;
      if (this.index >= n && this.index < 2 * n) return;
      this.index = n + (this.index % n);
      this.apply(0);
    },
    refit() {
      const button = $('#reel');
      button.style.transition = 'none';
      button.style.width = `${$('#reel-track').children[this.index].getBoundingClientRect().width}px`;
    },
  };

  function setPlatform(platform, { from } = {}) {
    if (!PLATFORM_NAMES[platform]) return;
    const changed = platform !== state.platform;
    state.platform = platform;
    state.platformChosen = true;
    if (platform === 'macos' || platform === 'windows' || platform === 'linux') {
      state.arch = state.detected.platform === platform ? state.detected.arch : platform === 'macos' ? 'arm64' : 'x64';
    }
    selectTab($('#platform-seg'), platform, true);
    if (from !== 'reel' && changed) reel.roll(platform);
    $('#reel').setAttribute('aria-label', `${t('reelLabel')}: ${PLATFORM_NAMES[platform]}`);
    renderCta();
    renderPanel(changed);
  }

  function setArch(arch) {
    if (arch === state.arch) return;
    state.arch = arch;
    renderCta();
    renderPanel(true);
  }

  function highlight(text, query) {
    if (!query) return [text];
    const parts = [];
    const lower = text.toLowerCase();
    let from = 0;
    let at = lower.indexOf(query, from);
    while (at !== -1) {
      if (at > from) parts.push(text.slice(from, at));
      parts.push(el('mark', { text: text.slice(at, at + query.length) }));
      from = at + query.length;
      at = lower.indexOf(query, from);
    }
    if (from < text.length) parts.push(text.slice(from));
    return parts;
  }

  function typeTitle(type) {
    const keys = { breaking: 'typeBreaking', feat: 'typeFeat', fix: 'typeFix', perf: 'typePerf', revert: 'typeRevert' };
    return keys[type] ? t(keys[type]) : '';
  }

  function releaseNode(version, groups, query, isLatest) {
    const body = el('div', { class: 'release-body' });
    if (version.empty && !groups.length) body.append(el('p', { class: 'empty', text: t('clEmpty') }));
    for (const group of groups) {
      const title = group.type ? typeTitle(group.type) || group.title : '';
      body.append(
        el(
          'section',
          { class: group.type ? 'group' : 'group plain', dataset: { type: group.type || 'plain' } },
          title ? el('h3', { class: 'group-title' }, el('span', { class: 'mark', 'aria-hidden': 'true' }), title) : null,
          el(
            'ul',
            { class: 'entries' },
            group.entries.map((entry) =>
              el(
                'li',
                { class: 'entry' },
                el(
                  'span',
                  { class: 'entry-text' },
                  entry.scope ? el('span', { class: 'scope' }, highlight(entry.scope, query)) : null,
                  highlight(entry.text, query),
                ),
                entry.id
                  ? el('a', { class: 'hash', href: `${REPO}/commit/${entry.id}`, text: entry.id.slice(0, 7) })
                  : null,
              ),
            ),
          ),
        ),
      );
    }
    const head = el(
      'header',
      { class: 'release-head' },
      el(
        'div',
        { class: 'ver-row' },
        el('a', { class: 'ver', href: `#${version.tag}` }, highlight(version.version, query)),
        isLatest ? el('span', { class: 'latest', text: t('clLatest') }) : null,
      ),
      version.date
        ? el(
            'span',
            { class: 'when' },
            el('time', { datetime: version.date, title: formatAgo(version.date), text: formatDate(version.date) }),
          )
        : null,
      el(
        'span',
        { class: 'when' },
        el(
          'a',
          { href: `${REPO}/releases/tag/${version.tag}`, 'aria-label': t('clOnGithubLabel', version.tag) },
          t('clOnGithub'),
          ' ',
          svg(ICON_EXTERNAL),
        ),
      ),
    );
    return el('article', { class: 'release', id: version.tag }, head, body);
  }

  function matchVersion(version, query) {
    if (version.version.includes(query) || version.tag.toLowerCase().includes(query)) {
      return version.groups;
    }
    return version.groups
      .map((group) => ({
        ...group,
        entries: group.entries.filter(
          (entry) =>
            entry.text.toLowerCase().includes(query) ||
            (entry.scope && entry.scope.toLowerCase().includes(query)) ||
            (entry.id && entry.id.startsWith(query)),
        ),
      }))
      .filter((group) => group.entries.length);
  }

  let lastYear = null;

  function appendReleases(container, items, query, animateFrom) {
    const latestTag = state.versions[0] && state.versions[0].tag;
    items.forEach(({ version, groups }, index) => {
      const year = version.date.slice(0, 4);
      if (year && year !== lastYear) {
        container.append(el('div', { class: 'year', text: year }));
        lastYear = year;
      }
      const node = releaseNode(version, groups, query, version.tag === latestTag);
      container.append(node);
      if (animateFrom != null && index < 10) {
        animate(node, FOCUS_IN, {
          duration: 600,
          delay: 45 * index,
          easing: 'cubic-bezier(0.22, 1, 0.36, 1)',
          fill: 'backwards',
        });
      }
    });
  }

  function renderTimeline() {
    const timeline = $('#timeline');
    const status = $('#cl-status');
    const more = $('#cl-more');
    timeline.replaceChildren();
    lastYear = null;

    if (state.changelogFailed) {
      status.replaceChildren(
        t('clError'),
        ' ',
        el('a', { href: `${REPO}/blob/main/CHANGELOG.md`, text: t('clErrorLink') }),
      );
      more.hidden = true;
      return;
    }

    const versions = state.versions;
    const first = versions[versions.length - 1];
    $('#cl-meta').textContent = first ? t('clMeta', versions.length, formatDate(first.date)) : '';

    const query = state.query.trim().toLowerCase();
    if (!query) {
      status.replaceChildren();
      appendReleases(
        timeline,
        versions.slice(0, state.shown).map((version) => ({ version, groups: version.groups })),
        '',
      );
      updateMore();
      return;
    }

    const matches = versions
      .map((version) => ({ version, groups: matchVersion(version, query) }))
      .filter(({ version, groups }) => groups.length || version.version.includes(query));
    const entryCount = matches.reduce(
      (sum, { groups }) => sum + groups.reduce((n, group) => n + group.entries.length, 0),
      0,
    );
    const clear = el('button', {
      type: 'button',
      text: t('clClear'),
      onclick: () => {
        $('#cl-search').value = '';
        state.query = '';
        renderTimeline();
        $('#cl-search').focus();
      },
    });
    if (matches.length) {
      status.replaceChildren(t('clResults', entryCount, matches.length), ' · ', clear);
    } else {
      status.replaceChildren(t('clNone', state.query.trim()), ' ', clear);
    }
    appendReleases(timeline, matches, query);
    more.hidden = true;
  }

  function updateMore() {
    const more = $('#cl-more');
    const remaining = state.versions.length - state.shown;
    more.hidden = remaining <= 0 || Boolean(state.query.trim());
    more.textContent = remaining > 0 ? t('clMore', remaining) : '';
  }

  function showMore() {
    const from = state.shown;
    state.shown = Math.min(state.versions.length, state.shown + PAGE);
    appendReleases(
      $('#timeline'),
      state.versions.slice(from, state.shown).map((version) => ({ version, groups: version.groups })),
      '',
      from,
    );
    updateMore();
  }

  function revealHash() {
    let tag;
    try {
      tag = decodeURIComponent(location.hash.slice(1));
    } catch {
      return;
    }
    const index = state.versions.findIndex((v) => v.tag === tag);
    if (index < 0) return;
    if (index >= state.shown) {
      state.shown = Math.min(state.versions.length, Math.ceil((index + 1) / PAGE) * PAGE);
      renderTimeline();
    }
    requestAnimationFrame(() => document.getElementById(tag)?.scrollIntoView());
  }

  async function copyText(text, button) {
    let ok = false;
    try {
      await navigator.clipboard.writeText(text);
      ok = true;
    } catch {
      const area = el('textarea', { readonly: true, style: 'position:fixed;opacity:0' });
      area.value = text;
      document.body.append(area);
      area.select();
      try {
        ok = document.execCommand('copy');
      } catch {}
      area.remove();
    }
    if (!ok) return;
    button.classList.add('done');
    const label = button.classList.contains('sha') ? button.textContent : null;
    if (label) button.textContent = t('copied');
    clearTimeout(button._reset);
    button._reset = setTimeout(() => {
      button.classList.remove('done');
      if (label) button.textContent = label;
    }, 1600);
  }

  function effectiveTheme() {
    if (root.dataset.theme) return root.dataset.theme;
    return matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  function syncShot() {
    const theme = root.dataset.theme;
    $('#shot-dark').media = theme ? (theme === 'dark' ? 'all' : 'not all') : '(prefers-color-scheme: dark)';
  }

  function toggleTheme(event) {
    const next = effectiveTheme() === 'dark' ? 'light' : 'dark';
    const apply = () => {
      root.dataset.theme = next;
      syncShot();
      try {
        localStorage.setItem('flclash.theme', next);
      } catch {}
    };
    if (!document.startViewTransition || reducedMotion.matches) {
      apply();
      return;
    }
    const rect = event.currentTarget.getBoundingClientRect();
    const x = rect.left + rect.width / 2;
    const y = rect.top + rect.height / 2;
    const radius = Math.hypot(Math.max(x, innerWidth - x), Math.max(y, innerHeight - y));
    const transition = document.startViewTransition(apply);
    transition.ready
      .then(() => {
        root.animate(
          { clipPath: [`circle(0px at ${x}px ${y}px)`, `circle(${radius}px at ${x}px ${y}px)`] },
          { duration: 560, easing: 'cubic-bezier(0.22, 1, 0.36, 1)', pseudoElement: '::view-transition-new(root)' },
        );
        root.animate(
          { filter: ['blur(0px)', 'blur(6px)'] },
          { duration: 560, easing: 'ease-in', pseudoElement: '::view-transition-old(root)' },
        );
      })
      .catch(() => {});
  }

  function setLang(next) {
    state.lang = next;
    try {
      localStorage.setItem('flclash.lang', next);
    } catch {}
    applyStaticText();
    renderReleaseMeta();
    renderCta();
    renderPanel(false);
    renderTimeline();
    reel.refit();
    moveInk($('#platform-seg'), false);
  }

  function wireGlyph() {
    const glyph = $('.brand .glyph');
    const last = $('.sig-3', glyph);
    glyph.addEventListener('animationend', (event) => {
      if (event.target === last) glyph.classList.remove('enter', 'wave');
    });
    $('.brand').addEventListener('mouseenter', () => {
      if (!glyph.classList.contains('enter')) glyph.classList.add('wave');
    });
    glyph.classList.add('enter');
  }

  function wireEvents() {
    wireTabs($('#platform-seg'), (value) => setPlatform(value));
    wireTabs($('#arch-seg'), (value) => setArch(value));

    $('#reel').addEventListener('click', () => {
      const next = PLATFORMS[(PLATFORMS.indexOf(state.platform) + 1) % PLATFORMS.length];
      reel.roll(next);
      setPlatform(next, { from: 'reel' });
    });
    $('#reel-track').addEventListener('transitionend', (event) => {
      if (event.propertyName === 'transform') reel.settle();
    });

    $('#theme-toggle').addEventListener('click', toggleTheme);
    $('#lang-toggle').addEventListener('click', () => {
      const next = state.lang === 'zh' ? 'en' : 'zh';
      if (!document.startViewTransition || reducedMotion.matches) {
        setLang(next);
        return;
      }
      document
        .startViewTransition(() => setLang(next))
        .ready.then(() => {
          root.animate(
            { opacity: [1, 0], filter: ['blur(0px)', 'blur(10px)'] },
            { duration: 240, easing: 'ease-in', fill: 'forwards', pseudoElement: '::view-transition-old(root)' },
          );
          root.animate(
            { opacity: [0, 1], filter: ['blur(10px)', 'blur(0px)'] },
            {
              duration: 460,
              delay: 90,
              easing: 'cubic-bezier(0.22, 1, 0.36, 1)',
              fill: 'backwards',
              pseudoElement: '::view-transition-new(root)',
            },
          );
        })
        .catch(() => {});
    });

    let searchTimer = 0;
    $('#cl-search').addEventListener('input', (event) => {
      clearTimeout(searchTimer);
      searchTimer = setTimeout(() => {
        state.query = event.target.value;
        renderTimeline();
      }, 80);
    });
    $('#cl-search').addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && event.target.value) {
        event.target.value = '';
        state.query = '';
        renderTimeline();
      }
    });
    document.addEventListener('keydown', (event) => {
      if (event.key !== '/' || event.metaKey || event.ctrlKey || event.altKey) return;
      if (event.target.closest('input, textarea, [contenteditable]')) return;
      event.preventDefault();
      $('#cl-search').focus({ preventScroll: true });
      $('#changelog').scrollIntoView();
    });
    $('#cl-more').addEventListener('click', showMore);
    addEventListener('hashchange', revealHash);

    const nav = $('#nav');
    const onScroll = () => nav.classList.toggle('scrolled', scrollY > 4);
    addEventListener('scroll', onScroll, { passive: true });
    onScroll();

    let resizeFrame = 0;
    addEventListener('resize', () => {
      cancelAnimationFrame(resizeFrame);
      resizeFrame = requestAnimationFrame(() => {
        moveInk($('#platform-seg'), false);
        moveInk($('#arch-seg'), false);
        reel.refit();
      });
    });
  }

  function wireAmbient() {
    const shot = $('.shot');
    const glow = $('#shot-glow');
    const syncGlow = () => {
      if (shot.currentSrc) glow.style.backgroundImage = `url("${shot.currentSrc}")`;
    };
    shot.addEventListener('load', syncGlow);
    if (shot.complete) syncGlow();

    const aura = $('#aura');
    const preview = $('#preview');
    if ('IntersectionObserver' in window) {
      const observer = new IntersectionObserver((entries) => {
        for (const entry of entries) entry.target.classList.toggle('paused', !entry.isIntersecting);
      });
      observer.observe(aura);
      observer.observe(preview);
    }

    if ('IntersectionObserver' in window) {
      const headings = new IntersectionObserver(
        (entries) => {
          for (const entry of entries) {
            if (!entry.isIntersecting) continue;
            entry.target.classList.replace('pending', 'focused');
            headings.unobserve(entry.target);
          }
        },
        { rootMargin: '0px 0px -15% 0px' },
      );
      for (const heading of document.querySelectorAll('.section h2')) {
        if (heading.getBoundingClientRect().top < innerHeight) continue;
        heading.classList.add('pending');
        headings.observe(heading);
      }
    }

    if (!matchMedia('(pointer: fine)').matches) return;
    let frame = 0;
    addEventListener(
      'pointermove',
      (event) => {
        if (reducedMotion.matches || scrollY > aura.offsetHeight) return;
        cancelAnimationFrame(frame);
        frame = requestAnimationFrame(() => {
          aura.style.setProperty('--mx', ((event.clientX / innerWidth) * 2 - 1).toFixed(3));
          aura.style.setProperty('--my', ((event.clientY / innerHeight) * 2 - 1).toFixed(3));
        });
      },
      { passive: true },
    );
  }

  async function start() {
    syncShot();
    wireAmbient();
    applyStaticText();
    reel.build();
    selectTab($('#platform-seg'), state.platform, false);
    wireEvents();
    wireGlyph();

    const [device] = await Promise.all([detectDevice(), loadData()]);
    state.detected = device;
    state.platform = device.platform || 'android';
    state.arch = device.arch;

    renderReleaseMeta();
    selectTab($('#platform-seg'), state.platform, false);
    renderCta();
    renderPanel(false);
    renderTimeline();
    if (location.hash) revealHash();

    document.fonts?.ready.then(() => {
      moveInk($('#platform-seg'), false);
      reel.refit();
    });
    setTimeout(() => reel.roll(state.platform, { full: true }), reducedMotion.matches ? 0 : 450);
  }

  start();
})();
