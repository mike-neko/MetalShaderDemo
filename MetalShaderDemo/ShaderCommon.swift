//
//  ShaderCommon.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

// MARK: -
struct ShaderParameter {
    var name: String
    var type: ShaderParameterType
}

enum ShaderParameterType {
    
    case color((float4) -> Void)
    case position((float3) -> Void)
//    case texture, textureList
    case normalizeValue
    case floatValue(min: Float, max: Float)
    
    @discardableResult
    func update(newValue: Any) -> Bool {
        switch self {
        case .color(let callback):
            guard let value = newValue as? float4 else { return false }
            callback(value)
            return true
        case .position(let callback):
            guard let value = newValue as? float3 else { return false }
            callback(value)
            return true
        default: return false
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
        return textureName.isEmpty ? SCNMaterialProperty(contents: NSColor.clear)
            : SCNMaterialProperty(contents: textureName)
    }
    var variables: [ShaderParameter] { return [] }
    
    var textureName: String
    
    init(key: String, textureName: String) {
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
    typealias ValueType = float4
    
    let key: String
    var rawData: ValueType

    var variables: [ShaderParameter] {
        return [
            ShaderParameter(name: "Vertex Color", type: .color { self.rawData = $0 })
        ]
    }
    
    init(key: String, rawData: ValueType) {
        self.key = key
        self.rawData = rawData
    }
}

class LightBuffer: ShaderPropertyProtocol {
    struct Data {
        var lightPosition: float3
        var eyePosition: float3
        var color: float4
    }

    typealias ValueType = Data
    
    let key: String
    var rawData = ValueType(lightPosition: float3(), eyePosition: float3(), color: float4())
    
    var variables: [ShaderParameter] {
        return [
            ShaderParameter(name: "Light Color", type: .color { self.rawData.color = $0 })
        ]
    }
    
    init(key: String) {
        self.key = key
    }
}

class MaterialBuffer: ShaderPropertyProtocol {
    struct Data {
        var diffuse = float4(1, 1, 1, 1)
        var specular = float4(1, 1, 1, 1)
        var shininess = Float(10)
        var emission = float4(0, 0, 0, 1)
        
        var roughness = Float(0)
        
        private let padding = [UInt8](repeating: 0, count: 12)
    }
    
    typealias ValueType = Data
    
    let key: String
    var rawData = ValueType()
    
    var variables: [ShaderParameter] {
        return [
            ShaderParameter(name: "Diffuse Color", type: .color { self.rawData.diffuse = $0 })
        ]
    }
    
    init(key: String) {
        self.key = key
    }
}


