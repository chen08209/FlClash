(() => {
  'use strict';

  const root = document.documentElement;
  const $ = (selector) => document.querySelector(selector);
  const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
  const wide = matchMedia('(min-width: 960px)');
  const { start: START_MORPH, enter: ENTER_MORPH, cycle: CYCLE_MORPHS } = globalThis.FlClashShapes;
  // The app's theme colours the page steps through; graphite is left out, as a grey start button reads as disabled.
  const ACCENTS = ['blue', 'purple', 'pink', 'red', 'orange', 'yellow', 'green'];
  // AppGlyphs.playPause in lib/ui/icons/app_glyphs.dart, on its 24-unit grid: the play corners, and each half of
  // play beside the pause bar it folds into.
  const PLAY = [
    [8.3, 5.6],
    [18.8, 12],
    [8.3, 18.4],
  ];
  const PLAY_HALVES = [
    [
      [[8.3, 5.6], [18.8, 12], [18.8, 12], [8.3, 12]],
      [[5.9, 6.9], [18.1, 6.9], [18.1, 9.1], [5.9, 9.1]],
    ],
    [
      [[8.3, 12], [18.8, 12], [18.8, 12], [8.3, 18.4]],
      [[5.9, 14.9], [18.1, 14.9], [18.1, 17.1], [5.9, 17.1]],
    ],
  ];
  const MORPH_MS = 450;
  // The hero keeps the start button's two shapes for its first stretch of scroll; after that every STEP_VH of scroll
  // morphs the emblem into the next shape and the page into the next colour.
  const HERO_VH = 0.08;
  const STEP_VH = 0.5;
  // Wide screens: the scroll by which the emblem has docked, which style.css's .flow margin places the downloads for.
  const DOCKED_VH = 0.45;

  // Shape k is the circle, the cookie, then the cycle; pos runs between them, and glyph.to is whether it is running.
  const shape = { pos: 0, origin: 0, to: 0, target: 0, t: 1 };
  const glyph = { value: 0, from: 0, to: 0, t: 1 };
  let scene = null;
  let tickFrame = 0;
  let tickLast = 0;

  function setAccent(accent) {
    if (accent === (root.dataset.accent || ACCENTS[0])) return;
    if (accent === ACCENTS[0]) delete root.dataset.accent;
    else root.dataset.accent = accent;
  }

  function morphPath(morph, progress, size = 1) {
    const digits = size === 1 ? 4 : 2;
    const at = (cubic, j) => ((cubic[j] + (cubic[j + 8] - cubic[j]) * progress) * size).toFixed(digits);
    let d = `M${at(morph[0], 0)} ${at(morph[0], 1)}`;
    for (const cubic of morph) {
      d += `C${at(cubic, 2)} ${at(cubic, 3)} ${at(cubic, 4)} ${at(cubic, 5)} ${at(cubic, 6)} ${at(cubic, 7)}`;
    }
    return `${d}Z`;
  }

  // The morph out of shape k, which leads to shape k + 1.
  function morphOf(index) {
    if (index === 0) return START_MORPH;
    if (index === 1) return ENTER_MORPH;
    return CYCLE_MORPHS[(index - 2) % CYCLE_MORPHS.length];
  }

  function roundedPolygon(points, radius) {
    let d = '';
    points.forEach(([x, y], i) => {
      const [px, py] = points[(i + points.length - 1) % points.length];
      const [nx, ny] = points[(i + 1) % points.length];
      const before = Math.hypot(px - x, py - y);
      const after = Math.hypot(nx - x, ny - y);
      let cut = 0;
      if (before > 1e-6 && after > 1e-6) {
        const cos = ((px - x) * (nx - x) + (py - y) * (ny - y)) / (before * after);
        const half = Math.acos(Math.min(1, Math.max(-1, cos))) / 2;
        cut = Math.min(radius / Math.tan(half), before / 2, after / 2);
      }
      const ax = x + ((px - x) / (before || 1)) * cut;
      const ay = y + ((py - y) / (before || 1)) * cut;
      const bx = x + ((nx - x) / (after || 1)) * cut;
      const by = y + ((ny - y) / (after || 1)) * cut;
      const at = (...values) => values.map((value) => value.toFixed(2)).join(' ');
      d += `${i ? 'L' : 'M'}${at(ax, ay)}Q${at(x, y, bx, by)}`;
    });
    return `${d}Z`;
  }

  function playPausePath(progress) {
    const fold = unit(progress);
    const angle = (Math.PI / 2) * progress;
    const cos = Math.cos(angle);
    const sin = Math.sin(angle);
    const turned = ([x, y]) => [12 + (x - 12) * cos - (y - 12) * sin, 12 + (x - 12) * sin + (y - 12) * cos];
    if (fold === 0) return roundedPolygon(PLAY.map(turned), 1.2);
    return PLAY_HALVES.map(([half, bar]) =>
      roundedPolygon(
        half.map(([x, y], i) => turned([x + (bar[i][0] - x) * fold, y + (bar[i][1] - y) * fold])),
        1.2,
      ),
    ).join('');
  }

  // Flutter's easeOutBack and easeInCubic, the curves the app's start button morphs on.
  function easeOutBack(t) {
    return 1 + 2.70158 * (t - 1) ** 3 + 1.70158 * (t - 1) ** 2;
  }

  function easeInCubic(t) {
    return t * t * t;
  }

  function unit(value) {
    return Math.min(Math.max(value, 0), 1);
  }

  function smooth(value) {
    const t = unit(value);
    return t * t * (3 - 2 * t);
  }

  // One step toward the target, or straight into it after a jump of several shapes, such as an anchor link.
  function nextShape(from, target) {
    const gap = target - from;
    return Math.abs(gap) > 3 ? target : from + Math.sign(gap);
  }

  function tick(now) {
    const step = (now - tickLast) / MORPH_MS;
    tickLast = now;
    if (shape.t < 1) {
      shape.t = Math.min(1, shape.t + step);
      // Stopping eases in as the app's button does; every other morph springs past its shape and settles.
      const eased = shape.to === 0 ? 1 - easeInCubic(1 - shape.t) : easeOutBack(shape.t);
      shape.pos = shape.origin + (shape.to - shape.origin) * eased;
      if (shape.t === 1 && shape.to !== shape.target) {
        shape.origin = shape.to;
        shape.to = nextShape(shape.to, shape.target);
        shape.t = 0;
      }
    }
    if (glyph.t < 1) {
      glyph.t = Math.min(1, glyph.t + step);
      glyph.value = glyph.from + (glyph.to - glyph.from) * easeOutBack(glyph.t);
    }
    drawEmblem();
    tickFrame = shape.t < 1 || glyph.t < 1 ? requestAnimationFrame(tick) : 0;
  }

  function animate() {
    if (tickFrame) return;
    tickLast = performance.now();
    tickFrame = requestAnimationFrame(tick);
  }

  function aimShape(target) {
    if (target === shape.target) return;
    shape.target = target;
    setAccent(ACCENTS[target <= 1 ? 0 : (target - 1) % ACCENTS.length]);
    if (reducedMotion.matches) {
      shape.pos = shape.origin = shape.to = target;
      shape.t = 1;
      drawEmblem();
      return;
    }
    const heading = Math.sign(shape.to - shape.pos);
    if (shape.t < 1 && heading !== 0 && heading === Math.sign(target - shape.pos)) return;
    shape.origin = shape.pos;
    shape.to = nextShape(target > shape.pos ? Math.floor(shape.pos) : Math.ceil(shape.pos), target);
    shape.t = 0;
    animate();
  }

  // The glyph eases from where it is, so a quick second tap overshoots past play, as in the app.
  function setRunning(on) {
    glyph.from = glyph.value;
    glyph.to = on ? 1 : 0;
    glyph.t = 0;
    if (Math.max(0, scrollY) < scene.vh * HERO_VH) aimShape(glyph.to);
    if (!reducedMotion.matches) {
      animate();
      return;
    }
    glyph.value = glyph.to;
    glyph.t = 1;
    drawEmblem();
  }

  function pageTop(node) {
    let top = 0;
    for (; node; node = node.offsetParent) top += node.offsetTop;
    return top;
  }

  function pageLeft(node) {
    let left = 0;
    for (; node; node = node.offsetParent) left += node.offsetLeft;
    return left;
  }

  // The emblem's box is where it docks; the spot in the hero is where it starts. Wide, the dock's view sticks to the
  // top of the viewport, so the emblem holds still there while it grows and crosses to the left.
  function measure() {
    const emblem = $('#emblem');
    const spot = $('#spot');
    const size = emblem.offsetWidth;
    const docks = wide.matches;
    const dockTop = docks ? 0 : pageTop($('#dock'));
    scene = {
      vh: innerHeight,
      wide: docks,
      dx: pageLeft(spot) + spot.offsetWidth / 2 - (emblem.offsetLeft + size / 2),
      dy: pageTop(spot) + spot.offsetHeight / 2 - (dockTop + emblem.offsetTop + size / 2),
      scale: spot.offsetWidth / size,
      changelog: pageTop($('#changelog')),
      lastScroll: Math.max(0, scrollY),
      part: -1,
      docking: 0,
      spin: 0,
      shapeKey: null,
      glyphKey: null,
    };
    emblem.classList.add('ready');
  }

  function drawEmblem() {
    const lower = Math.max(0, Math.floor(shape.pos));
    const shapeKey = shape.pos.toFixed(4);
    if (shapeKey !== scene.shapeKey) {
      scene.shapeKey = shapeKey;
      $('#emblem-path').setAttribute('d', morphPath(morphOf(lower), shape.pos - lower));
    }
    // Each morph turns the shape a ninth of a turn, as the app's start button does, on top of the scroll's own spin.
    const turn = scene.spin + 40 * shape.pos;
    $('.emblem-shape').style.transform = `rotate(${turn.toFixed(2)}deg)`;
    const glyphKey = glyph.value.toFixed(4);
    if (glyphKey !== scene.glyphKey) {
      scene.glyphKey = glyphKey;
      $('#emblem-glyph').setAttribute('d', playPausePath(glyph.value));
    }
    $('.emblem-glyph').style.opacity = String(1 - unit(scene.docking * 2.5));
  }

  function moveEmblem(scroll) {
    const { vh } = scene;
    const still = reducedMotion.matches;
    const travel = (scroll - vh * 0.1) / (vh * (DOCKED_VH - 0.1));
    const docking = scene.wide && (still ? (travel >= 0.8 ? 1 : 0) : smooth(travel));
    const grow = scene.wide ? (still ? docking : smooth(scroll / (vh * 0.25))) : still ? 0 : unit(scroll / (vh * 0.6));
    scene.docking = docking;
    scene.spin = still ? 0 : (scroll / vh) * 30;
    const scale = scene.wide ? scene.scale + (1 - scene.scale) * grow : scene.scale * (1 + 0.15 * grow);
    const emblem = $('#emblem');
    const x = (scene.dx * (1 - docking)).toFixed(1);
    const y = (scene.dy * (1 - docking)).toFixed(1);
    emblem.style.transform = `translate(${x}px, ${y}px) scale(${scale.toFixed(4)})`;
    emblem.classList.toggle('live', docking < 0.5);

    // style.css keys the docked titles, the emblem's number and the downloads' reveal off data-part.
    let part = 0;
    if (scene.wide && docking > 0.9) part = scroll + vh * 0.55 >= scene.changelog ? 2 : 1;
    if (part !== scene.part) {
      scene.part = part;
      root.dataset.part = String(part);
    }

    const hero = vh * HERO_VH;
    aimShape(scroll < hero ? glyph.to : 2 + Math.floor((scroll - hero) / (vh * STEP_VH)));
    drawEmblem();
  }

  // Scroll-driven CSS animations stutter in Android WebView at 120 Hz, so the emblem and the hero copy follow the
  // scroll position from script instead.
  function followScroll() {
    const scroll = Math.max(0, scrollY);
    const { vh } = scene;
    const delta = scroll - scene.lastScroll;
    scene.lastScroll = scroll;
    const bar = $('#bar');
    if (scroll < vh * 0.1 || delta < -6) bar.classList.remove('away');
    else if (delta > 6) bar.classList.add('away');

    moveEmblem(scroll);
    const copy = $('#hero-copy');
    if (reducedMotion.matches) {
      copy.style.visibility = scene.docking === 1 ? 'hidden' : '';
      return;
    }
    const fade = unit((scroll - vh * 0.06) / (vh * 0.26));
    copy.style.opacity = fade > 0 ? String(1 - fade) : '';
    copy.style.transform = fade > 0 ? `translateY(${(-scroll * 0.2).toFixed(1)}px)` : '';
    copy.style.visibility = fade === 1 ? 'hidden' : '';
    $('#scroll-hint').style.opacity = String(Math.max(0, 1 - scroll / (vh * 0.15)));
  }

  function relayout() {
    measure();
    followScroll();
  }

  function start() {
    root.style.setProperty('--circle', `path('${morphPath(START_MORPH, 0, 40)}')`);
    root.style.setProperty('--cookie', `path('${morphPath(START_MORPH, 1, 40)}')`);
    relayout();
    addEventListener('scroll', followScroll, { passive: true });
    new ResizeObserver(relayout).observe(document.body);
    let resizeFrame = 0;
    addEventListener('resize', () => {
      cancelAnimationFrame(resizeFrame);
      resizeFrame = requestAnimationFrame(relayout);
    });
    reducedMotion.addEventListener('change', () => {
      $('#hero-copy').removeAttribute('style');
      $('#scroll-hint').style.removeProperty('opacity');
      relayout();
    });
    document.fonts.ready.then(relayout);
    $('#emblem').addEventListener('click', () => setRunning(!glyph.to));
    if (reducedMotion.matches) setRunning(true);
    else setTimeout(() => glyph.to || setRunning(true), 900);
  }

  start();
})();
