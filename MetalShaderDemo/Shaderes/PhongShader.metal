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

//fragment half4 blinnPhongFragment(VertexOut in [[ stage_in ]],
//                                  texture2d<float> texture [[ texture(0) ]],
//                                  constant LightData& light [[ buffer(2) ]],
//                                  constant PhongMaterialData& material [[ buffer(3) ]]) {
//
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
//    auto diffuse = material.diffuse * decal * (NL * lightColor + ambient);
//
//    auto specular = NL * pow(NH, material.shininess) * 0.5 * lightColor;
//
//    return half4(diffuse + specular + emmision);
//
//    auto lightColor = light.color;
//    auto N = normalize(in.normal);
//    auto L = normalize(in.light);
//    auto V = normalize(in.eye);
//    auto NL = saturate(dot(N, L));
//
//    auto ambient = in.ambient;
//    auto emmision = material.emmision;
//
//    float4 color = ambient + emmision;
//
//    if (NL > 0.f) {
//        constexpr sampler defaultSampler;
//        auto decal = texture.sample(defaultSampler, in.texcoord);
//
//        auto diffuse = lightColor * float4(float3(NL), 1) * material.diffuse * decal;
//
//        auto specular = material.specular * float4(float3(pow(VR, material.shininess)), 1) * lightColor;
//
//        color += diffuse + specular;
//    }
//
//    return half4(color);
//}

/*
 float3 Ln = normalize(IN.LightVec);
 float3 Vn = normalize(IN.WorldView);
 float3 Nn = normalize(IN.WorldNormal);
 float3 Hn = normalize(Vn + Ln);
 float hdn = dot(Hn,Nn);
 float3 Rv = reflect(-Ln,Nn);
 float rdv = dot(Rv,Vn);
 rdv = max(rdv,0.001);
 float ldn=dot(Ln,Nn);
 ldn = max(ldn,0.0);
 float ndv = dot(Nn,Vn);
 float hdv = dot(Hn,Vn);
 float eSq = Eccentricity*Eccentricity;
 float distrib = eSq / (rdv * rdv * (eSq - 1.0) + 1.0);
 distrib = distrib * distrib;
 float Gb = 2.0 * hdn * ndv / hdv;
 float Gc = 2.0 * hdn * ldn / hdv;
 float Ga = min(1.0,min(Gb,Gc));
 float fresnelHack = 1.0 - pow(ndv,5.0);
 hdn = distrib * Ga * fresnelHack / ndv;
 float3 diffContrib = ldn * LampColor;
 float3 specContrib = hdn * Ks * LampColor;
 float3 diffuseColor = tex2D(ColorSampler,IN.UV).rgb;
 float3 result = specContrib+(diffuseColor*(diffContrib+AmbiColor));
 // return as float4
 return float4(result,1);
 */

//static float bechmannDistribution(float nh, float microfacet) {
//    auto NH2 = nh * nh;
//    auto m2 = microfacet * microfacet;
//
//    return exp((NH2 - 1) / (m2 * NH2)) / (4 * m2 * NH2 * NH2);
//}
//
//static float fresnel(float n, float c) {
//    auto g = sqrt(n * n + c * c - 1);
//
//    float ga = (c * (g + c) - 1.0) * (c * (g + c) - 1.0);
//    float gb = (c * (g - c) + 1.0) * (c * (g - c) + 1.0);
//    return (g - c) * (g - c) / (2.0 * (g + c) + (g + c)) * (1.0 + ga / gb);
//}
//
//fragment half4 cookTorranceFragment(VertexOut in [[ stage_in ]],
//                                    texture2d<float> texture [[ texture(0) ]],
//                                    constant LightData& light [[ buffer(2) ]],
//                                    constant PhongMaterialData& material [[ buffer(3) ]]) {
//
//    auto lightColor = light.color;
//    auto N = normalize(in.normal);
//    auto L = normalize(in.light);
//    auto V = normalize(in.eye);
//    auto NL = saturate(dot(N, L));
//
//    auto ambient = in.ambient;
//    auto emmision = material.emmision;
//
//    float4 color = ambient + emmision;
//
//    constexpr sampler defaultSampler;
//    auto decal = texture.sample(defaultSampler, in.texcoord);
//    auto diffuse = lightColor * float4(float3(NL), 1) * material.diffuse * decal;
//
//        auto H = normalize(L + V);
//        auto NH = saturate(dot(N, H));
//        auto VH = saturate(dot(V, H));
//        auto NV = saturate(dot(N, V));
//
//        // D: Beckman
//        auto D = bechmannDistribution(NH, material.roughness);
//
//        // G: 幾何減衰率
//        auto G = min(1.f, min(2 * NH * NV / VH, 2 * NH * NL / VH));
//
//        // F: フレネル項
//        auto F = fresnel(material.shininess, VH);
//        auto specular = material.specular * lightColor * D * G * F / NV;
//
//        color += diffuse + specular;
//
//    return half4(color);
//}

