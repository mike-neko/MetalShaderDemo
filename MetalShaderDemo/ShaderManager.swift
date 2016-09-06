//
//  ShaderManager.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

// シェーダを管理するクラス
class ShaderManager {
    private struct Shader {
        let name: String
        let vertexName: String
        let fragmentName: String
        let properties: [ShaderPropertyType]
    }

    static let sharedInstance = ShaderManager()
    
    private let list: [Shader]
    var count: Int { return list.count }
    private(set) var activeIndex = Int(0)
    
    weak var targetMaterial: SCNMaterial? = nil
    var changedActiveShaderCallback: ((Int, SCNProgram) -> Void)? = nil
    
    var light = LightBuffer.Data(lightPosition: float3(), eyePosition: float3(), color: float4())
    var materials: [MaterialBuffer] {
        get {
            return list[activeIndex].properties.flatMap { $0 as? MaterialBuffer }
        }
    }
    
    private init() {
        list = [
            Shader(name: "VertexColor", vertexName: "colorVertex", fragmentName: "colorFragment",
                   properties: [ColorBuffer(key: "colorBuffer", rawData: NSColor.red.rgba)]),
            Shader(name: "TextureColor", vertexName: "textureVertex", fragmentName: "textureFragment",
                   properties: [TextureProperty(key: "texture", textureName: "texture")]),
            Shader(name: "Lambert Half", vertexName: "lambertVertex", fragmentName: "halfLambertFragment",
                   properties: [LightBuffer(key: "light"),
                                MaterialBuffer(key: "material"),
                                TextureProperty(key: "texture", textureName: "")])
        ]
    }

    func name(index: Int) -> String? {
        guard list.indices.contains(index) else { return nil }
        return list[index].name
    }
    
    @discardableResult
    func apply(index: Int) -> Bool {
        guard list.indices.contains(index) else { return false }
        let shader = list[index]
        
        let program = SCNProgram()
        program.vertexFunctionName = shader.vertexName
        program.fragmentFunctionName = shader.fragmentName
        
        activeIndex = index
        changedActiveShaderCallback?(index, program)

        guard let material = targetMaterial else { return false }

        material.program = program
        shader.properties.forEach {
            if let buf = $0 as? LightBuffer {
                buf.rawData = light
            }
            material.setValue($0.data, forKey: $0.key)
        }
        return true
    }
    
    @discardableResult
    func changeProperty(key: String, name: String, value: Any) -> Bool {
        guard let material = targetMaterial else { return false }

        var change = false
        let shader = list[activeIndex]
        shader.properties.filter { $0.key == key }.forEach { property in
            property.variables.filter { $0.name == name }.forEach {
                $0.type.update(newValue: value)
                material.setValue(property.data, forKey: property.key)
                change = true
            }
        }
        return change
    }
    
    @discardableResult
    func changeProperty(property: ShaderPropertyType) -> Bool {
        guard let material = targetMaterial else { return false }

        var change = false
        let shader = list[activeIndex]
        shader.properties.filter { $0.key == property.key }.forEach {
            material.setValue($0.data, forKey: $0.key)
            change = true
        }
        return change
    }

}
