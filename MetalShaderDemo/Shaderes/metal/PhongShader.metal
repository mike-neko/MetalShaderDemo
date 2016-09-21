//
//  PhongShader.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/07.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include "SceneKitCommon.metal"

typedef GenericVertexInput VertexInput;
typedef GenericNodeBuffer NodeBuffer;
typedef GenericLightData LightData;
typedef GenericVertexOut VertexOut;

/*
 Phong
 struct GenericMaterialData {
    float3 diffuse;
    float3 specular;
    float shininess;    // 1...128 Specular Exponent（1...光沢大）
    float3 emmision;
 };

 CookTorrance
 struct GenericMaterialData {
    float3 diffuse;
    float3 specular;
    float shininess;    // 0...1 Highlight Eccentricity（1...光沢大）
    float3 emmision;
 };
 */
typedef GenericMaterialData MaterialData;


vertex VertexOut phongVertex(VertexInput in [[ stage_in ]],
                             constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                             constant NodeBuffer& scn_node [[ buffer(1) ]],
                             constant LightData& light [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.texcoord = in.texcoord;
    out.ambient = scn_frame.ambientLightingColor;
    out.normal = (scn_node.normalTransform * in.normal).xyz;
    out.light = (scn_frame.inverseViewTransform * light.lightWorldPosition).xyz;
    auto worldPos = scn_node.modelTransform * in.position;
    out.eye = (light.eyeWorldPosition - worldPos).xyz;
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
    auto H = normalize(L + V);
    auto NL = saturate(dot(N, L));
    auto NH = saturate(dot(N, H));
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    constexpr sampler defaultSampler;
    auto decal = texture.sample(defaultSampler, in.texcoord);
    auto diffuse = material.diffuse * decal.rgb * (NL * lightColor + ambient.rgb);
    
    auto shininess = sign(NL) * pow(NH, material.shininess);
    auto specular = NL * shininess * material.specular * lightColor;
    
    auto color = half3(diffuse + specular + emmision);
    return half4(color, 1);
}

fragment half4 cookTorranceFragment(VertexOut in [[ stage_in ]],
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
    auto R = -L + 2.0f * NL * N; // =reflect(-L, N)
    auto VR = saturate(dot(V, R));
    auto VH = saturate(dot(V, H));
    auto NV = max(dot(N, V), 0.01);
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    constexpr sampler defaultSampler;
    auto decal = texture.sample(defaultSampler, in.texcoord);
    auto diffuse = material.diffuse * decal.rgb * (NL * lightColor + ambient.rgb);
    
    auto highlight = material.shininess;
    auto hi2 = highlight * highlight;
    auto D = hi2 / (VR * VR * (hi2 - 1) + 1);
    D = D * D;
    auto gb = 2 * NH * NV / VH;
    auto gc = 2 * NH * NL / VH;
    auto ga = min(1.0, min(gb, gc));
    auto fresnel = 1.0 - pow(NV, 5);
    auto shininess = D * ga * fresnel / NV;
    auto specular = shininess * material.specular * lightColor;
    
    auto color = half3(diffuse + specular + emmision);
//    return half4(half3(NV), 1);
    return half4(color, 1);
}
