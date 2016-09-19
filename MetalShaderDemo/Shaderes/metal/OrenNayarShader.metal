//
//  OrenNayarShader.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/12.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include "SceneKitCommon.metal"

typedef GenericVertexInput VertexInput;
typedef GenericNodeBuffer NodeBuffer;
typedef GenericLightData LightData;
typedef GenericVertexOut VertexOut;

/*
 OrenNayar
 struct GenericMaterialData {
    float3 diffuse;
    float3 specular;
    float shininess;        // 0...1 roughness (0 = Lambert)
    float3 emmision;
 };
 */
typedef GenericMaterialData MaterialData;

vertex VertexOut orenNayarVertex(VertexInput in [[ stage_in ]],
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

fragment half4 orenNayarFragment(VertexOut in [[ stage_in ]],
                                 texture2d<float> texture [[ texture(0) ]],
                                 constant LightData& light [[ buffer(2) ]],
                                 constant MaterialData& material [[ buffer(3) ]]) {
    
    auto roughness = material.shininess;
    auto lightColor = light.color;
    auto N = normalize(in.normal);
    auto L = normalize(in.light);
    auto V = normalize(in.eye);
    auto NL = saturate(dot(N, L));
    auto NV = saturate(dot(N, V));
    
    auto ambient = in.ambient;
    auto emmision = material.emmision;
    
    auto angleVN = acos(NV);
    auto angleLN = acos(NL);
    auto gamma = dot(V - N * NV, L - N * NV);
    
    auto roughness2 = roughness * roughness;
    auto A = 1.0 - 0.5 * (roughness2 / (roughness2 + 0.57));
    auto B = 0.45 * (roughness2 / (roughness2 + 0.09));
    auto C = sin(max(angleVN, angleLN)) * tan(min(angleVN, angleLN));
    
    auto L1 = max(0.0, NL) * (A + B * max(0.0, gamma) * C);
    
    constexpr sampler defaultSampler;
    auto decal = texture.sample(defaultSampler, in.texcoord);
    auto diffuse = material.diffuse * decal.rgb * (L1 * lightColor + ambient.rgb);
    
    auto color = half3(diffuse + emmision);
    return half4(color, 1);
}
