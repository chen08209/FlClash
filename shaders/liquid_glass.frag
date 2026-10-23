#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

// The texture's size; the order of the rest is the order in which
// _LiquidGlassLayer in lib/ui/liquid_glass.dart writes them.
uniform vec2 uSize;
// Glass coordinates, in dp from its top left, of FlutterFragCoord: an origin,
// then a scale per unit.
uniform vec4 uFrame;
// Glass coordinates of the texture's pixels, as uFrame.
uniform vec4 uSample;
// The first and last pixel centers the pane may read, as a capture holds the
// backdrops of other panes beside its own.
uniform vec4 uClamp;
// Dp per device pixel, and the frost sigma in its own pixels the texture
// already holds, as a capture is blurred before any pane reads it.
uniform vec2 uTexels;
// As uSample and uClamp, for a capture blurred by the style's haze, and the
// share of the backdrop seen through it.
uniform vec4 uHazeSample;
uniform vec4 uHazeClamp;
uniform float uHaze;
// Width, height, bevel width, frost sigma.
uniform vec4 uShape;
// Corner radii: top left, top right, bottom right, bottom left.
uniform vec4 uCorners;
// The superellipse corners the pane is clipped to, three to a corner in the
// order of uCorners: n, J and the arc's radius for the octant along the top or
// bottom, the same for the one along the side, then both arcs' centers. A
// sharp corner has n 0.
uniform vec4 uCurves[12];
// Refraction depth at the rim, saturation, brightness. A negative depth makes
// a raised lens, which bends outward on UIKit's profile.
uniform vec3 uOptics;
// Straight alpha.
uniform vec4 uTint;
// Highlight along the top and bottom of the rim, the dp it fades over, how
// much a lens's rounded ends darken.
uniform vec3 uLight;
// Glow center, glow strength, how far the tint thickens over content much
// darker than it, or when negative much lighter.
uniform vec4 uGlow;
// How far the glow reaches, and the share of it spread over the whole pane.
uniform vec2 uGlowSpread;
// How much the dark line around the rim darkens the backdrop, how far apart in
// dp the color channels part along the rim, and the frost sigma the rim adds
// at its edge, easing off across the bevel.
uniform vec3 uEdge;
// The highlight's share in a faint tail kRimTail long, how far its fall
// round rounded ends goes from the tab bar's to iOS 27 controls', and its
// share added as light rather than screened; then the line at the sides.
uniform vec4 uRim;
// Above 0.5 the pane takes the outline of uProfile in place of its corners,
// above 1.5 that of uPills.
uniform float uOutlined;
// The outline's distance from the center along 64 even turns, the first
// toward +x and the rest toward +y, four to a vector.
uniform vec4 uProfile[16];
// A menu's highlight (LiquidGlassRim): light added at eight turns from the
// vertical through the center, rising from 0 to a right angle, and across
// bands inward from the rim, where each ends in dp and its share.
uniform vec4 uShineTurns[2];
uniform vec4 uShineLit[2];
uniform vec4 uShineEnds[3];
uniform vec4 uShineShares[3];
// Pills in rows, each from the left, as GooSurface in lib/ui/goo.dart lays
// them out: center and half size each, in glass coordinates.
uniform vec4 uPills[6];
// How many of uPills there are, then how far apart each flows into the one
// before it, from the second on, 0 across rows.
uniform vec4 uGoo[2];
// Each pill's superellipse along its long sides, as uCurves holds a corner's
// octant: n, J and the arc's radius, then the arcs' centers two to a vector.
uniform vec4 uPillCurves[6];
uniform vec4 uPillCenters[3];
uniform sampler2D uTexture;

out vec4 fragColor;

