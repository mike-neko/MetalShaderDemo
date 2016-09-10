//
//  LambertShader.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/11.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include "SceneKitCommon.metal"

typedef GenericVertexInput VertexInput;
typedef GenericNodeBuffer NodeBuffer;
typedef GenericLightData LightData;
typedef GenericVertexOut VertexOut;

/*
 Lambert
 struct GenericMaterialData {
    float3 diffuse;
//    float3 specular;
//    float shininess;
    float3 emmision;
 };
*/
typedef GenericMaterialData MaterialData;


vertex VertexOut lambertVertex(VertexInput in [[ stage_in ]],
                               constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                               constant NodeBuffer& scn_node [[ buffer(1) ]],
                               constant LightData& light [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.texcoord = in.texcoord;
    out.ambient = scn_frame.ambientLightingColor;
    out.normal = (scn_node.normalTransform * in.normal).xyz;
    out.light = -normalize(light.lightWorldPosition.xyz);
    out.eye = normalize(light.eyeWorldPosition.xyz - out.position.xyz);
    return out;
}

fragment half4 lambertFragment(VertexOut in [[ stage_in ]],
                               texture2d<float> texture [[ texture(0) ]],
                               constant LightData& light [[ buffer(2) ]],
                               constant MaterialData& material [[ buffer(3) ]]) {
    
    auto lightColor = light.color;
    auto N = normalize(in.normal);
    auto L = normalize(in.light);
    auto NL = saturate(dot(N, L));
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    constexpr sampler defaultSampler;
    auto decal = texture.sample(defaultSampler, in.texcoord);
    auto diffuse = material.diffuse * decal.rgb * (NL * lightColor + ambient.rgb);

    auto color = half3(diffuse + emmision);
    return half4(color, 1);
}

fragment half4 halfLambertFragment(VertexOut in [[ stage_in ]],
                                   texture2d<float> texture [[ texture(0) ]],
                                   constant LightData& light [[ buffer(2) ]],
                                   constant MaterialData& material [[ buffer(3) ]]) {
    
    auto lightColor = light.color;
    auto N = normalize(in.normal);
    auto L = normalize(in.light);
    auto NL = dot(N, L);
    NL = NL * 0.5 + 0.5;
    NL = saturate(NL * NL);
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    constexpr sampler defaultSampler;
    auto decal = texture.sample(defaultSampler, in.texcoord);
    auto diffuse = material.diffuse * decal.rgb * (NL * lightColor + ambient.rgb);
    
    auto color = half3(diffuse + emmision);
    return half4(color, 1);
}

