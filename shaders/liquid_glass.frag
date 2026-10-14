#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

// Filled by the engine; the order of the rest is the order in which
// _LiquidGlassLayer in lib/ui/liquid_glass.dart writes them.
uniform vec2 uSize;
// Glass coordinates, in dp from its top left, of FlutterFragCoord: an origin,
// then a scale per pixel.
uniform vec4 uFrame;
// Width, height, bevel width, frost sigma.
uniform vec4 uShape;
// Corner radii: top left, top right, bottom right, bottom left.
uniform vec4 uCorners;
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
// How much the dark line around the rim darkens the backdrop, and how far
// apart a lens bends the color channels.
uniform vec2 uEdge;
// Above 0.5 the pane takes the outline of uProfile in place of its corners.
uniform float uOutlined;
// The outline's distance from the center along 64 even turns, the first
// toward +x and the rest toward +y, four to a vector.
uniform vec4 uProfile[16];
uniform sampler2D uTexture;

out vec4 fragColor;

const vec3 kLuma = vec3(0.2126, 0.7152, 0.0722);
const float kTau = 6.28318530718;
const float kTurns = 64.0;
// Fewer taps leave a swirl over sharp text; 64 leave a faint one at 3x, too
// fine to see. A count taken from a uniform costs as much as 96 constant taps.
const int kFrostTaps = 64;
const float kGoldenAngle = 2.39996322973;
// 1.2 times the engine's kernel reach of (sigma - 0.5) * sqrt(3) pixels, which
// on a Vogel disc fits its blur best.
const float kFrostReach = 2.07846096908;
// Measured on iOS 27: the width of the dark line in dp and the most it takes
// off a channel of the backdrop.
const float kLine = 0.67;
const float kLineCap = 0.298;
// How far in dp a lens's ends darken in from the rim. iOS holds its shade flat
// for 6 dp, which on pale glass joins the crescents into a ring.
const float kEndShade = 3.0;

vec4 texel(vec2 pixel) {
  return texture(uTexture, clamp(pixel, vec2(0.5), uSize - 0.5) / uSize);
}

vec4 sampleGlass(vec2 point, vec2 scale) {
  return texel((point - uFrame.xy) / scale);
}

// The engine's Gaussian of the frost sigma in device pixels, read on a Vogel
// disc: an engine blur under a shader filter would blur the whole surface.
vec4 sampleFrosted(vec2 point, vec2 scale) {
  vec2 sigma = uShape.w / scale;
  vec2 reach = max(sigma - 0.5, 0.0) * kFrostReach;
  if (reach.x <= 0.0 || reach.y <= 0.0) {
    return sampleGlass(point, scale);
  }
  vec2 ratio = reach / sigma;
  float falloff = 0.5 * ratio.x * ratio.y;
  float decay = exp(-falloff / float(kFrostTaps));
  float weight = sqrt(decay);
  vec2 center = (point - uFrame.xy) / scale;
  vec2 turn = vec2(cos(kGoldenAngle), sin(kGoldenAngle));
  vec2 ray = vec2(1.0, 0.0);
  vec4 sum = vec4(0.0);
  float total = 0.0;
  for (int i = 0; i < kFrostTaps; i++) {
    float spread = sqrt((float(i) + 0.5) / float(kFrostTaps));
    sum += texel(center + ray * reach * spread) * weight;
    total += weight;
    weight *= decay;
    ray = vec2(ray.x * turn.x - ray.y * turn.y, ray.x * turn.y + ray.y * turn.x);
  }
  return sum / total;
}