const vec3 kLuma = vec3(0.2126, 0.7152, 0.0722);
const float kTau = 6.28318530718;
const float kTurns = 64.0;
// Fewer taps leave a swirl over sharp text; 64 leave a faint one at 3x, too
// fine to see. A count taken from a uniform costs as much as 96 constant taps,
// so a narrower frost takes a constant count of its own, its taps no further
// apart than 64 leave those of the widest.
const int kFrostTaps = 64;
const float kGoldenAngle = 2.39996322973;
// 1.2 times the engine's kernel reach of (sigma - 0.5) * sqrt(3) pixels, which
// on a Vogel disc fits its blur best.
const float kFrostReach = 2.07846096908;
// Measured on iOS 27: the width of the dark line in dp and the most it takes
// off a channel of the backdrop.
const float kLine = 0.67;
const float kLineCap = 0.298;
// The most the engine's superellipse corner lies inside a circular one, as a
// share of the radius, with room to spare over the 1.8% it reaches.
const float kCornerGap = 0.03;
// How far in dp a lens's ends darken in from the rim.
const float kEndShade = 3.0;
// How far in dp from the rim the color channels part, and where they start
// to close: iOS parts them nearly as far across a lens's band as at its rim.
const float kPartReach = 10.0;
const float kPartHold = 7.0;
// Measured on iOS 27 controls: how far in dp the highlight's tail reaches.
const float kRimTail = 4.5;
// A frost this wide in dp reads the backdrop's luma once, as a haze does.
const float kSteadyFrost = 8.0;

vec4 texel(vec2 pixel) {
  return texture(
    uTexture,
    clamp(pixel, uClamp.xy, min(uClamp.zw, uSize - 0.5)) / uSize
  );
}

vec4 sampleGlass(vec2 point) {
  return texel((point - uSample.xy) / uSample.zw);
}

vec4 sampleHaze(vec2 point) {
  vec2 pixel = (point - uHazeSample.xy) / uHazeSample.zw;
  return texture(
    uTexture,
    clamp(pixel, uHazeClamp.xy, min(uHazeClamp.zw, uSize - 0.5)) / uSize
  );
}

#define FROST_DISC(taps)                                                     \
  float decay = exp(-falloff / float(taps));                                  \
  float weight = sqrt(decay);                                                 \
  vec2 turn = vec2(cos(kGoldenAngle), sin(kGoldenAngle));                     \
  vec2 ray = vec2(1.0, 0.0);                                                  \
  vec4 sum = vec4(0.0);                                                       \
  float total = 0.0;                                                          \
  for (int i = 0; i < taps; i++) {                                            \
    float spread = sqrt((float(i) + 0.5) / float(taps));                      \
    sum += texel(center + ray * reach * spread) * weight;                     \
    total += weight;                                                          \
    weight *= decay;                                                          \
    ray = vec2(ray.x * turn.x - ray.y * turn.y, ray.x * turn.y + ray.y * turn.x); \
  }                                                                           \
  return sum / total;

vec4 frostDisc16(vec2 center, vec2 reach, float falloff) {
  FROST_DISC(16)
}

vec4 frostDisc32(vec2 center, vec2 reach, float falloff) {
  FROST_DISC(32)
}

vec4 frostDisc64(vec2 center, vec2 reach, float falloff) {
  FROST_DISC(kFrostTaps)
}

// The engine's Gaussian of a frost sigma in device pixels, past what the
// texture holds, read on a Vogel disc.
vec4 sampleFrosted(vec2 point, float frost) {
  vec2 sigma = frost / uSample.zw;
  sigma = sqrt(max(sigma * sigma - uTexels.y * uTexels.y, vec2(0.0)));
  vec2 reach = max(sigma - 0.5, 0.0) * kFrostReach;
  if (reach.x <= 0.0 || reach.y <= 0.0) {
    return sampleGlass(point);
  }
  vec2 ratio = reach / sigma;
  float falloff = 0.5 * ratio.x * ratio.y;
  vec2 center = (point - uSample.xy) / uSample.zw;
  float widest = max(sigma.x, sigma.y);
  if (widest <= 2.0) {
    return frostDisc16(center, reach, falloff);
  }
  if (widest <= 3.5) {
    return frostDisc32(center, reach, falloff);
  }
  return frostDisc64(center, reach, falloff);
}

// Its taps sit a frost sigma apart, so that a glyph passing under one point
// does not flicker the tint; a haze or a wide frost is blurred enough to read
// once.
vec4 sampleBehind(vec2 point) {
  if (uHaze > 0.0) {
    return sampleHaze(point);
  }
  if (uShape.w >= kSteadyFrost) {
    return sampleGlass(point);
  }
  vec2 spread = vec2(uShape.w, -uShape.w);
  return 0.25 * (sampleGlass(point + spread.xx)
      + sampleGlass(point + spread.yy)
      + sampleGlass(point + spread.xy)
      + sampleGlass(point + spread.yx));
}

