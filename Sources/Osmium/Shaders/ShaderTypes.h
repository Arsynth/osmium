//
//  ShaderTypes.h
//  Osmium
//
//  Created by Артем on 17.12.2020.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef struct {
    vector_float3 minPosition;
    vector_float3 maxPosition;
} BBox;

typedef struct {
    matrix_float4x4 modelMatrix;
    // Usually is top left submatrix of modelMatrix
    matrix_float3x3 normalMatrix;
    vector_float3 position;
    BBox bBox;
} ModelUniforms;

typedef struct {
    vector_float3 cameraPosition;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewProjectionMatrix;
    matrix_float4x4 skyboxMatrix;
} ViewInfo;

typedef struct {
    vector_uint2 displaySize;
    uint fragListCapacity;
} RenderPassUniforms;

typedef enum {
    unused = 0,
    LightTypeSun = 1,
    LightTypeSpot = 2,
    LightTypePoint = 3,
    LightTypeAmbient = 4
} LightType;

typedef struct {
    vector_float3 position;

    vector_float3 color;
    vector_float3 specularColor;
    float intensity;
    /// Howto - https://developer.valvesoftware.com/wiki/Constant-Linear-Quadratic_Falloff
    /// Representing constant, linear and quadratic falloff as x, y, z accordingly
    vector_float3 attenuation;
    LightType type;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
} LightUniforms;

typedef struct {
    ViewInfo viewInfo;
    uint lightCount;
} SceneUniforms;


typedef enum {
    Position = 0,
    Normal = 1,
    UV = 2,
    Tangent = 3,
    Bitangent = 4,
    Color = 5,
    Joints = 6,
    Weights = 7
} Attributes;

typedef enum {
    BaseColorTexture = 0,
    NormalTexture = 1,
    RoughnessTexture = 2,
    MetallicTexture = 3,
    AOTexture = 4,
    CompositionTargetTexture = 5,
    ReflectionTextureCube = 6,
} TextureIndices;

typedef enum {
    /// This enum values should correspond to MDLVertexDescriptor's buffer indices
    BufferIndexVertices = 0,
    BufferIndexTangent = 1,
    BufferIndexBitangent = 2,
    /// -------
    BufferIndexModelUniforms = 3,
//    BufferIndexViewUniforms = 4,
    BufferIndexLights = 5,
//    BufferIndexFragmentUniforms = 6,
    BufferIndexSceneUniforms = 7,
    BufferIndexRenderPassUniforms = 8,
    BufferIndexMaterials = 9,
    BufferIndexInstances = 10,
    BufferIndexSkybox = 11,
    BufferIndexSkyboxDiffuse = 12,
    BufferIndexBRDFLut = 13,
    BufferIndexFragmentsCounter = 14,
    BufferIndexFragmentHeads = 15,
    BufferIndexListItems = 16,
} BufferIndices;

typedef struct {
    vector_float3 baseColor;
    vector_float3 specularColor;
    float roughness;
    float metallic;
    vector_float3 ambientOcclusion;
    float specularExponent;
    float opacity;
    vector_float3 reflective;

    vector_float2 tiling;
} MaterialUniforms;

typedef struct {
    vector_float4 color;
//    float x;
//    float y;
    float z;
    uint next;
} ListItem;

typedef struct {
    vector_float2 position;
} OITComposeVertex;

#endif /* ShaderTypes_h */

