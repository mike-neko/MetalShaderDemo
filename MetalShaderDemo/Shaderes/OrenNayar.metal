//
//  OrenNayar.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/12.
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

vertex VertexOut orenNayarVertex(VertexInput in [[ stage_in ]],
                             constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                             constant NodeBuffer& scn_node [[ buffer(1) ]],
                             constant LightData& light [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1);
    out.texcoord = in.texcoord;
    out.ambient = scn_frame.ambientLightingColor;
    out.normal = in.normal;
    out.light = (scn_node.inverseModelTransform * float4(normalize(light.lightPosition), 0)).xyz;
    auto eyepos = light.eyePosition - in.position;
    out.eye = (scn_node.inverseModelTransform * float4(normalize(eyepos), 0)).xyz;
    return out;
}

fragment half4 orenNayarFragment(VertexOut in [[ stage_in ]],
                             texture2d<float> texture [[ texture(0) ]],
                             constant LightData& light [[ buffer(2) ]],
                             constant MaterialData& material [[ buffer(3) ]]) {
    
    auto roughness = material.roughness;
    auto lightColor = light.color;
    auto N = normalize(in.normal);
    auto L = normalize(in.light);
    auto V = normalize(in.eye);
    auto NL = saturate(dot(N, L));
    auto NV = saturate(dot(N, V));
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    float4 color = ambient + emmision;
    
    auto angleVN = acos(NL);
    auto angleLN = acos(NL);
    auto gamma = dot(V - N * NV, L - N * NV);
    
    auto roughness2 = roughness * roughness;
    auto A = 1.0 - 0.5 * (roughness2 / (roughness2 + 0.57));
    auto B = 0.45 * (roughness2 / (roughness2 + 0.09));
    auto C = sin(max(angleVN, angleLN)) * tan(min(angleVN, angleLN));
    
    auto L1 = max(0.0, NL) * (A + B * max(0.0, gamma) * C);
    
    constexpr sampler defaultSampler;
    auto decal = texture.sample(defaultSampler, in.texcoord);
    
    auto diffuse = lightColor * L1 * material.diffuse * decal;

    color += diffuse;
    return half4(color);
}




