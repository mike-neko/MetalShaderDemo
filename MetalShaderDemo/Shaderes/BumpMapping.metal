//
//  BumpMapping.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/13.
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
    float3 tangent  [[ attribute(SCNVertexSemanticTangent) ]];
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

vertex VertexOut bumpVertex(VertexInput in [[ stage_in ]],
                             constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                             constant NodeBuffer& scn_node [[ buffer(1) ]],
                             constant LightData& light [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1);
    out.texcoord = in.texcoord;
    out.ambient = scn_frame.ambientLightingColor;
    
    
    auto normal = normalize(in.normal);
    auto tangent = normalize(cross(normal, float3(0.0, 1.0, 0.0)));
    auto bitangent = cross(normal, tangent);
    
    auto lightpos = (scn_node.inverseModelTransform * float4(normalize(light.lightPosition), 0)).xyz;
    auto eyepos = light.eyePosition - in.position;
    eyepos = (scn_node.inverseModelTransform * float4(normalize(eyepos), 0)).xyz;
    
    out.eye = float3(dot(tangent, eyepos), dot(bitangent, eyepos), dot(normal, eyepos));
    out.light = float3(dot(tangent, lightpos), dot(bitangent, lightpos), dot(normal, lightpos));

    return out;
}

fragment half4 bumpFragment(VertexOut in [[ stage_in ]],
                            texture2d<float> texture [[ texture(0) ]],
                            texture2d<float> normalmap [[ texture(1) ]],
                            constant LightData& light [[ buffer(2) ]],
                            constant MaterialData& material [[ buffer(3) ]]) {
    
    constexpr sampler defaultSampler;
    auto normal = normalmap.sample(defaultSampler, in.texcoord);
    auto N = (normal * 2 - 1).xyz;
    auto L = normalize(in.light);
    auto V = normalize(in.eye);

    
    
    
    
    auto lightColor = light.color;
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



