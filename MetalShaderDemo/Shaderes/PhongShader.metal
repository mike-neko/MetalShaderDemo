//
//  PhongShader.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/07.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

// 頂点属性
struct VertexInput {
    float4 position [[ attribute(SCNVertexSemanticPosition) ]];
    float2 texcoord [[ attribute(SCNVertexSemanticTexcoord0) ]];
    float4 normal   [[ attribute(SCNVertexSemanticNormal) ]];
};

// モデルデータ
struct NodeBuffer {
    float4x4 modelViewProjectionTransform;
    float4x4 inverseModelTransform;
};

struct LightData {
    float3 position;
    float3 color;
};

struct MaterialData {
    float3 diffuse;
    float3 specular;
    float shine;
};

struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
    float4 ambient;
    float4 normal;
    float4 light;
    float4 eye;
};

vertex VertexOut phongVertex(VertexInput in [[ stage_in ]],
                               constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                               constant NodeBuffer& scn_node [[ buffer(1) ]],
                               constant LightData& light [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.texcoord = in.texcoord;
    out.ambient = scn_frame.ambientLightingColor;
    out.normal = normalize(in.normal);
    
    auto eyeDirection = -(scn_node.inverseModelTransform * in.position);
    out.eye = normalize(eyeDirection);
    
    auto lightDirection = (scn_node.inverseModelTransform * float4(light.position, 1));
    out.light = normalize(lightDirection + eyeDirection);

    return out;
}

fragment half4 phongFragment(VertexOut in [[ stage_in ]],
                             texture2d<float> texture [[ texture(0) ]],
                             constant LightData& light [[ buffer(2) ]],
                             constant MaterialData& material [[ buffer(3) ]]) {
    constexpr sampler defaultSampler;

    auto lightColor = float4(light.color, 1);
    auto N = in.normal;
    auto L = in.light;
    auto E = in.eye;
    auto NdotL = saturate(dot(N, L));
    auto R = -L + 2.0f * NdotL * N;
    auto EdotR = saturate(dot(E, R));
 
    auto ambient = in.ambient;
    auto diffuse = lightColor * NdotL * float4(material.diffuse, 1);
    auto specular = float4(material.specular, 1) * lightColor * pow(EdotR, material.shine);
    
    return half4(ambient + diffuse + specular);
}
