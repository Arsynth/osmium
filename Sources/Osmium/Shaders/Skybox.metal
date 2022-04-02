//
//  Skybox.metal
//  Osmium
//
//  Created by Artem Sechko on 30.09.2021.
//

using namespace metal;
#include <metal_stdlib>
#include "ShaderTypes.h"


struct SkyVertexIn {
    float4 position [[ attribute(0) ]];
};

struct SkyVertexOut {
    float4 position [[ position ]];
    float3 textureCoordinates;
};

vertex SkyVertexOut skyboxVertex(const SkyVertexIn in [[stage_in]],
                              constant SceneUniforms &sceneUniforms [[buffer(BufferIndexSceneUniforms)]]) {
    SkyVertexOut out;
    ViewInfo viewInfo = sceneUniforms.viewInfo;
    out.position = (viewInfo.skyboxMatrix * in.position).xyww;
    out.textureCoordinates = in.position.xyz;
    return out;
}

fragment half4 skyboxFragment(SkyVertexOut in [[stage_in]],
                              texturecube<half> skyboxCube [[texture(BufferIndexSkybox)]]) {
    constexpr sampler default_sampler(filter::linear);
    half4 color = skyboxCube.sample(default_sampler, in.textureCoordinates);
    return color;
}

