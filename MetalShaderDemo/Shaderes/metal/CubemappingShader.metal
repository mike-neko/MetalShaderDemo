//
//  CubemappingShader.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/30.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include "SceneKitCommon.metal"

typedef GenericVertexInput VertexInput;
typedef GenericNodeBuffer NodeBuffer;
typedef GenericLightData LightData;
typedef GenericVertexOut VertexOut;
typedef GenericMaterialData MaterialData;


vertex VertexOut cubemapVertex(VertexInput in [[ stage_in ]],
                               constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                               constant NodeBuffer& scn_node [[ buffer(1) ]],
                               constant LightData& light [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.texcoord = in.texcoord;
    out.ambient = scn_frame.ambientLightingColor;
//    out.normal = (scn_frame.inverseViewTransform * (scn_node.normalTransform * in.normal)).xyz;    // view space
//    out.light = -light.lightWorldPosition.xyz;
//    out.eye = (-light.eyeWorldPosition).xyz;


    out.position = scn_node.modelViewProjectionTransform * in.position;
    
    // Calculate the normal from the perspective of the camera
    out.normal = (normalize(scn_node.modelViewTransform * float4(in.normal.xyz, 0.0f))).xyz;
    
    // Calculate the view vector from the perspective of the camera
    float3 vertex_position_cameraspace = (scn_node.modelViewTransform * in.position ).xyz;
    out.eye = light.eyeWorldPosition.xyz - vertex_position_cameraspace;
    
    // Calculate the direction of the light from the position of the camera
    float3 light_position_cameraspace = (scn_frame.viewTransform * float4(light.lightWorldPosition.xyz,1.0f)).xyz;
    out.light = light_position_cameraspace + out.eye;
    
    return out;
}

fragment half4 cubemapFragment(VertexOut in [[ stage_in ]],
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
    
    auto uv = reflect(V, N);
    constexpr sampler cubeSampler(filter::linear, mip_filter::linear);
    auto env = cubemap.sample(cubeSampler, uv).rgb;
    auto diffuse = material.diffuse * env * (NL * lightColor + ambient.rgb);
    
    auto shininess = sign(NL) * pow(NH, material.shininess);
    auto specular = NL * shininess * material.specular * lightColor;
    
    auto color = half3(diffuse + specular + emmision);
    return half4(color, 1);
}
