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

 BlinnPhong
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
    out.light = -normalize(light.lightWorldPosition.xyz);
    out.eye = normalize(light.eyeWorldPosition.xyz - out.position.xyz);
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

/*
 float3 Ln = normalize(IN.LightVec);
 float3 Vn = normalize(IN.WorldView);
 float3 Nn = normalize(IN.WorldNormal);
 float3 Hn = normalize(Vn + Ln);
 float4 litV = lit(dot(Ln,Nn),dot(Hn,Nn),SpecExpon);
 float3 diffContrib = litV.y * LampColor;
 float3 specContrib = litV.y * litV.z * Ks * LampColor;
 float3 diffuseColor = tex2D(ColorSampler,IN.UV).rgb;
 float3 result = specContrib+(diffuseColor*(diffContrib+AmbiColor));
 // return as float4
 return float4(result,1);
 */