float roundedBoxDistance(vec2 p, vec2 halfSize, float radius) {
  vec2 q = abs(p) - halfSize + radius;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

vec2 roundedBoxNormal(vec2 p, vec2 halfSize, float radius) {
  vec2 q = abs(p) - halfSize + radius;
  vec2 n = q.x > 0.0 && q.y > 0.0
      ? normalize(q)
      : (q.x > q.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
  return n * vec2(p.x < 0.0 ? -1.0 : 1.0, p.y < 0.0 ? -1.0 : 1.0);
}

// How far inside one octant of the engine's rounded superellipse a point lies,
// in the octant's frame (impeller/geometry/round_superellipse_param.cc): a
// superellipse of half side a up to J, then a circular arc. Close to exact
// only within a few dp of the curve.
float octantInset(vec2 point, float a, vec4 curve, vec2 center) {
  vec2 fromCenter = point - center;
  vec2 toJoint = curve.yz - center;
  if (toJoint.x * fromCenter.y < toJoint.y * fromCenter.x) {
    return curve.w - length(fromCenter);
  }
  float n = curve.x;
  vec2 s = max(point, 0.0) / a;
  float major = max(max(s.x, s.y), 1e-4);
  float norm = major * pow(1.0 + pow(min(s.x, s.y) / major, n), 1.0 / n);
  vec2 slope = pow(s / norm, vec2(n - 1.0));
  return a * (1.0 - norm) / max(length(slope), 1e-4);
}

// A corner's quadrant lies about the pane's center, as the engine lays it when
// all corners are alike, and its octants part along the diagonal through where
// their arcs meet, half the difference of the sides off center.
float cornerInset(vec2 p, vec2 halfSize) {
  vec2 side = step(0.0, p);
  vec4 along = mix(
    mix(uCurves[0], uCurves[3], side.x),
    mix(uCurves[9], uCurves[6], side.x),
    side.y
  );
  vec4 across = mix(
    mix(uCurves[1], uCurves[4], side.x),
    mix(uCurves[10], uCurves[7], side.x),
    side.y
  );
  vec4 centers = mix(
    mix(uCurves[2], uCurves[5], side.x),
    mix(uCurves[11], uCurves[8], side.x),
    side.y
  );
  vec2 q = abs(p);
  if (along.x < 2.0) {
    return min(halfSize.x - q.x, halfSize.y - q.y);
  }
  float c = halfSize.x - halfSize.y;
  if (q.y + c >= q.x) {
    return octantInset(vec2(q.x, q.y + c), halfSize.x, along, centers.xy);
  }
  return octantInset(vec2(q.y, q.x - c), halfSize.y, across, centers.zw);
}

// Adds one sample of the profile to the radius at turn u and its slope, by
// the Catmull-Rom (Keys) kernel, which crosses the samples smoothly.
void addTurn(float u, float index, float radius, inout vec2 sum) {
  float x = u - index;
  x -= kTurns * floor(x / kTurns + 0.5);
  float d = abs(x);
  if (d >= 2.0) {
    return;
  }
  vec2 weight = d < 1.0
      ? vec2((1.5 * d - 2.5) * d * d + 1.0, (4.5 * d - 5.0) * d)
      : vec2(((-0.5 * d + 2.5) * d - 4.0) * d + 2.0, (-1.5 * d + 5.0) * d - 4.0);
  sum += radius * vec2(weight.x, weight.y * sign(x));
}

// The distance inward from a star-shaped outline and its outward normal,
// both taken at the outline where the point's direction from the center
// meets it, so they hold steady all the way in.
void outlineGeometry(vec2 p, out float inset, out vec2 normal) {
  float len = max(length(p), 1e-3);
  float turn = atan(p.y, p.x) / kTau;
  float u = (turn - floor(turn)) * kTurns;
  vec2 sum = vec2(0.0);
  for (int i = 0; i < 16; i++) {
    vec4 radii = uProfile[i];
    float index = float(i) * 4.0;
    addTurn(u, index, radii.x, sum);
    addTurn(u, index + 1.0, radii.y, sum);
    addTurn(u, index + 2.0, radii.z, sum);
    addTurn(u, index + 3.0, radii.w, sum);
  }
  float reach = max(sum.x, 1e-3);
  float slope = sum.y * kTurns / kTau / reach;
  vec2 radial = p / len;
  vec2 gradient = radial - slope * vec2(-radial.y, radial.x);
  float stretch = length(gradient);
  inset = max((reach - len) / stretch, 0.0);
  normal = gradient / stretch;
}

// How far inside a pill of the engine's superellipse a point lies, q taken
// from its center and its long sides along x. Its ends are the circles an
// octant whose side is its radius makes.
float pillInset(vec2 q, vec2 halfSize, vec4 curve, vec2 center) {
  float c = halfSize.x - halfSize.y;
  if (q.y + c < q.x) {
    return halfSize.y - length(q - vec2(c, 0.0));
  }
  return octantInset(vec2(q.x, q.y + c), halfSize.x, curve, center);
}

// The distance inward from pills flowing together and its outward normal,
// both blended by a polynomial smooth minimum of the pills' own. The edge
// keeps to the superellipse of the nearest pill within traced of its rim, as
// the outline drawn on the CPU does where they do not flow together.
void gooGeometry(
  vec2 p,
  float traced,
  out float inset,
  out vec2 normal,
  out float edge
) {
  float d = 1e4;
  vec2 n = vec2(0.0, -1.0);
  float nearest = 1e4;
  float lost = 0.0;
  for (int i = 0; i < 6; i++) {
    if (float(i) < uGoo[0].x) {
      vec4 pill = uPills[i];
      vec2 q = p - pill.xy;
      float radius = min(pill.z, pill.w);
      float di = roundedBoxDistance(q, pill.zw, radius);
      vec2 ni = roundedBoxNormal(q, pill.zw, radius);
      if (di < nearest) {
        nearest = di;
        lost = 0.0;
        if (traced > 0.0 && -di < traced + uTexels.x + kCornerGap * radius) {
          vec4 centers = uPillCenters[i / 2];
          bool wide = pill.z >= pill.w;
          lost = max(
            -di - pillInset(
              wide ? abs(q) : abs(q.yx),
              wide ? pill.zw : pill.wz,
              uPillCurves[i],
              i - i / 2 * 2 == 0 ? centers.xy : centers.zw
            ),
            0.0
          );
        }
      }
      float k = max(
        i == 1 ? uGoo[0].y
            : i == 2 ? uGoo[0].z
            : i == 3 ? uGoo[0].w
            : i == 4 ? uGoo[1].x
            : uGoo[1].y,
        1e-3
      );
      float h = i == 0 ? 0.0 : clamp(0.5 + 0.5 * (di - d) / k, 0.0, 1.0);
      d = mix(di, d, h) - k * h * (1.0 - h);
      vec2 m = mix(ni, n, h);
      n = dot(m, m) > 1e-8 ? normalize(m) : n;
    }
  }
  inset = max(-d, 0.0);
  normal = n;
  edge = max(inset - max(lost - (nearest - d), 0.0), 0.0);
}

// The highlight's bands over depths a to b in from the rim, on average.
float shineAcross(float a, float b) {
  float sum = 0.0;
  float start = 0.0;
  for (int i = 0; i < 3; i++) {
    vec4 ends = uShineEnds[i];
    vec4 starts = vec4(start, ends.xyz);
    sum += dot(
      uShineShares[i],
      max(min(vec4(b), ends) - max(vec4(a), starts), 0.0)
    );
    start = ends.w;
  }
  return sum / max(b - a, 1e-4);
}

// The highlight's brightness a turn from the vertical, as the sweep the
// fallback draws it with lays it out.
float shineAround(float turn) {
  vec4 startTurns = uShineTurns[0];
  vec4 lastTurns = uShineTurns[1];
  vec4 startLit = uShineLit[0];
  vec4 lastLit = uShineLit[1];
  vec4 firstEnds = vec4(startTurns.yzw, lastTurns.x);
  vec3 lastEnds = lastTurns.yzw;
  vec4 firstRise = vec4(startLit.yzw, lastLit.x) - startLit;
  vec3 lastRise = lastLit.yzw - lastLit.xyz;
  return startLit.x
      + dot(firstRise, clamp(
          (turn - startTurns) / max(firstEnds - startTurns, 1e-5), 0.0, 1.0))
      + dot(lastRise, clamp(
          (turn - lastTurns.xyz) / max(lastEnds - lastTurns.xyz, 1e-5),
          0.0,
          1.0
        ));
}

void main() {
  vec2 point = uFrame.xy + FlutterFragCoord().xy * uFrame.zw;
  vec2 halfSize = uShape.xy * 0.5;
  float halfMinor = min(halfSize.x, halfSize.y);
  vec2 centered = point - halfSize;
  float inset;
  vec2 normal;
  // The inset of the line and the highlight. A pane is clipped to the engine's
  // superellipse, up to half a dp inside its circular corners where a long side
  // runs into them, and they keep to it; the optics read deeper than its inset
  // holds true, so they keep the circles. Only the band the line and the
  // highlight can reach works it out.
  float edge;
  bool lit = uEdge.x > 0.0 || uRim.w > 0.0 || uLight.x > 0.0;
  float traced = max(
    lit ? kLine + uLight.y : 0.0,
    uShineLit[0].x > 0.0 ? uShineEnds[2].w : 0.0
  );
  if (uOutlined > 1.5) {
    gooGeometry(point, traced, inset, normal, edge);
  } else if (uOutlined > 0.5) {
    outlineGeometry(centered, inset, normal);
    edge = inset;
  } else {
    vec2 side = step(0.0, centered);
    float radius = min(
      mix(
        mix(uCorners.x, uCorners.y, side.x),
        mix(uCorners.w, uCorners.z, side.x),
        side.y
      ),
      halfMinor
    );
    inset = max(-roundedBoxDistance(centered, halfSize, radius), 0.0);
    normal = roundedBoxNormal(centered, halfSize, radius);
    edge = inset;
    if (traced > 0.0 && inset < traced + uTexels.x + kCornerGap * radius) {
      edge = max(cornerInset(centered, halfSize), 0.0);
    }
  }

  bool lens = uOptics.x < 0.0;
  float bevel = max(min(uShape.z, halfMinor * 0.5), 1e-3);
  float rise = 1.0 - clamp(inset / bevel, 0.0, 1.0);
  vec2 shift;
  if (lens) {
    // As measured on iOS 27, the raised lens reads outward along its normal
    // all around, by nothing at the rim and its full depth a bevel in, so its
    // outer band draws out what lies right under the rim; the depth then eases
    // off toward the middle.
    shift = normal * -uOptics.x * smoothstep(0.0, bevel, inset)
        * (1.0 - smoothstep(bevel, halfMinor, inset));
  } else {
    // A bevel of circular profile, fitted to small panes: flat where it meets
    // the face and steepening toward the rim, which reads from so far inside
    // that its outermost band shows the content squeezed and mirrored.
    float depth = min(uOptics.x, halfMinor) * (1.0 - sqrt(1.0 - rise * rise));
    shift = -normal * depth;
  }

  float frost = uShape.w + uEdge.z * rise * rise;
  vec4 base = sampleFrosted(point + shift, frost);
  if (uEdge.y > 0.0 && inset < kPartReach) {
    // iOS 27 parts red from blue along the normal's mirror image, across it
    // at the sides and along it at the corners. Along the top and bottom the
    // parting narrows from the rim to what it holds around the ends. Over
    // clear glass a channel shows past the others, so the cover is the widest
    // of them.
    vec2 part = normal.yx * 0.5 * uEdge.y
        * (0.6 + 0.4 * abs(normal.y) * max(1.0 - inset / kPartHold, 0.0))
        * (1.0 - smoothstep(kPartHold, kPartReach, inset));
    vec4 red = sampleFrosted(point + shift + part, frost);
    vec4 blue = sampleFrosted(point + shift - part, frost);
    base = vec4(red.r, base.g, blue.b, max(base.a, max(red.a, blue.a)));
  }
  if (uHaze > 0.0) {
    base = mix(base, sampleHaze(point + shift), uHaze);
  }
  float alpha = base.a;
  vec3 color = base.rgb / max(alpha, 1e-4);
  color = mix(vec3(dot(color, kLuma)), color, uOptics.y) * uOptics.z;
  color *= 1.0 - uLight.z * abs(normal.x) * exp(-inset / kEndShade);

  float clash = 0.0;
  if (uGlow.w != 0.0) {
    vec4 behind = sampleBehind(halfSize)
        + sampleBehind(halfSize * vec2(0.4, 0.6))
        + sampleBehind(halfSize * vec2(1.6, 0.6))
        + sampleBehind(halfSize * vec2(0.4, 1.4))
        + sampleBehind(halfSize * vec2(1.6, 1.4));
    float behindLuma = dot(behind.rgb / max(behind.a, 1e-4), kLuma);
    clash = clamp(
      (sign(uGlow.w) * (dot(uTint.rgb, kLuma) - behindLuma) - 0.3) / 0.5,
      0.0,
      1.0
    );
  }
  float cover = uTint.a + (1.0 - uTint.a) * clash * abs(uGlow.w);
  float coverage = alpha * (1.0 - cover) + cover;
  vec3 glass = color * alpha * (1.0 - cover) + uTint.rgb * cover;

  // iOS lights the top and bottom of its glass, just inside the line, and on
  // its tab bar fades that around the rounded ends with the normal's upward
  // part squared, out only at their tips; its controls dim far faster. All
  // screened toward white, a pale tint would clip into a flat white ring.
  // The tail reads the circular inset, as it reaches past where the edge's is
  // worked out, and moves too slowly for the difference to show.
  float within = max(edge - kLine, 0.0);
  float facing;
  if (lens) {
    facing = smoothstep(0.65, 0.95, abs(normal.y));
  } else {
    float rise2 = normal.y * normal.y;
    float rise4 = rise2 * rise2;
    float rise16 = rise4 * rise4 * rise4 * rise4;
    facing = mix(rise2, 0.5 * rise2 * abs(normal.y) * (1.0 + rise16), uRim.y);
  }
  float band = clamp(1.0 - within / max(uLight.y, 1e-3), 0.0, 1.0);
  float tail = clamp(1.0 - max(inset - kLine, 0.0) / kRimTail, 0.0, 1.0);
  float shine = min(uLight.x * facing * mix(band, tail, uRim.x), 1.0);
  glass += (vec3(coverage) - (1.0 - uRim.z) * glass) * shine;

  // iOS 27 outlines its glass with a dark line, which UIKit draws just outside
  // the bounds, over the backdrop, where the pane cannot draw, so it takes the
  // outermost pixels here. iOS draws it darkest at the sides; the dock keeps
  // it as faint all around as along the top, as its darker sides read as
  // brackets.
  float line = clamp((kLine - edge) / uTexels.x + 0.5, 0.0, 1.0);
  float across = abs(normal.x);
  float darken = mix(uEdge.x, uRim.w, across * across * across);
  if ((uEdge.x > 0.0 || uRim.w > 0.0) && line > 0.0) {
    vec4 under = sampleGlass(point);
    vec3 dark = max(under.rgb - kLineCap * under.a, 0.22 * under.rgb);
    glass = mix(glass, mix(under.rgb, dark, darken), line);
    coverage = mix(coverage, under.a, line);
  }

  vec2 toGlow = point - uGlow.xy;
  float reach = max(uGlowSpread.x * uGlowSpread.x, 1.0);
  glass += uGlow.z * coverage
      * mix(exp(-dot(toGlow, toGlow) / reach), 1.0, uGlowSpread.y);

  // A pixel the rim crosses takes the bands it covers, as the rasterizer
  // weighs the rest by its coverage.
  if (uShineLit[0].x > 0.0 && edge < uShineEnds[2].w + uTexels.x) {
    float turn = atan(abs(centered.x), abs(centered.y));
    float pixel = 0.5 * uTexels.x;
    glass += coverage * shineAround(turn)
        * shineAcross(max(edge - pixel, 0.0), edge + pixel);
  }

  fragColor = vec4(min(glass, vec3(coverage)), coverage);
}
