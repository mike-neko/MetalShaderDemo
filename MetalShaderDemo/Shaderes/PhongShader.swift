//
//  PhongShader.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/10.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

/*
 Phong
 struct GenericMaterialData {
    float3 diffuse;
    float3 specular;
    float shininess;    // 1...128 Specular Exponent
    float3 emmision;
 };
 */

extension Shader {
    static let phong = Shader(name: "Phong", vertexName: "phongVertex", fragmentName: "phongFragment",
                              properties: [LightBuffer(), PhongMaterialBuffer(), TextureProperty(textureName: "")])

    
}

class PhongMaterialBuffer: MaterialBuffer {
    override var variables: [ShaderParameter] {
        return [
            ShaderParameter(name: ShaderConst.diffuseColor,
                            type: .rgbColor(set: { self.rawData.diffuse = $0 }, get: { self.rawData.diffuse })),
            ShaderParameter(name: ShaderConst.specularColor,
                            type: .rgbColor(set: { self.rawData.specular = $0 }, get: { self.rawData.specular })),
            ShaderParameter(name: "Specular Exponent",
                            type: .floatValue(min: 1, max: 128, set: { self.rawData.shininess = $0 }, get: { self.rawData.shininess })),
            ShaderParameter(name: ShaderConst.emissionColor,
                            type: .rgbColor(set: { self.rawData.emission = $0 }, get: { self.rawData.emission }))
        ]
    }
    
    override init(key: String = ShaderConst.materialKey) {
        super.init(key: key)
        
        rawData.shininess = 10
    }
}

