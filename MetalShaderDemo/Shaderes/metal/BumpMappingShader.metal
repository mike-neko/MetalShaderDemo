//
//  BumpMappingShader.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/13.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include "SceneKitCommon.metal"

typedef GenericVertexInput VertexInput;
typedef GenericNodeBuffer NodeBuffer;
typedef GenericLightData LightData;
typedef GenericVertexOut VertexOut;

/*
 BumpMapping
 struct GenericMaterialData {
    float3 diffuse;
    float3 specular;
    float shininess;    // 1...128 Specular Exponent（1...光沢大）
    float3 emmision;
 };
 */
typedef GenericMaterialData MaterialData;


vertex VertexOut bumpVertex(VertexInput in [[ stage_in ]],
                            constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                            constant NodeBuffer& scn_node [[ buffer(1) ]],
                            constant LightData& light [[ buffer(2) ]]) {
    
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.texcoord = in.texcoord;
    out.ambient = scn_frame.ambientLightingColor;
    
    auto N = in.normal.xyz;
// auto tangent = normalize(in.tangent);    // Error!!
    auto T = normalize(cross(N, float3(0, 1, 0)));
    auto B = cross(N, T);

    auto L = (scn_node.inverseModelTransform * light.lightWorldPosition).xyz;
    auto worldPos = scn_node.modelTransform * in.position;
    auto eye = (scn_node.inverseModelTransform * light.eyeWorldPosition - worldPos).xyz;
    
    out.normal = N;
    out.light = float3(dot(L, T), dot(L, B), dot(L, N));
    out.eye = float3(dot(eye, T), dot(eye, B), dot(eye, N));
    return out;
}

fragment half4 bumpFragment(VertexOut in [[ stage_in ]],
                            texture2d<float> texture [[ texture(0) ]],
                            texture2d<float> normalmap [[ texture(1) ]],
                            constant LightData& light [[ buffer(2) ]],
                            constant MaterialData& material [[ buffer(3) ]]) {
    
    constexpr sampler defaultSampler;
    auto normal = (normalmap.sample(defaultSampler, in.texcoord) - 0.5).rgb;
    auto N = normalize(normal);
    auto L = normalize(in.light);
    auto V = normalize(in.eye);
    auto H = normalize(L + V);

    auto lightColor = light.color;
    auto NL = saturate(dot(N, L));
    auto NH = saturate(dot(N, H));
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    auto decal = texture.sample(defaultSampler, in.texcoord);
    auto diffuse = material.diffuse * decal.rgb * (NL * lightColor + ambient.rgb);
    
    auto shininess = pow(NH, material.shininess);
    auto specular = shininess * material.specular * lightColor;
    
    auto color = half3(diffuse + specular + emmision);
    return half4(color, 1);
}



