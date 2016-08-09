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
    float4 position;
    float4 color;
};

struct MaterialData {
    float4 diffuse;
    float4 specular;
    float shininess;
    float4 emmision;
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
    out.normal = in.normal;
    
    auto eyeDirection = -(scn_node.inverseModelTransform * in.position);
    out.eye = normalize(eyeDirection);
    
    auto lightDirection = (scn_node.inverseModelTransform * light.position);
    out.light = normalize(lightDirection + eyeDirection);
    
    return out;
}

fragment half4 phongFragment(VertexOut in [[ stage_in ]],
                             texture2d<float> texture [[ texture(0) ]],
                             constant LightData& light [[ buffer(2) ]],
                             constant MaterialData& material [[ buffer(3) ]]) {
    auto lightColor = light.color;
    auto N = in.normal;
    auto L = in.light;
    auto V = in.eye;
    auto NdotL = saturate(dot(N, L));
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    float4 color = ambient + emmision;
    
    if (NdotL > 0.f) {
        constexpr sampler defaultSampler;
        auto decal = texture.sample(defaultSampler, in.texcoord);
        auto diffuse = lightColor * NdotL * material.diffuse * decal;
        
        auto R = -L + 2.0f * NdotL * N;     // =reflect(-L, N)
        auto VdotR = saturate(dot(V, R));
        auto specular = material.specular * pow(VdotR, material.shininess);
        
        color += diffuse + specular;
    }
    
    return half4(color);
}

fragment half4 blinnPhongFragment(VertexOut in [[ stage_in ]],
                                  texture2d<float> texture [[ texture(0) ]],
                                  constant LightData& light [[ buffer(2) ]],
                                  constant MaterialData& material [[ buffer(3) ]]) {
    
    auto lightColor = light.color;
    auto N = in.normal;
    auto L = in.light;
    auto V = in.eye;
    auto NdotL = saturate(dot(N, L));
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    float4 color = ambient + emmision;
    
    if (NdotL > 0.f) {
        constexpr sampler defaultSampler;
        auto decal = texture.sample(defaultSampler, in.texcoord);
        auto diffuse = lightColor * NdotL * material.diffuse * decal;
        
        auto H = normalize(L + V);
        auto NdotH = saturate(dot(N, H));
        auto specular = material.specular * pow(NdotH, material.shininess);
        
        color += diffuse + specular;
    }
    
    return half4(color);
}

