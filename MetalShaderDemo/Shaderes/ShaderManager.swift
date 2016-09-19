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
    static let sharedInstance = ShaderManager()
    
    private let list: [Shader]
    var count: Int { return list.count }
    private(set) var activeIndex = Int(0)
    
    weak var targetMaterial: SCNMaterial? = nil
    var changedActiveShaderCallback: ((Int, SCNProgram) -> Void)? = nil
    
    var light = LightBuffer.Data()
    var materials: [MaterialBuffer] {
        get {
            return list[activeIndex].properties.flatMap { $0 as? MaterialBuffer }
        }
    }
    
    private init() {
        list = [
            Shader.cubemapping,
            
            Shader(name: "VertexColor", vertexName: "colorVertex", fragmentName: "colorFragment",
                   properties: [ColorBuffer(rawData: ShaderDefault.diffuseColor)]),
            Shader(name: "TextureColor", vertexName: "textureVertex", fragmentName: "textureFragment",
                   properties: [TextureProperty(textureName: "texture")]),
            
            Shader.lambert, Shader.halfLambert,
            Shader.phong, Shader.blinnPhong,
            Shader.orenNayar,
            
            Shader.bumpMapping,
        ]
    }

    func name(index: Int) -> String? {
        guard list.indices.contains(index) else { return nil }
        return list[index].name
    }
    
    @discardableResult
    func apply(index: Int) -> (result: Bool, properties: [ShaderPropertyType]) {
        guard list.indices.contains(index) else { return (result: false, properties: []) }
        let shader = list[index]

        let program = SCNProgram()
        program.vertexFunctionName = shader.vertexName
        program.fragmentFunctionName = shader.fragmentName
        
        activeIndex = index
        changedActiveShaderCallback?(index, program)

        guard let material = targetMaterial else { return (result: false, properties: shader.properties) }

        material.program = program
        shader.properties.forEach {
            if let buf = $0 as? LightBuffer {
                buf.rawData = light
            }
            material.setValue($0.data, forKey: $0.key)
        }
        return (result: true, properties: shader.properties)
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
