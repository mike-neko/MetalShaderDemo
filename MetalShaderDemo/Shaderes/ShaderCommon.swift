//
//  ShaderCommon.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

// mac
typealias Color = NSColor
// ios
// typealias Color = UIColor


// MARK: -
struct ShaderDefault {
    static let diffuseColor = Color(red: 203, green: 0, blue: 45).rgb
    static let lightColor = Color.white.rgb
    static let specularColor = ShaderDefault.lightColor
    static let emissionColor = Color.black.rgb
    
}

struct ShaderConst {
    // プロパティ名
    static let vertexColor = "Vertex Color"
    static let lightColor = "Light Color"
    
    static let diffuseColor = "Diffuse Color"
    static let specularColor = "Specular Color"
    static let emissionColor = "Emission Color"
    
    static let specularExponent = "Specular Exponent"

    // キー（パラメータ名）
    static let colorKey = "colorBuffer"
    static let textureKey = "texture"
    static let lightKey = "light"
    static let materialKey = "material"
    static let normalmapKey = "normalmap"
    static let cubemapKey = "cubemap"
}

// MARK: -
struct Shader {
    let name: String
    let vertexName: String
    let fragmentName: String
    let properties: [ShaderPropertyType]
}

// MARK: -
struct ShaderParameter {
    var name: String
    var type: ShaderParameterType
}

enum ShaderParameterType {
    case rgbColor(set: (float3) -> Void, get: () -> float3)
//    case color((float4) -> Void)
//    case position((float3) -> Void)
//    case texture, textureList
    case normalizeValue(set: (Float) -> Void, get: () -> Float)
    case floatValue(min: Float, max: Float, set: (Float) -> Void, get: () -> Float)
    
    @discardableResult
    func update(newValue: Any) -> Bool {
        switch self {
        case .rgbColor(let callback, _):
            guard let value = newValue as? float3 else { return false }
            callback(value)
            return true
        case .normalizeValue(let callback, _), .floatValue(_, _, let callback, _):
            guard let value = newValue as? Float else { return false }
            callback(value)
            return true
        }
    }
}

protocol ShaderPropertyType {
    var key: String { get }
    var data: Any { get }
    
    var variables: [ShaderParameter] { get }
}

protocol ShaderPropertyProtocol: ShaderPropertyType {
    associatedtype ValueType
    
    var rawData: ValueType { get }
}

extension ShaderPropertyProtocol {
    var data: Any {
        var dat = rawData
        return NSData(bytes: &dat, length: MemoryLayout<ValueType>.size)
    }
}

// MARK: -
class TextureProperty: ShaderPropertyType {
    let key: String
    var data: Any {
        return textureName.isEmpty ? SCNMaterialProperty(contents: Color.clear)
            : SCNMaterialProperty(contents: textureName)
    }
    var variables: [ShaderParameter] { return [] }
    
    var textureName: String
    
    init(key: String = ShaderConst.textureKey, textureName: String) {
        self.key = key
        self.textureName = textureName
    }
}

class TextureListProperty: ShaderPropertyType {
    let key: String
    var data: Any {
        return SCNMaterialProperty(contents: textureNames)
    }
    var variables: [ShaderParameter] { return [] }
    
    var textureNames: [String]
    
    init(key: String, textureNames: [String]) {
        self.key = key
        self.textureNames = textureNames
    }
}

class ColorBuffer: ShaderPropertyProtocol {
    typealias ValueType = float3
    
    let key: String
    var rawData: ValueType

    var variables: [ShaderParameter] {
        return [
            ShaderParameter(name: ShaderConst.vertexColor,
                            type: .rgbColor(set: { self.rawData = $0 }, get: { self.rawData }))
        ]
    }
    
    init(key: String = ShaderConst.colorKey, rawData: ValueType) {
        self.key = key
        self.rawData = rawData
    }
}

class LightBuffer: ShaderPropertyProtocol {
    struct Data {
        var lightPosition = float3(0)
        var eyePosition = float3(0)
        var color = ShaderDefault.lightColor
    }

    typealias ValueType = Data
    
    let key: String
    var rawData = ValueType()
    
    var variables: [ShaderParameter] {
        return [
            ShaderParameter(name: ShaderConst.lightColor,
                            type: .rgbColor(set: { self.rawData.color = $0 }, get: { self.rawData.color }))
        ]
    }
    
    init(key: String = ShaderConst.lightKey) {
        self.key = key
    }
}

class MaterialBuffer: ShaderPropertyProtocol {
    struct Data {
        var diffuse = ShaderDefault.diffuseColor
        var specular = ShaderDefault.specularColor
        var shininess = Float(0)
        var emission = ShaderDefault.emissionColor
        
        var scale = Float(0)
        private let padding = [UInt8](repeating: 0, count: 12)
    }
    
    typealias ValueType = Data
    
    let key: String
    var rawData = ValueType()
    
    var variables: [ShaderParameter] {
        return []
    }
    
    init(key: String = ShaderConst.materialKey) {
        self.key = key
    }
}
