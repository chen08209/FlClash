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
  const springEasing = CSS.supports('transition-timing-function', 'linear(0, 1)')
    ? getComputedStyle(root).getPropertyValue('--spring').trim()
    : 'cubic-bezier(0.22, 1, 0.36, 1)';
  const COS30 = Math.cos(Math.PI / 6);
  let field = null;

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

  const LANE_IN = [
    { opacity: 0, transform: 'translate(-16px, 9px)' },
    { opacity: 1, transform: 'none' },
  ];

  function animate(node, keyframes, options) {
    if (reducedMotion.matches || !node.animate) return null;
    return node.animate(keyframes, options);
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
      $('#dl-meta').textContent = t('dlMeta', release.version, formatDate(release.date, state.lang));
      $('#sums-link').href = `${REPO}/releases/download/${release.tag}/SHA256SUMS`;
      $('#sums-link').hidden = !release.assets || !release.assets.has('SHA256SUMS');
    } else {
      heroText.textContent = t('heroReleaseLoading');
    }
    const stars = $('#stars');
    if (release && typeof release.stars === 'number') {
      const format = new Intl.NumberFormat(locale(), { notation: 'compact', maximumFractionDigits: 1 });
      const compact = format.format(release.stars);
      if (stars.hidden) countUp(stars, release.stars, format);
      else stars.textContent = compact;
      stars.hidden = false;
      $('#gh-link').setAttribute('aria-label', `GitHub, ${t('stars', compact)}`);
    }
  }

  function countUp(node, value, format) {
    if (reducedMotion.matches) {
      node.textContent = format.format(value);
      return;
    }
    const start = performance.now();
    const step = (now) => {
      const progress = Math.min((now - start) / 1100, 1);
      node.textContent = format.format(Math.round(value * (1 - (1 - progress) ** 4)));
      if (progress < 1) requestAnimationFrame(step);
    };
    step(start);
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
    const left = active.offsetLeft;
    const previous = parseFloat(ink.style.left);
    ink.classList.toggle('to-end', withMotion && left > previous);
    ink.classList.toggle('to-start', withMotion && left < previous);
    if (!withMotion) ink.style.transition = 'none';
    ink.style.left = `${left}px`;
    ink.style.right = `${seg.clientWidth - left - active.offsetWidth}px`;
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
      animate(node, LANE_IN, { duration: 700, delay: 45 * index, easing: springEasing, fill: 'backwards' });
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
      if (!motion) void track.offsetWidth;
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
    if (changed) field?.surge();
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
          { rootMargin: '0px 0px -10% 0px' },
        )
      : null;

  function stageReveal(nodes, showVisible = false) {
    if (!revealer || reducedMotion.matches) return;
    for (const node of nodes) {
      if (node.getBoundingClientRect().top < innerHeight * 0.9) {
        if (showVisible) node.classList.add('shown');
        continue;
      }
      node.classList.add('pending');
      revealer.observe(node);
    }
  }

  let lastYear = null;

  function appendReleases(container, items, query, showVisible = false) {
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
    stageReveal(releases, showVisible);
  }

  function renderTimeline() {
    const timeline = $('#timeline');
    const status = $('#cl-status');
    const more = $('#cl-more');

    if (state.changelogFailed) {
      status.replaceChildren(
        t('clError'),
        ' ',
        el('a', { href: `${REPO}/blob/main/CHANGELOG.md`, text: t('clErrorLink') }),
      );
      more.hidden = true;
      return;
    }
    timeline.replaceChildren();
    lastYear = null;

    const versions = state.versions;
    $('#cl-meta').textContent = changelogMeta(versions, state.lang);

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
      true,
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

  function laneWipe(originX, originY) {
    const width = innerWidth;
    const height = innerHeight;
    const span = width * 0.5 + height * COS30;
    const bands = Math.max(6, Math.round(span / 110));
    const pitch = span / bands;
    const from = -height * 0.5 - 2;
    const to = width * COS30 + 2;
    const origin = Math.floor((originX * 0.5 + originY * COS30) / pitch);
    const lag = 0.5 / Math.max(origin, bands - 1 - origin, 1);
    const at = (across, along) =>
      `${(across * 0.5 + along * COS30).toFixed(1)}px ${(across * COS30 - along * 0.5).toFixed(1)}px`;
    const frames = [];
    for (let frame = 0; frame <= 16; frame++) {
      const points = [];
      for (let band = 0; band < bands; band++) {
        const local = Math.min(Math.max((frame / 16 - Math.abs(band - origin) * lag) * 2, 0), 1);
        const half = (pitch / 2 + 1) * (1 - (1 - local) ** 3);
        const middle = (band + 0.5) * pitch;
        points.push(at(middle - half, from), at(middle - half, to), at(middle + half, to), at(middle + half, from));
      }
      frames.push(`polygon(${points.join(', ')})`);
    }
    return frames;
  }

  function toggleTheme(event) {
    const next = effectiveTheme() === 'dark' ? 'light' : 'dark';
    const apply = () => {
      root.dataset.theme = next;
      syncShot();
      field?.refresh();
      try {
        localStorage.setItem('flclash.theme', next);
      } catch {}
    };
    if (!document.startViewTransition || reducedMotion.matches) {
      apply();
      return;
    }
    const rect = event.currentTarget.getBoundingClientRect();
    const frames = laneWipe(rect.left + rect.width / 2, rect.top + rect.height / 2);
    document
      .startViewTransition(apply)
      .ready.then(() => {
        root.animate({ clipPath: frames }, { duration: 820, easing: 'linear', pseudoElement: '::view-transition-new(root)' });
      })
      .catch(() => {});
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
    reel.refit();
    moveInk($('#platform-seg'), false);
    field?.refresh();
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

  function splitWordmark() {
    const word = $('#wordmark');
    const text = word.textContent;
    word.replaceChildren(
      el('span', { class: 'sr', text }),
      el(
        'span',
        { 'aria-hidden': 'true' },
        [...text].map((letter, index) => el('span', { class: 'ch', style: `--i:${index}`, text: letter })),
      ),
    );
    word.classList.add('split');
  }

  function wireHoverInk(group) {
    const ink = el('span', { class: 'hover-ink', 'aria-hidden': 'true' });
    group.prepend(ink);
    group.addEventListener('pointerover', (event) => {
      const item = event.target.closest('a, button');
      if (event.pointerType !== 'mouse' || !item || !group.contains(item)) return;
      const landing = !ink.classList.contains('on');
      if (landing) ink.style.transition = 'none';
      ink.style.width = `${item.offsetWidth}px`;
      ink.style.transform = `translateX(${item.offsetLeft}px)`;
      if (landing) {
        void ink.offsetWidth;
        ink.style.transition = '';
      }
      ink.classList.add('on');
    });
    group.addEventListener('pointerleave', () => ink.classList.remove('on'));
  }

  function wireMagnet(button) {
    if (!matchMedia('(hover: hover) and (pointer: fine)').matches) return;
    button.addEventListener('pointermove', (event) => {
      if (reducedMotion.matches) return;
      const rect = button.getBoundingClientRect();
      const x = (event.clientX - rect.left) / rect.width - 0.5;
      const y = (event.clientY - rect.top) / rect.height - 0.5;
      button.style.setProperty('--pull-x', `${(x * 10).toFixed(1)}px`);
      button.style.setProperty('--pull-y', `${(y * 8).toFixed(1)}px`);
    });
    button.addEventListener('pointerleave', () => {
      button.style.removeProperty('--pull-x');
      button.style.removeProperty('--pull-y');
    });
  }

  // Offsets rather than client rects: the hero is the offset parent of all of these and of the canvas, and the
  // entrance animations move the client rects while they run.
  function layoutBox(node) {
    return {
      left: node.offsetLeft,
      top: node.offsetTop,
      right: node.offsetLeft + node.offsetWidth,
      bottom: node.offsetTop + node.offsetHeight,
    };
  }

  function taglineBox() {
    const box = layoutBox($('#tagline'));
    const widest = Math.max(...[...$('#reel-track').children].map((word) => word.offsetWidth));
    return { ...box, right: box.right - $('#reel').offsetWidth + widest };
  }

  function wireField() {
    field = globalThis.FlClashField?.mount($('#field'), {
      avoid: () => [
        taglineBox(),
        ...[...document.querySelectorAll('#hero-release, #wordmark, .lede, .cta, #cta-note, #facts')]
          .filter((node) => node.offsetWidth)
          .map(layoutBox),
      ],
      stage: () => ($('#stage').offsetWidth ? layoutBox($('#stage')) : null),
      still: () => reducedMotion.matches,
    });
    matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => field?.refresh());
  }

  // Scroll-driven CSS animations stutter in Android WebView at 120 Hz, so the page progress bar and the preview
  // settling flat follow the scroll position from script instead.
  function followScroll() {
    if (reducedMotion.matches) return;
    const range = root.scrollHeight - innerHeight;
    const read = range > 0 ? Math.min(1, Math.max(0, scrollY / range)) : 0;
    $('.nav-progress').style.transform = `scaleX(${read.toFixed(4)})`;

    const shot = $('.shot');
    let top = 0;
    for (let node = shot; node; node = node.offsetParent) top += node.offsetTop;
    const inset = parseFloat(getComputedStyle(root).scrollPaddingTop) || 0;
    const travel = (innerHeight - inset + shot.offsetHeight) * 0.42;
    const flat = Math.min(1, Math.max(0, (scrollY - top + innerHeight) / travel));
    shot.style.transform =
      flat < 1 ? `rotateX(${(18 * (1 - flat)).toFixed(2)}deg) scale(${(0.93 + 0.07 * flat).toFixed(4)})` : '';
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
    for (const group of document.querySelectorAll('[data-ink]')) wireHoverInk(group);
    wireMagnet($('#cta'));
    $('#cta').addEventListener('click', () => field?.surge());

    $('#theme-toggle').addEventListener('click', toggleTheme);
    $('#lang-toggle').addEventListener('click', (event) => {
      const next = state.lang === 'zh' ? 'en' : 'zh';
      if (!root.dataset.pageLang) {
        setLang(next);
        return;
      }
      rememberLang(next);
      carryView(event.currentTarget);
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
    const onScroll = () => {
      nav.classList.toggle('scrolled', scrollY > 4);
      followScroll();
    };
    addEventListener('scroll', onScroll, { passive: true });
    onScroll();
    if ('ResizeObserver' in window) new ResizeObserver(followScroll).observe(document.body);

    let resizeFrame = 0;
    addEventListener('resize', () => {
      cancelAnimationFrame(resizeFrame);
      resizeFrame = requestAnimationFrame(() => {
        moveInk($('#platform-seg'), false);
        moveInk($('#arch-seg'), false);
        reel.refit();
        followScroll();
      });
    });
  }

  async function start() {
    const carried = takeCarriedView();
    syncShot();
    splitWordmark();
    applyStaticText();
    reel.build();
    selectTab($('#platform-seg'), state.platform, false);
    wireEvents();
    wireGlyph();
    wireField();
    stageReveal(document.querySelectorAll('.section .rail, .dl, #facts, .foot'));

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
    selectTab($('#platform-seg'), state.platform, false);
    renderCta();
    renderPanel(false);
    renderTimeline();
    if (location.hash) revealHash();

    field?.refresh();
    document.fonts?.ready.then(() => {
      moveInk($('#platform-seg'), false);
      reel.refit();
      field?.refresh();
    });
    setTimeout(() => reel.roll(state.platform, { full: true }), reducedMotion.matches ? 0 : 450);
  }

  start();
})();
