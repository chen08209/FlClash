// Copyright 2025 Kyant
// SPDX-License-Identifier: Apache-2.0
//
// RoundedRectRefractionWithDispersionShaderString from
// Kyant0/AndroidLiquidGlass 2.0.1
// backdrop/src/commonMain/kotlin/com/kyant/backdrop/internal/Shaders.kt,
// translated from AGSL to GLSL by FlClash for ImageFilter.shader: content
// is a sampler of the backdrop in input pixels, offset is minus the shape's
// origin in them, radiusAt reads the centred coordinate, and depthEffect and
// chromaticAberration are fixed at the 0 and 1 LiquidBottomTabs uses.

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
  float dispersionIntensity =
      (centeredCoord.x * centeredCoord.y) / (halfSize.x * halfSize.y);
  vec2 dispersedCoord = d * grad * dispersionIntensity;

  vec4 color = vec4(0.0);

  vec4 red = contentAt(refractedCoord + dispersedCoord);
  color.r += red.r / 3.5;
  color.a += red.a / 7.0;

  vec4 orange = contentAt(refractedCoord + dispersedCoord * (2.0 / 3.0));
  color.r += orange.r / 3.5;
  color.g += orange.g / 7.0;
  color.a += orange.a / 7.0;

  vec4 yellow = contentAt(refractedCoord + dispersedCoord * (1.0 / 3.0));
  color.r += yellow.r / 3.5;
  color.g += yellow.g / 3.5;
  color.a += yellow.a / 7.0;

  vec4 green = contentAt(refractedCoord);
  color.g += green.g / 3.5;
  color.a += green.a / 7.0;

  vec4 cyan = contentAt(refractedCoord - dispersedCoord * (1.0 / 3.0));
  color.g += cyan.g / 3.5;
  color.b += cyan.b / 3.0;
  color.a += cyan.a / 7.0;

  vec4 blue = contentAt(refractedCoord - dispersedCoord * (2.0 / 3.0));
  color.b += blue.b / 3.0;
  color.a += blue.a / 7.0;

  vec4 purple = contentAt(refractedCoord - dispersedCoord);
  color.r += purple.r / 7.0;
  color.b += purple.b / 3.0;
  color.a += purple.a / 7.0;

  fragColor = color;
}
