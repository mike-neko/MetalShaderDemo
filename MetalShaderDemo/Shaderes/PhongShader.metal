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
    float4x4 normalTransform; // Inverse transpose of modelViewTransform
    float4x4 modelViewProjectionTransform;
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

vertex VertexOut phongVertex(VertexInput in [[ stage_in ]],
                             constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                             constant NodeBuffer& scn_node [[ buffer(1) ]],
                             constant LightData& light [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.texcoord = in.texcoord;
    out.ambient = scn_frame.ambientLightingColor;
    out.normal = (scn_node.normalTransform * in.normal).xyz;
    out.light = -normalize(light.lightPosition);
    out.eye = normalize(light.eyePosition - out.position.xyz);
    return out;
}

fragment half4 phongFragment(VertexOut in [[ stage_in ]],
                             texture2d<float> texture [[ texture(0) ]],
                             constant LightData& light [[ buffer(2) ]],
                             constant MaterialData& material [[ buffer(3) ]]) {
    
    auto lightColor = light.color;
    auto N = normalize(in.normal);
    auto L = normalize(in.light);
    auto V = normalize(in.eye);
    auto NL = saturate(dot(N, L));
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    float4 color = ambient + emmision;
    
    if (NL > 0.f) {
        constexpr sampler defaultSampler;
        auto decal = texture.sample(defaultSampler, in.texcoord);
        
        auto diffuse = lightColor * float4(float3(NL), 1) * material.diffuse * decal;
        
        auto R = -L + 2.0f * NL * N; // =reflect(-L, N)
        auto VR = saturate(dot(V, R));
        auto specular = material.specular * float4(float3(pow(VR, material.shininess)), 1) * lightColor;
        
        color += diffuse + specular;
    }
    
    return half4(color);
}

fragment half4 blinnPhongFragment(VertexOut in [[ stage_in ]],
                                  texture2d<float> texture [[ texture(0) ]],
                                  constant LightData& light [[ buffer(2) ]],
                                  constant MaterialData& material [[ buffer(3) ]]) {
    
    auto lightColor = light.color;
    auto N = normalize(in.normal);
    auto L = normalize(in.light);
    auto V = normalize(in.eye);
    auto H = normalize(L + V);
    auto NL = saturate(dot(N, L));
    auto NH = saturate(dot(N, H));
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    float4 color = emmision;
    
    
    auto diffcontrib = NL * lightColor;
    auto specular = NL * pow(NH, material.shininess) * 0.5 * lightColor;
    
    constexpr sampler defaultSampler;
    auto decal = texture.sample(defaultSampler, in.texcoord);
    
    auto diffuse = material.diffuse * decal * (diffcontrib + ambient);
    
    color += diffuse + specular;
    
    return half4(color);
}


static float bechmannDistribution(float nh, float microfacet) {
    auto NH2 = nh * nh;
    auto m2 = microfacet * microfacet;
    
    return exp((NH2 - 1) / (m2 * NH2)) / (4 * m2 * NH2 * NH2);
}

static float fresnel(float n, float c) {
    auto g = sqrt(n * n + c * c - 1);
    
    float ga = (c * (g + c) - 1.0) * (c * (g + c) - 1.0);
    float gb = (c * (g - c) + 1.0) * (c * (g - c) + 1.0);
    return (g - c) * (g - c) / (2.0 * (g + c) + (g + c)) * (1.0 + ga / gb);
}

fragment half4 cookTorranceFragment(VertexOut in [[ stage_in ]],
                                    texture2d<float> texture [[ texture(0) ]],
                                    constant LightData& light [[ buffer(2) ]],
                                    constant MaterialData& material [[ buffer(3) ]]) {
    
    auto lightColor = light.color;
    auto N = normalize(in.normal);
    auto L = normalize(in.light);
    auto V = normalize(in.eye);
    auto NL = saturate(dot(N, L));
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    float4 color = ambient + emmision;
    
    if (NL > 0.f) {
        constexpr sampler defaultSampler;
        auto decal = texture.sample(defaultSampler, in.texcoord);
        
        auto diffuse = lightColor * float4(float3(NL), 1) * material.diffuse * decal;
        
        auto H = normalize(L + V);
        auto NH = saturate(dot(N, H));
        auto VH = saturate(dot(V, H));
        auto NV = saturate(dot(N, V));
        
        // D: Beckman
        auto D = bechmannDistribution(NH, material.roughness);
        
        // G: 幾何減衰率
        auto G = min(1.f, min(2 * NH * NV / VH, 2 * NH * NL / VH));
        
        // F: フレネル項
        auto F = fresnel(material.shininess, VH);
        auto specular = material.specular * lightColor * D * G * F / NV;
        
        color += diffuse + specular;
    }
    
    return half4(color);
}


