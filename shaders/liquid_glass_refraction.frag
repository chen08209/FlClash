// Copyright 2025 Kyant
// SPDX-License-Identifier: Apache-2.0
//
// RoundedRectRefractionShaderString from Kyant0/AndroidLiquidGlass 2.0.1
// backdrop/src/commonMain/kotlin/com/kyant/backdrop/internal/Shaders.kt,
// translated from AGSL to GLSL by FlClash for ImageFilter.shader: content
// is a sampler of the backdrop in input pixels, offset is minus the shape's
// origin in them, radiusAt reads the centred coordinate, and depthEffect is
// dropped because LiquidBottomTabs never sets it.

#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 inputSize;
uniform vec2 size;
uniform vec2 offset;
uniform vec4 cornerRadii;
uniform float refractionHeight;
uniform float refractionAmount;
uniform sampler2D content;

out vec4 fragColor;

#include "rounded_rect_sdf.glsl"

vec4 texelAt(vec2 centre) {
  return texture(content, centre / inputSize);
}

// Impeller binds the filter input with a nearest sampler, where Skia's
// RenderEffect filters it linearly.
vec4 contentAt(vec2 coord) {
  vec2 p = coord - 0.5;
  vec2 f = fract(p);
  vec2 b = floor(p) + 0.5;
  return mix(
      mix(texelAt(b), texelAt(b + vec2(1.0, 0.0)), f.x),
      mix(texelAt(b + vec2(0.0, 1.0)), texelAt(b + vec2(1.0, 1.0)), f.x),
      f.y);
}

float circleMap(float x) {
  return 1.0 - sqrt(1.0 - x * x);
}

void main() {
  vec2 coord = FlutterFragCoord().xy;
  // A lens at a sub-pixel offset puts coord off the texel grid; refracting
  // from the texel a nearest read returns keeps the unbent interior sharp.
  vec2 texel = floor(coord) + 0.5;
  vec2 halfSize = size * 0.5;
  vec2 centeredCoord = (coord + offset) - halfSize;
  float radius = radiusAt(centeredCoord, cornerRadii);

  float sd = sdRoundedRect(centeredCoord, halfSize, radius);
  if (-sd >= refractionHeight) {
    fragColor = texelAt(texel);
    return;
  }
  sd = min(sd, 0.0);

  float d = circleMap(1.0 - -sd / refractionHeight) * refractionAmount;
  float gradRadius = min(radius * 1.5, min(halfSize.x, halfSize.y));
  vec2 grad = normalize(gradSdRoundedRect(centeredCoord, halfSize, gradRadius));

  vec2 refractedCoord = texel + d * grad;
  fragColor = contentAt(refractedCoord);
}