// Its taps sit a frost sigma apart, so that a glyph passing under one point
// does not flicker the tint.
vec4 sampleBehind(vec2 point, vec2 scale) {
  vec2 spread = vec2(uShape.w, -uShape.w);
  return 0.25 * (sampleGlass(point + spread.xx, scale)
      + sampleGlass(point + spread.yy, scale)
      + sampleGlass(point + spread.xy, scale)
      + sampleGlass(point + spread.yx, scale));
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

void main() {
  vec2 scale = uFrame.zw;
  vec2 point = uFrame.xy + FlutterFragCoord().xy * scale;
  vec2 halfSize = uShape.xy * 0.5;
  float halfMinor = min(halfSize.x, halfSize.y);
  vec2 centered = point - halfSize;
  float inset;
  vec2 normal;
  if (uOutlined > 0.5) {
    outlineGeometry(centered, inset, normal);
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
  }

  bool lens = uOptics.x < 0.0;
  float bevel = max(min(uShape.z, halfMinor * 0.5), 1e-3);
  float rise = 1.0 - clamp(inset / bevel, 0.0, 1.0);
  vec2 shift;
  if (lens) {
    // UIKit's raised lens reads from outside its rim, steeply near it. On iOS
    // only its top and bottom do, less toward its ends, so the bands of
    // backdrop they show taper into the rim and none rings its ends.
    float depth = min(
      bevel * rise / sqrt(max(1.0 - rise * rise, 1e-4)),
      -uOptics.x
    );
    float across = centered.x / halfSize.x;
    shift = normal * depth * smoothstep(0.85, 1.0, abs(normal.y))
        * (1.0 - across * across);
  } else {
    // A bevel of circular profile, fitted to small panes: flat where it meets
    // the face and steepening toward the rim, which reads from so far inside
    // that its outermost band shows the content squeezed and mirrored.
    float depth = min(uOptics.x, halfMinor) * (1.0 - sqrt(1.0 - rise * rise));
    shift = -normal * depth;
  }

  vec4 base = sampleFrosted(point + shift, scale);
  if (uEdge.y > 0.0) {
    base.r = sampleFrosted(point + shift * (1.0 - uEdge.y), scale).r;
    base.b = sampleFrosted(point + shift * (1.0 + uEdge.y), scale).b;
  }
  float alpha = base.a;
  vec3 color = base.rgb / max(alpha, 1e-4);
  color = mix(vec3(dot(color, kLuma)), color, uOptics.y) * uOptics.z;
  color *= 1.0 - uLight.z * abs(normal.x) * exp(-inset / kEndShade);

  float clash = 0.0;
  if (uGlow.w != 0.0) {
    vec4 behind = sampleBehind(halfSize, scale)
        + sampleBehind(halfSize * vec2(0.4, 0.6), scale)
        + sampleBehind(halfSize * vec2(1.6, 0.6), scale)
        + sampleBehind(halfSize * vec2(0.4, 1.4), scale)
        + sampleBehind(halfSize * vec2(1.6, 1.4), scale);
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

  // iOS lights only the top and bottom of its glass, just inside the line. It
  // screens toward white rather than adding, which would clip a pale tint
  // into a flat white ring.
  float within = max(inset - kLine, 0.0);
  float shine = uLight.x * smoothstep(0.65, 0.95, abs(normal.y))
      * clamp(1.0 - within / max(uLight.y, 1e-3), 0.0, 1.0);
  glass += (vec3(coverage) - glass) * min(shine, 1.0);

  // iOS 27 outlines its glass with a dark line, which UIKit draws just outside
  // the bounds, over the backdrop, where a clipped filter cannot reach, so it
  // takes the outermost pixels here. It is as faint all around as iOS draws it
  // along the top and bottom: the darker sides iOS draws read as brackets.
  float pixel = max(scale.x, scale.y);
  float line = clamp((kLine - inset) / pixel + 0.5, 0.0, 1.0);
  if (uEdge.x > 0.0 && line > 0.0) {
    vec4 under = sampleGlass(point, scale);
    vec3 dark = max(under.rgb - kLineCap * under.a, 0.22 * under.rgb);
    glass = mix(glass, mix(under.rgb, dark, uEdge.x), line);
    coverage = mix(coverage, under.a, line);
  }

  vec2 toGlow = point - uGlow.xy;
  float reach = max(uGlowSpread.x * uGlowSpread.x, 1.0);
  glass += uGlow.z * coverage
      * mix(exp(-dot(toGlow, toGlow) / reach), 1.0, uGlowSpread.y);

  fragColor = vec4(min(glass, vec3(coverage)), coverage);
}
