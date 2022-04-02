//
//  OIT.metal
//  Osmium
//
//  Created by Artem Sechko on 30.09.2021.
//

#include <metal_stdlib>
#include "ShadersCommon.h"
using namespace metal;
/*
constant uint nil32 = 0xffffffff;

struct OITVertexOut {
    float4 position [[position]];
};

struct SortStackItem {
    uint level = 0;
    uint item = nil32;
};

uint sort(uint list, device ListItem *fragList);
float4 sourceOver(float4 destination, float4 source);
float4 overlap(uint list, device ListItem *fragList);

[[early_fragment_tests]]
fragment void fragment_OIT_main(VertexOut in [[stage_in]],
                                constant MaterialValues &material [[buffer(BufferIndexMaterials)]],
                                constant SceneUniforms &sceneUniforms [[buffer(BufferIndexSceneUniforms)]],
                                constant RenderPassUniforms &renderPassUniforms [[buffer(BufferIndexRenderPassUniforms)]],
                                constant LightUniforms *lights [[buffer(BufferIndexLights)]],
                                constant ModelUniforms &modelUniforms [[buffer(BufferIndexModelUniforms)]],
                                sampler textureSampler [[sampler(0)]],
                                texture2d<float> baseColorTexture [[texture(BaseColorTexture), function_constant(hasColorTexture)]],
                                texture2d<float> normalTexture [[texture(NormalTexture), function_constant(hasNormalTexture)]],
                                texture2d<float> aoTexture [[texture(AOTexture), function_constant(hasAOTexture)]],
                                texturecube<float> reflectionTextureCube [[texture(ReflectionTextureCube), function_constant(hasReflectionTextureCube)]],
                                device atomic_uint *fragCounter [[buffer(BufferIndexFragmentsCounter)]],
                                device atomic_uint *fragHeads [[buffer(BufferIndexFragmentHeads)]],
                                device ListItem *fragList [[buffer(BufferIndexListItems)]]) {
    float4 color = shade_phong(
                               in,
                               material,
                               sceneUniforms,
                               lights,
                               modelUniforms,
                               textureSampler,
                               baseColorTexture,
                               normalTexture,
                               aoTexture,
                               reflectionTextureCube
                               );
    color.w = material.opacity;
    
    float2 xy = in.position.xy;
    uint nodeIndex = atomic_fetch_add_explicit(fragCounter, 1, memory_order_relaxed);
    uint headIndex = uint(xy.x) + uint(xy.y) * renderPassUniforms.displaySize.x;
    
    if (nodeIndex < renderPassUniforms.fragListCapacity) {
        fragList[nodeIndex].color = color;
        fragList[nodeIndex].z = in.position.z;
        fragList[nodeIndex].next = atomic_exchange_explicit(&fragHeads[headIndex], nodeIndex, memory_order_relaxed);
        
        //Debug
//        fragList[nodeIndex].x = xy.x;
//        fragList[nodeIndex].y = xy.y;
    }
}

vertex OITVertexOut composeOITVertex(uint vertexID [[vertex_id]],
                                     constant OITComposeVertex *vertices [[buffer(BufferIndexVertices)]],
                                     constant RenderPassUniforms &renderPassUniforms [[buffer(BufferIndexRenderPassUniforms)]]) {
    float2 v = vertices[vertexID].position;
    //v.x *= fragmentUniforms.displaySize.x;
    //v.y *= fragmentUniforms.displaySize.y;
    
    OITVertexOut out {
        .position = float4(v.x, v.y, 0.0, 1.0)
    };
    
    return out;
}

fragment float4 composeOITFragment(OITVertexOut in [[stage_in]],
                                   constant RenderPassUniforms &renderPassUniforms [[buffer(BufferIndexRenderPassUniforms)]],
                                   device uint *fragHeads [[buffer(BufferIndexFragmentHeads)]],
                                   device ListItem *fragList [[buffer(BufferIndexListItems)]]) {
    float2 xy = in.position.xy;
    uint headIndex = uint(xy.x) + uint(xy.y) * renderPassUniforms.displaySize.x;
    uint fragIndex = fragHeads[headIndex];
    if (fragIndex == nil32) {
        return float4(0.0);
    }

    uint listStart = sort(fragIndex, fragList);
    float4 result = overlap(listStart, fragList);
    //result.xyz = result.xyz * result.w;
    return result;
}

kernel void clearHeads(device atomic_uint *heads [[buffer(0)]], uint index [[thread_position_in_grid]]) {
    atomic_store_explicit(&heads[index], nil32, memory_order_relaxed);
}

/// https://ru.wikipedia.org/wiki/%D0%A1%D0%BE%D1%80%D1%82%D0%B8%D1%80%D0%BE%D0%B2%D0%BA%D0%B0_%D1%81%D0%B2%D1%8F%D0%B7%D0%BD%D0%BE%D0%B3%D0%BE_%D1%81%D0%BF%D0%B8%D1%81%D0%BA%D0%B0
uint intersectSorted(uint list1, uint list2, device ListItem *fragList) {
    uint curItem = nil32;
    uint p1 = list1;
    uint p2 = list2;
    
    if (fragList[p1].z <= fragList[p2].z) {
        curItem = p1;
        p1 = fragList[p1].next;
    } else {
        curItem = p2;
        p2 = fragList[p2].next;
    }
    uint result = curItem;
    
    while (p1 != nil32 && p2 != nil32) {
        if (fragList[p1].z <= fragList[p2].z) {
            fragList[curItem].next = p1;
            curItem = p1;
            p1 = fragList[p1].next;
        } else {
            fragList[curItem].next = p2;
            curItem = p2;
            p2 = fragList[p2].next;
        }
    }
    
    if (p1 != nil32) {
        fragList[curItem].next = p1;
    } else {
        fragList[curItem].next = p2;
    }
    
    return result;
}

uint sort(uint list, device ListItem *fragList) {
    constexpr int stackLength = 32;
    SortStackItem stack[stackLength];
    //for (int i = 0; i < stackLength; i++) {
    //    stack[i].item = nil;
    //}
    
    int stackPos = 0;
    uint p = list;
    
    while (p != nil32) {
        stack[stackPos].level = 1;
        stack[stackPos].item = p;
        p = fragList[p].next;
        fragList[stack[stackPos].item].next = nil32;
        
        stackPos += 1;
        while (stackPos > 1 && stack[stackPos - 1].level == stack[stackPos - 2].level) {
            stack[stackPos - 2].item = intersectSorted(
                                                       stack[stackPos - 2].item,
                                                       stack[stackPos - 1].item,
                                                       fragList
                                                       );
            stack[stackPos - 2].level += 1;
            stackPos -= 1;
        }
    }
    
    while (stackPos > 1) {
        stack[stackPos - 2].item = intersectSorted(
                                                   stack[stackPos - 2].item,
                                                   stack[stackPos - 1].item,
                                                   fragList
                                                   );
        stack[stackPos - 2].level += 1;
        stackPos -= 1;
    }
    
    if (stackPos > 0) {
        return stack[0].item;
    } else {
        return list;
    }
}

float4 sourceOver(float4 destination, float4 source) {
    float dbf = 1.0 - source.w;
    return float4(
                  destination.x * dbf + source.x,
                  destination.y * dbf + source.y,
                  destination.z * dbf + source.z,
                  destination.w * dbf + source.w
           );
}

float4 overlap(uint list, device ListItem *fragList) {
    uint currentIndex = fragList[list].next;
    uint previousIndex = list;
    
    device ListItem *previousItem = &fragList[previousIndex];
    float4 resultColor = previousItem->color;
    while (currentIndex != nil32) {
        device ListItem *currentItem = &fragList[currentIndex];
        float4 currentColor = currentItem->color;
        if (previousItem->z == currentItem->z) {
            resultColor = mix(currentColor, resultColor, float4(0.5));
        } else {
            resultColor = sourceOver(currentColor, resultColor);
        }
        
        previousIndex = currentIndex;
        currentIndex = fragList[currentIndex].next;
    }
    return resultColor;
}
*/
