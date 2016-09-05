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
    
    private init() {
        list = [
            Shader(name: "VertexColor", vertexName: "colorVertex", fragmentName: "colorFragment",
                   properties: [ColorBuffer(key: "colorBuffer", rawData: NSColor.red.rgba)]),
            Shader(name: "TextureColor", vertexName: "textureVertex", fragmentName: "textureFragment",
                   properties: [TextureProperty(key: "texture", textureName: "texture")])
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
        shader.properties.forEach { material.setValue($0.data, forKey: $0.key) }
        return true
    }
    
    @discardableResult
    func changeProperty(key: String, name: String, value: Any) -> Bool {
        let shader = list[activeIndex]
        shader.properties.filter { $0.key == key }.forEach { property in
            property.variables[0].type.update(newValue: value)
            
            guard let material = targetMaterial else { return }
            material.setValue(property.data, forKey: property.key)

        }
        return false
    }
}
