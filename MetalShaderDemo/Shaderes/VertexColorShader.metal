//
//  VertexColorShader.metal
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/07.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include "SceneKitCommon.metal"

typedef GenericVertexInput VertexInput;
typedef GenericNodeBuffer NodeBuffer;

// 変数
struct ColorBuffer {
    float4 rgba;
};

struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
    float4 color;
};


vertex VertexOut colorVertex(VertexInput in [[ stage_in ]],
                             constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                             constant NodeBuffer& scn_node [[ buffer(1) ]],
                             constant ColorBuffer& colorBuffer [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.texcoord = in.texcoord;
    out.color = colorBuffer.rgba;
    return out;
}

fragment half4 colorFragment(VertexOut in [[ stage_in ]]) {
    return half4(in.color);
}
