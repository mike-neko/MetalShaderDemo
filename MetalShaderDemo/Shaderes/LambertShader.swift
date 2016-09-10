//
//  LambertShader.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/10.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

/*
 Lambert
 struct GenericMaterialData {
    float3 diffuse;
    float3 emmision;
 };
*/

extension Shader {
    static let lambert = Shader(name: "Lambert", vertexName: "lambertVertex", fragmentName: "lambertFragment",
                                properties: [LightBuffer(), LambertMaterialBuffer(), TextureProperty(textureName: "")])

    static let halfLambert = Shader(name: "Lambert(Half)", vertexName: "lambertVertex", fragmentName: "halfLambertFragment",
                                    properties: [LightBuffer(), LambertMaterialBuffer(), TextureProperty(textureName: "")])
}

class LambertMaterialBuffer: MaterialBuffer {
    override var variables: [ShaderParameter] {
        return [
            ShaderParameter(name: ShaderConst.diffuseColor,
                            type: .rgbColor(set: { self.rawData.diffuse = $0 }, get: { self.rawData.diffuse })),
            ShaderParameter(name: ShaderConst.emissionColor,
                            type: .rgbColor(set: { self.rawData.emission = $0 }, get: { self.rawData.emission }))
        ]
    }
}

