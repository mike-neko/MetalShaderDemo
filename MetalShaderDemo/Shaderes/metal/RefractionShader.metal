//
//  RefractionShader.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/31.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include "SceneKitCommon.metal"

typedef GenericVertexInput VertexInput;
typedef GenericNodeBuffer NodeBuffer;
typedef GenericLightData LightData;
typedef GenericVertexOut VertexOut;

/*
 Refraction
 struct GenericMaterialData {
    float3 diffuse;
    float3 specular;
    float shininess;        // 1...128 Specular Exponent（1...光沢大）
    float3 emmision;
 
    float scale;            // 0...1 eta
 };
 */
typedef GenericMaterialData MaterialData;


vertex VertexOut refractionVertex(VertexInput in [[ stage_in ]],
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

fragment half4 refractionFragment(VertexOut in [[ stage_in ]],
                                  texturecube<float> cubemap [[ texture(0) ]],
                                  texture2d<float> normalmap [[ texture(1) ]],
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
    
    auto uv = refract(-V, N, saturate(material.scale));
    constexpr sampler cubeSampler(filter::linear, mip_filter::linear);
    auto env = cubemap.sample(cubeSampler, uv).rgb;
    auto diffuse = material.diffuse * env * (NL * lightColor + ambient.rgb);
    
    auto shininess = sign(NL) * pow(NH, material.shininess);
    auto specular = NL * shininess * material.specular * lightColor;
    
    auto color = half3(diffuse + specular + emmision);
    return half4(color, 1);
}
