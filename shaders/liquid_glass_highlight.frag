// Copyright 2025 Kyant
// SPDX-License-Identifier: Apache-2.0
//
// DefaultHighlightShaderString from Kyant0/AndroidLiquidGlass 2.0.1
// backdrop/src/commonMain/kotlin/com/kyant/backdrop/internal/Shaders.kt,
// translated from AGSL to GLSL by FlClash for a Paint.shader: color is
// premultiplied and carries the paint's alpha, and radiusAt reads the
// centred coordinate.

#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 size;
uniform vec4 cornerRadii;
uniform vec4 color;
uniform float angle;
uniform float falloff;

out vec4 fragColor;

#include "rounded_rect_sdf.glsl"

void main() {
  vec2 halfSize = size * 0.5;
  vec2 centeredCoord = FlutterFragCoord().xy - halfSize;
  float radius = radiusAt(centeredCoord, cornerRadii);

  float gradRadius = min(radius * 1.5, min(halfSize.x, halfSize.y));
  vec2 grad = gradSdRoundedRect(centeredCoord, halfSize, gradRadius);
  vec2 normal = vec2(cos(angle), sin(angle));
  float d = dot(grad, normal);
  float intensity = pow(abs(d), falloff);
  fragColor = color * intensity;
}
