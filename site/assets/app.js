(() => {
  'use strict';

  const PLATFORMS = ['android', 'windows', 'macos', 'linux'];
  const PLATFORM_NAMES = { android: 'Android', windows: 'Windows', macos: 'macOS', linux: 'Linux' };
  const PAGE = 15;
  const { REPO, FIRST_PAGE, parseChangelog, translate, formatDate, changelogMeta, timelineHtml } =
    globalThis.FlClashSite;
  const SITE = new URL('..', document.currentScript.src);

  const root = document.documentElement;
  const $ = (selector, scope = document) => scope.querySelector(selector);
  const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');

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
    return translate(state.lang, key, ...args);
  }

  function el(tag, props, ...children) {
    const node = document.createElement(tag);
    if (props) {
      for (const [key, value] of Object.entries(props)) {
        if (value == null || value === false) continue;
        if (key === 'class') node.className = value;
        else if (key === 'text') node.textContent = value;
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

  function rise(node, index) {
    if (reducedMotion.matches || !node.animate) return;
    node.animate([{ opacity: 0, translate: '0 14px' }, { opacity: 1, translate: '0 0' }], {
      duration: 600,
      delay: 40 * index,
      easing: 'cubic-bezier(0.22, 1, 0.36, 1)',
      fill: 'backwards',
    });
  }

  function locale() {
    return state.lang === 'zh' ? 'zh-CN' : 'en';
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
          { id: 'android-arm64.apk', kind: 'APK', title: 'arm64-v8a', note: 'noteAndroidArm64', rec: true },
          { id: 'android-armv7.apk', kind: 'APK', title: 'armeabi-v7a', note: 'noteAndroidArm32' },
          { id: 'android-amd64.apk', kind: 'APK', title: 'x86_64', note: 'noteAndroidX64' },
        ];
      case 'windows':
        return [
          { id: `windows-${goArch(arch)}-setup.exe`, kind: 'EXE', titleKey: 'winSetup', note: 'noteWinSetup', rec: true },
          { id: `windows-${goArch(arch)}-portable.zip`, kind: 'ZIP', titleKey: 'winPortable', note: 'noteWinPortable' },
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

  // tool/package.dart check parses these names from this file to hold each release to them.
  function assetName(release, id) {
    return `FlClash-${release.version}-${id}`;
  }

  function assetHref(release, name) {
    if (release.assets && !release.assets.has(name)) return `${REPO}/releases/tag/${release.tag}`;
    return `${REPO}/releases/download/${release.tag}/${name}`;
  }

  function resolveBuilds(platform, arch) {
    const release = state.release;
    if (!release) return [];
    return buildsFor(platform, arch).map((build) => {
      const name = assetName(release, build.id);
      const asset = release.assets ? release.assets.get(name) : null;
      return {
        ...build,
        name,
        title: build.titleKey ? t(build.titleKey) : build.title,
        href: assetHref(release, name),
        size: asset ? asset.size : null,
        digest: asset && asset.digest ? asset.digest.replace(/^sha256:/, '') : null,
      };
    });
  }

  function isIos() {
    const ua = navigator.userAgent;
    return /iphone|ipad|ipod/i.test(ua) || (/macintosh/i.test(ua) && navigator.maxTouchPoints > 1);
  }

  function platformFromAgent() {
    const ua = navigator.userAgent;
    if (/android/i.test(ua)) return 'android';
    if (isIos()) return null;
    if (/windows/i.test(ua)) return 'windows';
    if (/macintosh|mac os x/i.test(ua)) return 'macos';
    if (/linux|x11|cros/i.test(ua)) return 'linux';
    return null;
  }

  async function detectDevice() {
    const ua = navigator.userAgent;
    const result = { platform: platformFromAgent(), arch: null, ios: isIos() };
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

  async function loadData() {
    const [markdown, release] = await Promise.allSettled([
      fetch(new URL('CHANGELOG.md', SITE), { cache: 'no-cache' }).then((r) => (r.ok ? r.text() : Promise.reject(r.status))),
      fetch(new URL('release.json', SITE), { cache: 'no-cache' }).then((r) => (r.ok ? r.json() : null)),
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
    document.title = t('pageTitle');
    $('meta[name="description"]').content = t('pageDescription');
    for (const node of document.querySelectorAll('[data-i18n]')) node.textContent = t(node.dataset.i18n);
    for (const node of document.querySelectorAll('[data-i18n-placeholder]')) {
      node.placeholder = t(node.dataset.i18nPlaceholder);
    }
    $('#langs').setAttribute('aria-label', t('langGroup'));
    for (const link of $('#langs').children) {
      if (link.dataset.lang === state.lang) link.setAttribute('aria-current', 'page');
      else link.removeAttribute('aria-current');
    }
    $('#platform-seg').setAttribute('aria-label', t('platformLabel'));
    $('#arch-seg').setAttribute('aria-label', t('archLabel'));
  }

  function renderReleaseMeta() {
    const release = state.release;
    if (release) {
      $('#hero-release-text').textContent = t('heroRelease', release.tag, formatDate(release.date, state.lang));
      $('#hero-release').href = `#${release.tag}`;
      $('#dl-meta').textContent = $('#dock-dl-meta').textContent = t(
        'dlMeta',
        release.version,
        formatDate(release.date, state.lang),
      );
      $('#sums-link').href = assetHref(release, assetName(release, 'SHA256SUMS'));
    }
    if (release && typeof release.stars === 'number') {
      const compact = new Intl.NumberFormat(locale(), { notation: 'compact', maximumFractionDigits: 1 }).format(
        release.stars,
      );
      const stars = $('#stars');
      stars.textContent = compact;
      stars.hidden = false;
      $('#gh-link').setAttribute('aria-label', `GitHub, ${t('stars', compact)}`);
    }
  }

  function renderCta() {
    const cta = $('#cta');
    const sub = $('#cta-sub');
    const note = $('#cta-note');
    $('#hero-platform').textContent = PLATFORM_NAMES[state.platform];
    note.hidden = !state.detected.ios;
    note.textContent = state.detected.ios ? t('ctaIos') : '';
    const builds = state.detected.ios && !state.platformChosen ? [] : resolveBuilds(state.platform, state.arch);
    const pick = builds.find((b) => b.rec) || builds[0];
    if (!pick) {
      $('#cta-title').textContent = t('ctaChoose');
      sub.hidden = true;
      cta.href = '#download';
      return;
    }
    $('#cta-title').textContent = t('ctaDownload', PLATFORM_NAMES[state.platform]);
    const parts = [pick.short || pick.title];
    if (state.platform === 'windows' || state.platform === 'linux') parts.unshift(state.arch === 'arm64' ? 'ARM64' : 'x64');
    if (pick.size) parts.push(formatSize(pick.size));
    sub.textContent = parts.join(' · ');
    sub.hidden = false;
    cta.href = pick.href;
  }

  function selectTab(group, value) {
    for (const button of group.querySelectorAll('[role="tab"]')) {
      const selected = button.dataset.value === value;
      button.setAttribute('aria-selected', String(selected));
      button.tabIndex = selected ? 0 : -1;
    }
  }

  function wireTabs(group, onSelect) {
    group.addEventListener('click', (event) => {
      const button = event.target.closest('[role="tab"]');
      if (button) onSelect(button.dataset.value);
    });
    group.addEventListener('keydown', (event) => {
      if (!['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) return;
      const tabs = [...group.querySelectorAll('[role="tab"]')];
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
      el(
        'div',
        { class: 'file-main' },
        el(
          'p',
          { class: 'file-head' },
          el('a', { class: 'file-title', href: build.href, title: build.name, text: build.title }),
          build.rec ? el('span', { class: 'rec-tag', text: t('recommended') }) : null,
        ),
        el(
          'p',
          { class: 'file-sub' },
          el('span', { class: 'note', text: t(build.note) }),
          el('span', { class: 'kind', text: build.kind === 'APPIMAGE' ? 'AppImage' : build.kind }),
          build.size ? el('span', { class: 'size', text: formatSize(build.size) }) : null,
          sha,
        ),
      ),
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
        { class: 'copy', type: 'button', 'aria-label': t('copy'), onclick: (event) => copyText(text, event.currentTarget) },
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
        return [tip('tipTrayTitle', 'tipTray')];
      default:
        return [];
    }
  }

  function renderPanel(withMotion) {
    const hints = { android: 'hintAndroid', windows: 'hintWindows', macos: 'hintMacos', linux: 'hintLinux' };
    $('#panel-hint').textContent = t(hints[state.platform]);
    $('#panel').setAttribute('aria-labelledby', `tab-${state.platform}`);

    const archSeg = $('#arch-seg');
    archSeg.hidden = !(state.platform === 'windows' || state.platform === 'linux');
    if (!archSeg.hidden) selectTab(archSeg, state.arch);

    const files = $('#files');
    files.replaceChildren(...resolveBuilds(state.platform, state.arch).map(fileRow));
    $('#dl-error').hidden = !state.releaseFailed;
    $('#dl-error').textContent = state.releaseFailed ? t('dlError') : '';
    $('#extras').replaceChildren(...extrasFor(state.platform));
    if (withMotion) [...files.children, ...$('#extras').children].forEach(rise);
  }

  function setPlatform(platform) {
    if (!PLATFORM_NAMES[platform]) return;
    const changed = platform !== state.platform;
    state.platform = platform;
    state.platformChosen = true;
    if (platform === 'macos' || platform === 'windows' || platform === 'linux') {
      state.arch = state.detected.platform === platform ? state.detected.arch : platform === 'macos' ? 'arm64' : 'x64';
    }
    selectTab($('#platform-seg'), platform);
    renderCta();
    renderPanel(changed);
  }

  function setArch(arch) {
    if (arch === state.arch) return;
    state.arch = arch;
    renderCta();
    renderPanel(true);
  }

  function matchVersion(version, query) {
    if (version.version.includes(query) || version.tag.toLowerCase().includes(query)) return version.groups;
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

  const revealer =
    'IntersectionObserver' in window
      ? new IntersectionObserver(
          (entries) => {
            for (const entry of entries) {
              if (!entry.isIntersecting) continue;
              entry.target.classList.replace('pending', 'shown');
              revealer.unobserve(entry.target);
            }
          },
          { rootMargin: '0px 0px -8% 0px' },
        )
      : null;

  function stageReveal(nodes) {
    if (!revealer || reducedMotion.matches) return;
    for (const node of nodes) {
      if (node.getBoundingClientRect().top < innerHeight * 0.92) continue;
      node.classList.add('pending');
      revealer.observe(node);
    }
  }

  let lastYear = null;

  function appendReleases(container, items, query) {
    const { html, year } = timelineHtml(items, {
      lang: state.lang,
      query,
      latestTag: state.versions[0]?.tag,
      ago: formatAgo,
      year: lastYear,
    });
    lastYear = year;
    const template = document.createElement('template');
    template.innerHTML = html;
    const releases = [...template.content.querySelectorAll('.release')];
    container.append(template.content);
    stageReveal(releases);
  }

  function renderTimeline() {
    const timeline = $('#timeline');
    const status = $('#cl-status');
    const more = $('#cl-more');

    if (state.changelogFailed) {
      status.replaceChildren(t('clError'), ' ', el('a', { href: `${REPO}/blob/main/CHANGELOG.md`, text: t('clErrorLink') }));
      more.hidden = true;
      return;
    }
    timeline.replaceChildren();
    lastYear = null;

    const versions = state.versions;
    $('#cl-meta').textContent = $('#dock-cl-meta').textContent = changelogMeta(versions, state.lang);

    const query = state.query.trim().toLowerCase();
    if (!query) {
      status.replaceChildren();
      appendReleases(timeline, versions.slice(0, state.shown).map((version) => ({ version, groups: version.groups })), '');
      updateMore();
      return;
    }

    const matches = versions
      .map((version) => ({ version, groups: matchVersion(version, query) }))
      .filter(({ version, groups }) => groups.length || version.version.includes(query));
    const entryCount = matches.reduce((sum, { groups }) => sum + groups.reduce((n, group) => n + group.entries.length, 0), 0);
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
    if (matches.length) status.replaceChildren(t('clResults', entryCount, matches.length), ' · ', clear);
    else status.replaceChildren(t('clNone', state.query.trim()), ' ', clear);
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

  function rememberLang(lang) {
    try {
      localStorage.setItem('flclash.lang', lang);
    } catch {}
  }

  function anchorAtTop() {
    const line = (parseFloat(getComputedStyle(root).scrollPaddingTop) || 0) + 1;
    let anchor = '';
    for (const node of document.querySelectorAll('#download, #changelog, .release')) {
      if (node.getBoundingClientRect().top > line) break;
      anchor = `#${node.id}`;
    }
    return anchor;
  }

  function carryView(link) {
    if (!link.dataset.base) link.dataset.base = link.getAttribute('href');
    const url = new URL(link.dataset.base, location.href);
    if (state.platformChosen) {
      url.searchParams.set('platform', state.platform);
      url.searchParams.set('arch', state.arch);
    }
    const query = state.query.trim();
    if (query) url.searchParams.set('q', query);
    url.hash = anchorAtTop();
    link.href = url.href;
  }

  function takeCarriedView() {
    const params = new URLSearchParams(location.search);
    const view = { platform: params.get('platform'), arch: params.get('arch'), query: params.get('q') };
    if (!['platform', 'arch', 'q'].some((key) => params.has(key))) return view;
    for (const key of ['platform', 'arch', 'q']) params.delete(key);
    const search = params.toString();
    history.replaceState(history.state, '', `${location.pathname}${search ? `?${search}` : ''}${location.hash}`);
    return view;
  }

  function setLang(next) {
    state.lang = next;
    rememberLang(next);
    applyStaticText();
    renderReleaseMeta();
    renderCta();
    renderPanel(false);
    renderTimeline();
  }

  function wireEvents() {
    wireTabs($('#platform-seg'), setPlatform);
    wireTabs($('#arch-seg'), setArch);

    $('#langs').addEventListener('click', (event) => {
      const link = event.target.closest('[data-lang]');
      if (!link) return;
      const next = link.dataset.lang;
      if (next === state.lang || !root.dataset.pageLang) {
        event.preventDefault();
        if (next !== state.lang) setLang(next);
        return;
      }
      rememberLang(next);
      carryView(link);
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
  }

  async function start() {
    const carried = takeCarriedView();
    state.platform = platformFromAgent() || 'android';
    applyStaticText();
    selectTab($('#platform-seg'), state.platform);
    renderCta();
    wireEvents();

    const [device] = await Promise.all([detectDevice(), loadData()]);
    state.detected = device;
    state.platform = device.platform || 'android';
    state.arch = device.arch;
    if (PLATFORMS.includes(carried.platform)) {
      state.platform = carried.platform;
      state.platformChosen = true;
      if (carried.arch === 'x64' || carried.arch === 'arm64') state.arch = carried.arch;
    }
    if (carried.query) {
      state.query = carried.query;
      $('#cl-search').value = carried.query;
    }

    renderReleaseMeta();
    selectTab($('#platform-seg'), state.platform);
    renderCta();
    renderPanel(false);
    renderTimeline();
    if (location.hash) revealHash();
  }

  start();
})();
