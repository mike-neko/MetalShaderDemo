//
//  ShaderCommon.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

// MARK: -

struct LightData {
    var lightPosition: float3
    var eyePosition: float3
    var color: float4
}

struct MaterialData {
    var diffuse: float4
    var specular: float4
    var shininess: Float
    var emission: float4
    
    var roughness: Float
    
    private let padding = [UInt8](repeating: 0, count: 12)
}

// MARK: -

typealias ColorParameter = ValueParameter<float4>
typealias LightParameter = ValueParameter<LightData>
typealias MaterialParameter = ValueParameter<MaterialData>


// MARK: -

protocol ShaderParameter {
    var key: String { get }
    var data: Any { get }
}

class ValueParameter<T>: ShaderParameter {
    let key: String
    var data: Any {
        return NSData(bytes: &value, length: MemoryLayout<T>.size)
    }
    
    var value: T
    
    init(key: String, value: T) {
        self.key = key
        self.value = value
    }
}

class TextureParameter: ShaderParameter {
    let key: String
    var data: Any {
        return SCNMaterialProperty(contents: textureName)
    }
    
    var textureName: String
    
    init(key: String, textureName: String) {
        self.key = key
        self.textureName = textureName
    }
}

class TextureListParameter: ShaderParameter {
    let key: String
    var data: Any {
        return SCNMaterialProperty(contents: textureNames)
    }
    
    var textureNames: [String]
    
    init(key: String, textureNames: [String]) {
        self.key = key
        self.textureNames = textureNames
    }
}

