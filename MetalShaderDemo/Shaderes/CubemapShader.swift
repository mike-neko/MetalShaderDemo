//
//  CubemapShader.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/14.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

extension Shader {
    static let cubemapping = Shader(name: "Cubemapping", vertexName: "cubemapVertex", fragmentName: "cubemapFragment",
                              properties: [LightBuffer(), CubemapMaterialBuffer(),
                                           TextureProperty(textureName: ""),
                                           TextureListProperty(key: ShaderConst.cubemapKey,
                                                               textureNames: ["px", "nx", "py", "ny", "pz", "nz"])])
}

class CubemapMaterialBuffer: MaterialBuffer {
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
        
        rawData.diffuse = Color.white.rgb
        rawData.shininess = 10
    }
}
