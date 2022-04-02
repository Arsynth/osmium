//
//  ShadersCommon.h
//  Osmium
//
//  Created by Artem Sechko on 30.09.2021.
//

#ifndef ShadersCommon_h
#define ShadersCommon_h

#include <metal_stdlib>
#include <metal_atomic>
#include "ShaderTypes.h"
using namespace metal;

constant bool hasColorTexture [[function_constant(BaseColorTexture)]];
constant bool hasNormalTexture [[function_constant(NormalTexture)]];
constant bool hasAOTexture [[function_constant(AOTexture)]];
constant bool hasReflectionTextureCube [[function_constant(ReflectionTextureCube)]];

struct VertexIn {
    float4 position [[attribute(Position)]];
    float3 normal [[attribute(Normal)]];
    float2 uv [[attribute(UV)]];
    float3 tangent [[attribute(Tangent)]];
    float3 bitangent [[attribute(Bitangent)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
    float3 worldTangent;
    float3 worldBitangent;
    float2 uv;
};

float4 shade_phong(VertexOut in,
                   constant MaterialUniforms &material,
                   constant SceneUniforms &sceneUniforms,
                   constant LightUniforms *lights,
                   constant ModelUniforms &modelUniforms,
                   sampler textureSampler,
                   texture2d<float> baseColorTexture,
                   texture2d<float> normalTexture,
                   texture2d<float> aoTexture,
                   texturecube<float> reflectionTextureCube);

float4 fragmentChromeLighting(VertexOut in,
                              constant SceneUniforms &sceneUniforms,
                              constant ModelUniforms &modelUniforms,
                              texturecube<float> cubeMap);

float3 localCorrect(float3 origVec, BBox bBox, float3 vertexPos, float3 cubemapPos);

#endif /* ShadersCommon_h */

