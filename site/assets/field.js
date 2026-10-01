globalThis.FlClashField = (() => {
  'use strict';

  const COS = Math.cos(Math.PI / 6);
  const SIN = 0.5;
  // Bar thickness and bar step of the logo glyph, in lane pitches. Odd lanes sit half a step along, which is what
  // stacks a two-step bar, a one-step bar and a dot into the logo.
  const THICKNESS = 0.75;
  const STEP = 1.125;
  const PALETTE = [0, 0, 0, 1, 1, 2, 3, 4, 5];
  const HOPS = [1, 1, 2, 2, 2, 3];
  const LENGTHS = [0, 0, 1, 1, 2];
  const PIXEL_BUDGET = 12e6;

  const clamp = (value, low, high) => Math.min(high, Math.max(low, value));
  const pick = (list) => list[Math.floor(Math.random() * list.length)];
  const spring = (t) => (t >= 1 ? 1 : 1 - Math.exp(-7.5 * t) * Math.cos(8.5 * t));

  // `avoid` and `stage` report boxes in the canvas's own coordinates.
  function mount(canvas, { avoid = () => [], stage = () => null, still = () => false } = {}) {
    const ctx = canvas.getContext('2d');
    if (!ctx) return null;

    let width = 0;
    let height = 0;
    let pitch = 0;
    let step = 0;
    let gap = 0;
    let lanes = [];
    let capsules = [];
    let colors = [];
    let logoColors = [];
    let frame = 0;
    let last = 0;
    let tempo = 1;
    let dirty = true;
    let onScreen = true;
    let pointer = null;
    let scrollAt = { y: scrollY, time: performance.now() };

    function point(lane, cell) {
      const along = (cell + (lane & 1 ? 0.5 : 0)) * step;
      return [along * COS, lane * gap - along * SIN];
    }

    function measure() {
      const box = canvas.getBoundingClientRect();
      width = box.width;
      height = box.height;
      const ratio = Math.min(devicePixelRatio || 1, 2, Math.sqrt(PIXEL_BUDGET / Math.max(width * height, 1)));
      canvas.width = Math.round(width * ratio);
      canvas.height = Math.round(height * ratio);
      ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
      pitch = clamp(width * 0.044, 30, 62);
      step = pitch * STEP;
      gap = pitch / COS;
    }

    function chart() {
      const edge = pitch * THICKNESS * 0.5 + 2;
      const margin = edge + 10;
      const blocks = avoid().map((rect) => ({
        left: rect.left - margin,
        right: rect.right + margin,
        top: rect.top - margin,
        bottom: rect.bottom + margin,
      }));
      const cells = Math.ceil(width / (step * COS)) + 1;
      const count = Math.ceil((height + (width * SIN) / COS) / gap) + 1;
      lanes = [];
      for (let lane = 0; lane < count; lane++) {
        const open = [];
        const runs = [];
        let from = -1;
        for (let cell = 0; cell <= cells; cell++) {
          const [x, y] = point(lane, cell);
          const free =
            cell < cells &&
            x >= edge &&
            x <= width - edge &&
            y >= edge &&
            y <= height - edge &&
            !blocks.some((b) => x > b.left && x < b.right && y > b.top && y < b.bottom);
          open.push(free);
          if (free) {
            if (from < 0) from = cell;
          } else if (from >= 0) {
            if (cell - from >= 2) runs.push([from, cell - 1]);
            from = -1;
          }
        }
        lanes.push({ open, runs });
      }
    }

    function tint() {
      const style = getComputedStyle(canvas);
      const read = (name) => style.getPropertyValue(name).trim() || '#999';
      colors = [1, 2, 3, 4, 5, 6].map((index) => read(`--field-${index}`));
      logoColors = [1, 2, 3].map((index) => read(`--g${index}`));
    }

    function begin(capsule, phase, span) {
      capsule.phase = phase;
      capsule.span = span;
      capsule.t = 0;
    }

    function rest(capsule, longest = 3.6) {
      begin(capsule, 'rest', 0.4 + Math.random() * longest);
      capsule.eager = false;
    }

    function claimed(lane, cell, self) {
      return capsules.some(
        (other) =>
          other !== self &&
          other.lane === lane &&
          cell >= Math.floor(other.a) - 1 &&
          cell <= Math.ceil(other.phase === 'stretch' ? other.to : other.b) + 1,
      );
    }

    function settle(capsule, lane, cell) {
      capsule.lane = lane;
      capsule.a = capsule.b = cell;
    }

    function relocate(capsule) {
      const ahead = lanes[capsule.lane]?.runs.find(([from]) => from > capsule.b && !claimed(capsule.lane, from, capsule));
      if (ahead) {
        settle(capsule, capsule.lane, ahead[0]);
        return true;
      }
      for (let attempt = 0; attempt < 12; attempt++) {
        const lane = Math.floor(Math.random() * lanes.length);
        const { runs } = lanes[lane];
        if (!runs.length) continue;
        const [from] = Math.random() < 0.6 ? runs[0] : pick(runs);
        if (claimed(lane, from, capsule)) continue;
        settle(capsule, lane, from);
        capsule.keep = pick(LENGTHS);
        capsule.color = pick(PALETTE);
        capsule.logo = 0;
        return true;
      }
      return false;
    }

    function act(capsule) {
      const { open } = lanes[capsule.lane];
      let reach = 0;
      while (reach < 3 && open[capsule.b + reach + 1] && !claimed(capsule.lane, capsule.b + reach + 1, capsule)) reach++;
      if (!reach) {
        begin(capsule, 'sink', 0.24);
        return;
      }
      capsule.from = capsule.b;
      capsule.to = capsule.b + Math.min(reach, pick(HOPS));
      begin(capsule, 'stretch', capsule.eager ? 0.42 : 0.6 + Math.random() * 0.25);
    }

    function advance(capsule, dt) {
      capsule.t += dt;
      const done = capsule.t >= capsule.span;
      const progress = capsule.span ? capsule.t / capsule.span : 1;
      switch (capsule.phase) {
        case 'rest':
          if (done) act(capsule);
          break;
        case 'stretch':
          capsule.b = capsule.from + (capsule.to - capsule.from) * spring(progress);
          if (done) {
            capsule.b = capsule.to;
            begin(capsule, 'hold', 0.05 + Math.random() * 0.15);
          }
          break;
        case 'hold':
          if (!done) break;
          if (capsule.b - capsule.keep > capsule.a) {
            capsule.from = capsule.a;
            capsule.to = capsule.b - capsule.keep;
            begin(capsule, 'contract', capsule.eager ? 0.42 : 0.6 + Math.random() * 0.25);
          } else {
            rest(capsule);
          }
          break;
        case 'contract':
          capsule.a = capsule.from + (capsule.to - capsule.from) * spring(progress);
          if (done) {
            capsule.a = capsule.to;
            rest(capsule);
          }
          break;
        case 'sink':
          capsule.w = Math.min(capsule.w, Math.max(0, 1 - progress * progress));
          if (done) {
            capsule.w = 0;
            begin(capsule, relocate(capsule) ? 'cue' : 'limbo', 0.2 + Math.random() * 0.5);
          }
          break;
        case 'limbo':
          if (done) begin(capsule, relocate(capsule) ? 'cue' : 'limbo', 0.6);
          break;
        case 'cue':
          if (done) begin(capsule, 'rise', 0.6);
          break;
        case 'rise':
          capsule.w = spring(progress);
          if (done) {
            capsule.w = 1;
            rest(capsule, capsule.logo ? 1.6 : 1.2);
            if (capsule.logo) capsule.span += 3.4;
          }
          break;
      }
    }

    function assemble() {
      const target = stage();
      if (!target) return [];
      const cx = (target.left + target.right) / 2;
      const cy = (target.top + target.bottom) / 2;
      let best = null;
      for (let lane = 0; lane + 2 < lanes.length; lane++) {
        const shift = lane & 1;
        const [top, middle, bottom] = [lanes[lane].open, lanes[lane + 1].open, lanes[lane + 2].open];
        for (let cell = 0; cell + 2 < top.length; cell++) {
          const fits =
            top[cell] && top[cell + 1] && top[cell + 2] && middle[cell + shift] && middle[cell + shift + 1] && bottom[cell + 1];
          if (!fits) continue;
          const [x, y] = point(lane + 1, cell + shift + 0.5);
          const distance = (x - cx) ** 2 + (y - cy) ** 2;
          if (!best || distance < best.distance) best = { lane, cell, shift, distance };
        }
      }
      if (!best) return [];
      const { lane, cell, shift } = best;
      return [
        { lane, a: cell, b: cell + 2, keep: 2, logo: 1 },
        { lane: lane + 1, a: cell + shift, b: cell + shift + 1, keep: 1, logo: 2 },
        { lane: lane + 2, a: cell + 1, b: cell + 1, keep: 0, logo: 3 },
      ];
    }

    function seed(intro) {
      capsules = [];
      const create = (shape, delay) => {
        const capsule = { color: pick(PALETTE), logo: 0, w: 1, eager: false, from: 0, to: 0, ...shape };
        capsules.push(capsule);
        if (intro) {
          capsule.w = 0;
          begin(capsule, 'cue', delay);
        } else {
          rest(capsule);
        }
      };
      assemble().forEach((shape) => create(shape, 0.95 - shape.logo * 0.13));
      const busy = lanes.map((lane, index) => (lane.runs.length ? index : -1)).filter((index) => index >= 0);
      const total = clamp(Math.round(busy.length * 0.62), 0, width < 700 ? 16 : 30);
      for (let attempt = 0; capsules.length < total && attempt < total * 6; attempt++) {
        const lane = pick(busy);
        const [from, to] = pick(lanes[lane].runs);
        const head = from + Math.floor(Math.random() * (to - from + 1));
        const keep = pick(LENGTHS);
        const tail = Math.max(from, head - keep);
        if (claimed(lane, head, null) || claimed(lane, tail, null)) continue;
        create({ lane, a: tail, b: head, keep }, 0.25 + (point(lane, head)[0] / width) * 0.8 + Math.random() * 0.3);
      }
    }

    function draw() {
      ctx.clearRect(0, 0, width, height);
      ctx.lineCap = 'round';
      for (const capsule of capsules) {
        if (capsule.w < 0.02) continue;
        const [x1, y1] = point(capsule.lane, capsule.a);
        const [x2, y2] = point(capsule.lane, capsule.b);
        ctx.strokeStyle = capsule.logo ? logoColors[capsule.logo - 1] : colors[capsule.color];
        ctx.lineWidth = pitch * THICKNESS * capsule.w;
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2 + 0.01, y2);
        ctx.stroke();
      }
    }

    function stir() {
      const box = canvas.getBoundingClientRect();
      const x = pointer.x - box.left;
      const y = pointer.y - box.top;
      pointer = null;
      for (const capsule of capsules) {
        if (capsule.phase !== 'rest') continue;
        const [x1, y1] = point(capsule.lane, capsule.a);
        const [x2, y2] = point(capsule.lane, capsule.b);
        const reach = pitch * 1.3 + Math.hypot(x2 - x1, y2 - y1) / 2;
        if (Math.hypot((x1 + x2) / 2 - x, (y1 + y2) / 2 - y) > reach) continue;
        capsule.t = capsule.span;
        capsule.eager = true;
      }
    }

    function tick(now) {
      frame = requestAnimationFrame(tick);
      const dt = Math.min((now - last) / 1000, 0.05) * tempo;
      last = now;
      tempo += (1 - tempo) * Math.min(1, dt * 2.5);
      if (pointer) stir();
      let moving = false;
      for (const capsule of capsules) {
        advance(capsule, dt);
        if (capsule.phase !== 'rest' && capsule.phase !== 'cue' && capsule.phase !== 'limbo') moving = true;
      }
      if (moving || dirty) draw();
      dirty = moving;
    }

    function sync() {
      const run = onScreen && !document.hidden && !still();
      if (run && !frame) {
        last = performance.now();
        frame = requestAnimationFrame(tick);
      } else if (!run && frame) {
        cancelAnimationFrame(frame);
        frame = 0;
      }
    }

    function rebuild(intro) {
      measure();
      chart();
      tint();
      seed(intro && !still());
      draw();
    }

    function refresh() {
      chart();
      tint();
      if (still()) {
        seed(false);
      } else {
        for (const capsule of capsules) {
          if (capsule.phase === 'sink' || capsule.phase === 'limbo') continue;
          const { open } = lanes[capsule.lane] || { open: [] };
          const from = Math.floor(capsule.a);
          const to = Math.ceil(capsule.phase === 'stretch' ? capsule.to : capsule.b);
          let clear = true;
          for (let cell = from; cell <= to; cell++) clear = clear && open[cell];
          if (clear) continue;
          if (capsule.phase !== 'cue') begin(capsule, 'sink', 0.2);
          else if (!relocate(capsule)) begin(capsule, 'limbo', 0.6);
        }
      }
      draw();
      dirty = true;
      sync();
    }

    function surge() {
      for (const capsule of capsules) {
        if (capsule.phase !== 'rest') continue;
        capsule.span = capsule.t + (point(capsule.lane, capsule.b)[0] / width) * 0.45;
        capsule.eager = true;
      }
    }

    rebuild(true);

    if ('ResizeObserver' in window) {
      new ResizeObserver(() => {
        const box = canvas.getBoundingClientRect();
        if (Math.abs(box.width - width) > 1) {
          rebuild(false);
        } else if (Math.abs(box.height - height) > 1) {
          measure();
          refresh();
        }
      }).observe(canvas);
    }
    if ('IntersectionObserver' in window) {
      new IntersectionObserver(([entry]) => {
        onScreen = entry.isIntersecting;
        sync();
      }).observe(canvas);
    }
    document.addEventListener('visibilitychange', sync);
    addEventListener(
      'pointermove',
      (event) => {
        if (event.pointerType === 'mouse' && frame) pointer = { x: event.clientX, y: event.clientY };
      },
      { passive: true },
    );
    addEventListener(
      'scroll',
      () => {
        const now = performance.now();
        const speed = (Math.abs(scrollY - scrollAt.y) / Math.max(now - scrollAt.time, 8)) * 1000;
        scrollAt = { y: scrollY, time: now };
        tempo = Math.max(tempo, 1 + Math.min(speed / 700, 2.4));
      },
      { passive: true },
    );
    sync();

    return { refresh, surge };
  }

  return { mount };
})();
