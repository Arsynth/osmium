//
//  Shaders.metal
//  Osmium
//
//  Created by Артем on 17.12.2020.
//

// File for Metal kernel and shader functions

using namespace metal;
#include "ShadersCommon.h"

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                             constant SceneUniforms &sceneUniforms [[buffer(BufferIndexSceneUniforms)]],
                             constant ModelUniforms &modelUniforms [[buffer(BufferIndexModelUniforms)]])

{
    float4 position = vertexIn.position;
    ViewInfo viewInfo = sceneUniforms.viewInfo;
    float3 worldPosition = (modelUniforms.modelMatrix * position).xyz;

    VertexOut out {
        .position = viewInfo.projectionMatrix * viewInfo.viewMatrix * modelUniforms.modelMatrix * position,
        .worldPosition = worldPosition,
        .worldNormal = modelUniforms.normalMatrix * vertexIn.normal,
        .worldTangent = modelUniforms.normalMatrix * vertexIn.tangent,
        .worldBitangent = modelUniforms.normalMatrix * vertexIn.bitangent,
        .uv = vertexIn.uv,
    };
    
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant MaterialUniforms &material [[buffer(BufferIndexMaterials)]],
                              constant SceneUniforms &sceneUniforms [[buffer(BufferIndexSceneUniforms)]],
                              constant LightUniforms *lights [[buffer(BufferIndexLights)]],
                              constant ModelUniforms &modelUniforms [[buffer(BufferIndexModelUniforms)]],
                              sampler baseColor_S [[sampler(0)]],
                              texture2d<float> baseColor [[texture(BaseColorTexture), function_constant(hasColorTexture)]],
                              texture2d<float> bump [[texture(NormalTexture), function_constant(hasNormalTexture)]],
                              texture2d<float> ambientOcclusion [[texture(AOTexture), function_constant(hasAOTexture)]],
                              texturecube<float> reflective [[texture(ReflectionTextureCube), function_constant(hasReflectionTextureCube)]]) {
    float4 color = shade_phong(
                               in,
                               material,
                               sceneUniforms,
                               lights,
                               modelUniforms,
                               baseColor_S,
                               baseColor,
                               bump,
                               ambientOcclusion,
                               reflective
                               );
    
    return color;
}

