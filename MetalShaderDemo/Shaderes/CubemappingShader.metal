//
//  CubemappingShader.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/30.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

// 頂点属性
struct VertexInput {
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
    float2 texcoord [[ attribute(SCNVertexSemanticTexcoord0) ]];
    float3 normal   [[ attribute(SCNVertexSemanticNormal) ]];
};

// モデルデータ
struct NodeBuffer {
    float4x4 modelViewProjectionTransform;
    float4x4 inverseModelTransform;
};

struct LightData {
    float3 lightPosition;
    float3 eyePosition;
    float4 color;
};

struct MaterialData {
    float4 diffuse;
    float4 specular;
    float shininess;
    float4 emmision;
    
    // CookTorrance(microfacet)
    float roughness;
};

struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
    float4 ambient;
    float3 normal;
    float3 light;
    float3 eye;
};

vertex VertexOut cubemapVertex(VertexInput in [[ stage_in ]],
                               constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                               constant NodeBuffer& scn_node [[ buffer(1) ]],
                               constant LightData& light [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1);
    out.texcoord = in.texcoord;
    out.ambient = scn_frame.ambientLightingColor;
    out.normal = (scn_node.modelViewProjectionTransform * float4(in.normal, 0)).xyz;
    out.light = (scn_node.inverseModelTransform * float4(normalize(light.lightPosition), 0)).xyz;
    auto eyepos = light.eyePosition - in.position;
    out.eye = (scn_node.inverseModelTransform * float4(normalize(eyepos), 0)).xyz;
    return out;
}

fragment half4 cubemapFragment(VertexOut in [[ stage_in ]],
                               texturecube<float> texture [[ texture(0) ]],
                               texture2d<float> normalmap [[ texture(1) ]],
                               constant LightData& light [[ buffer(2) ]],
                               constant MaterialData& material [[ buffer(3) ]]) {
    
    auto N = normalize(in.normal);
    auto V = normalize(in.eye);
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    float4 color = ambient + emmision;
    
    auto uv = reflect(V, N);
    constexpr sampler cubeSampler(filter::linear, mip_filter::linear);
    auto env = texture.sample(cubeSampler, uv);

    auto diffuse = material.diffuse * env;
    color += diffuse;
    
    return half4(color);
}



