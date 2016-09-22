//
//  RimLighting.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/14.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include "SceneKitCommon.metal"

typedef GenericVertexInput VertexInput;
typedef GenericNodeBuffer NodeBuffer;
typedef GenericLightData LightData;
typedef GenericVertexOut VertexOut;

//struct MaterialData {
//    float3 diffuse;
//    float3 specular;
//    float shininess;
//    float3 emmision;
//    
//    // RimLighting(rim power)
////    float rimPower;
//};
typedef GenericMaterialData MaterialData;

vertex VertexOut rimLightingVertex(VertexInput in [[ stage_in ]],
                                   constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                                   constant NodeBuffer& scn_node [[ buffer(1) ]],
                                   constant LightData& light [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.texcoord = in.texcoord;
    out.ambient = scn_frame.ambientLightingColor;
    out.normal = in.normal.xyz;
    out.light = (scn_node.inverseModelTransform * light.lightWorldPosition).xyz;
    auto worldPos = scn_node.modelTransform * in.position;
    out.eye = (scn_node.inverseModelTransform * light.eyeWorldPosition - worldPos).xyz;
    return out;
}

fragment half4 rimLightingFragment(VertexOut in [[ stage_in ]],
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
    auto NV = saturate(dot(N, V));
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    constexpr sampler defaultSampler;
    auto decal = texture.sample(defaultSampler, in.texcoord);
    auto diffuse = material.diffuse * decal.rgb * (NL * lightColor + ambient.rgb);
    
    auto shininess = sign(NL) * pow(NH, material.shininess);
    auto specular = NL * shininess * material.specular * lightColor;
    
    auto rim = pow(1.0 - NV, 2) * max(dot(V, -L), 0.0);
//    auto rim = pow(1.0 - NV, material.rimPower) * max(dot(V, -L), 0.0);
    
    auto color = half3(diffuse + specular + emmision + rim);
    return half4(color, 1);
}
