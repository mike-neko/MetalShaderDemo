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


struct PhongMaterialData {
    float3 diffuse;
    float3 specular;    // 0...1
    float shininess;    // 1...128 Specular Exponent
    float3 emmision;
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
    out.light = -normalize(light.lightWorldPosition.xyz);
    out.eye = normalize(light.eyeWorldPosition.xyz - out.position.xyz);
    return out;
}

fragment half4 phongFragment(VertexOut in [[ stage_in ]],
                             texture2d<float> texture [[ texture(0) ]],
                             constant LightData& light [[ buffer(2) ]],
                             constant PhongMaterialData& material [[ buffer(3) ]]) {
    
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

fragment half4 blinnPhongFragment(VertexOut in [[ stage_in ]],
                                  texture2d<float> texture [[ texture(0) ]],
                                  constant LightData& light [[ buffer(2) ]],
                                  constant PhongMaterialData& material [[ buffer(3) ]]) {
    return half4(1);
//    auto lightColor = light.color;
//    auto N = normalize(in.normal);
//    auto L = normalize(in.light);
//    auto V = normalize(in.eye);
//    auto H = normalize(L + V);
//    auto NL = saturate(dot(N, L));
//    auto NH = saturate(dot(N, H));
//    auto R = -L + 2.0f * NL * N; // =reflect(-L, N)
//    auto VR = max(dot(V, R), 0.001);
//    auto VH = saturate(dot(V, H));
//    auto NV = saturate(dot(N, V));
//    
//    auto ambient = in.ambient;
//    auto emmision = material.emmision;
//    
//    constexpr sampler defaultSampler;
//    auto decal = texture.sample(defaultSampler, in.texcoord);
//    auto diffuse = material.diffuse * decal.rgb * (NL * lightColor + ambient.rgb);
//    
//    auto hi2 = highlight * highlight;
//    auto D = hi2 / (VR * VR * (hi2 - 1) + 1);
//    D = D * D;
//    auto gb = 2 * NH * NV / VH;
//    auto gc = 2 * NH * NL / VH;
//    auto ga = min(1, min(gb, gc));
//    auto fresnel = 1.0 - pow(NV, 5);    // ????
//    auto shininess = D * ga * fresnel / NV;
//    auto specular = shininess * material.specular * lightColor;
//    
//    auto color = half3(diffuse + specular + emmision);
//    return half4(color, 1);
}