float4 shade_phong(VertexOut in,
                   constant MaterialUniforms &material,
                   constant SceneUniforms &sceneUniforms,
                   constant LightUniforms *lights,
                   constant ModelUniforms &modelUniforms,
                   sampler textureSampler,
                   texture2d<float> baseColorTexture [[function_constant(hasColorTexture)]],
                   texture2d<float> normalTexture [[function_constant(hasNormalTexture)]],
                   texture2d<float> aoTexture [[function_constant(hasAOTexture)]],
                   texturecube<float> reflectionTextureCube [[function_constant(hasReflectionTextureCube)]]) {
    float2 tiledUV = in.uv * material.tiling;
    
    // extract color
    float4 baseColor = float4(0.0);
    if (hasColorTexture) {
        baseColor = baseColorTexture.sample(textureSampler, tiledUV);
    } else {
        baseColor = float4(material.baseColor, 1.0);
    }
    
    float3 matSpecularColor = material.specularColor;
    float shininess = material.specularExponent;
    
    float3 diffuse = float3(0.0);
    float3 specular = float3(0.0);
    float3 ambient = float3(0.0);
    
    float3 normalDirection;
    
    ViewInfo viewInfo = sceneUniforms.viewInfo;
    
    if (hasNormalTexture) {
        float3x3 tbn = float3x3(in.worldTangent, in.worldBitangent, in.worldNormal);
        normalDirection = normalTexture.sample(textureSampler, tiledUV).xyz;
        normalDirection.xy = normalDirection.xy * 2.0 - 1.0;
        normalDirection = normalize(tbn * normalDirection);
        // return float4(normalDirection, 1.0);
    } else {
        normalDirection = normalize(in.worldNormal);
    }
    
    if (hasReflectionTextureCube) {
        return fragmentChromeLighting(in, sceneUniforms, modelUniforms, reflectionTextureCube);
    }
    
    for (uint i = 0; i < sceneUniforms.lightCount; i++) {
        LightUniforms currentLight = lights[i];
        if (currentLight.type == LightTypeAmbient) {
            ambient += currentLight.color * currentLight.intensity * baseColor.xyz;
        } else if (currentLight.type == LightTypeSun) {
            float3 lightDirection = normalize(-currentLight.position);
            float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
            diffuse += currentLight.color * baseColor.xyz * diffuseIntensity;
            if (diffuseIntensity > 0) {
                float3 reflection = reflect(lightDirection, normalDirection);
                float3 cameraDirection = normalize(in.worldPosition - viewInfo.cameraPosition);
                float specularIntensity = pow(saturate(-dot(reflection, cameraDirection)), shininess);
                specular += currentLight.specularColor * matSpecularColor * specularIntensity;
            }
        } else if (currentLight.type == LightTypePoint) {
            float d = distance(currentLight.position, in.worldPosition);
            float attenuation = 1.0 / (currentLight.attenuation.x + currentLight.attenuation.y * d + currentLight.attenuation.z * d * d);
            
            float3 lightDirection = normalize(in.worldPosition - currentLight.position);
            float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
            float3 color = currentLight.color * baseColor.xyz * diffuseIntensity;
            color *= attenuation;
            diffuse += color;
            
            float3 cameraDirection = normalize(in.worldPosition - viewInfo.cameraPosition);
            float3 reflection = reflect(lightDirection, normalDirection);
            float specularIntensity = pow(saturate(-dot(cameraDirection, reflection)), shininess);
            float3 spec = matSpecularColor * specularIntensity * currentLight.color;
            spec *= attenuation;
            specular += spec;
        }
    }
    
    float3 result = diffuse + ambient + specular;
    
    if (hasAOTexture) {
        result.xyz *= aoTexture.sample(textureSampler, tiledUV).xyz;
    }
    
    return float4(result, baseColor.a);
}

float4 fragmentChromeLighting(VertexOut in,
                              constant SceneUniforms &sceneUniforms,
                              constant ModelUniforms &modelUniforms,
                              texturecube<float> cubeMap) {
    constexpr sampler linearSampler (mip_filter::linear,
                                     mag_filter::linear,
                                     min_filter::linear);

    // The per-vertex vectors have been interpolated, thus we need to normalize them again :
    in.worldNormal = normalize (in.worldNormal);

    float3 eyeDir = normalize (sceneUniforms.viewInfo.cameraPosition - float3(in.worldPosition));

    float similiFresnel = dot ((float3)in.worldNormal, eyeDir);
    similiFresnel = saturate(1.0-similiFresnel);
    similiFresnel = min ( 1.0, similiFresnel * 0.6 + 0.45);

    float3 reflectionDir = reflect (-eyeDir, (float3)in.worldNormal);
    reflectionDir = localCorrect(normalize(reflectionDir), modelUniforms.bBox, in.worldPosition, modelUniforms.position);

    float3 cubeRefl = (float3)cubeMap.sample (linearSampler, reflectionDir).xyz;

    return float4(cubeRefl * similiFresnel, 1.0);
}

float3 localCorrect(float3 origVec, BBox bBox, float3 vertexPos, float3 cubemapPos) {
    float3 intersectMaxPointPlanes = (bBox.maxPosition - vertexPos) / origVec;
    float3 intersectMinPointPlanes = (bBox.minPosition - vertexPos) / origVec;
    // Looking only for intersections in the forward direction of the ray.
    float3 largestRayParams = max(intersectMaxPointPlanes, intersectMinPointPlanes);
    // Smallest value of the ray parameters gives us the intersection.
    float distToIntersect = min(min(largestRayParams.x, largestRayParams.y), largestRayParams.z);
    // Find the position of the intersection point.
    float3 intersectPositionWS = vertexPos + origVec * distToIntersect;
    // Get local corrected reflection vector.
    return intersectPositionWS - cubemapPos;
}
