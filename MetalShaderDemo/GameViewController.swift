//
//  GameViewController.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/07.
//  Copyright (c) 2016年 M.Ike. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    struct ShaderInfo {
        let name: String
        let program: SCNProgram
        let setup: (material: SCNMaterial) -> ()
        
        init(name: String, vertexName: String, fragmentName: String, setup: ((material: SCNMaterial) -> ())) {
            let program = SCNProgram()
            program.vertexFunctionName = vertexName
            program.fragmentFunctionName = fragmentName

            self.name = name
            self.program = program
            self.setup = setup
        }
    }
    
    struct ColorBuffer {
        var color: float4
    }
    
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
    
    let defaultDiffuseColor = float4(1, 0, 0, 1)
    let defaultSpecularColor = float4(1, 1, 1, 1)
    let defaultSpecularShininess = Float(100)
    let defaultEmmisionColor = float4(0, 0, 0, 1)
    
    private(set) var shaderList = [ShaderInfo]()

    private weak var torusNode: SCNNode!
    private weak var lightNode: SCNNode!
    private weak var cameraNode: SCNNode!
    @IBOutlet weak var gameView: GameView!
    @IBOutlet weak var shaderMenu: NSMenu!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        // create a new scene
        let scene = SCNScene()

        let torus = SCNNode(geometry: SCNTorus(ringRadius: 3, pipeRadius: 1))
        torus.name = "torus"
        scene.rootNode.addChildNode(torus)
        torusNode = torus
        
        // create and add a camera to the scene
        let camera = SCNNode()
        camera.camera = SCNCamera()
        scene.rootNode.addChildNode(camera)
        camera.position = SCNVector3(x: 0, y: 0, z: 15)
        cameraNode = camera
        
        // create and add a light to the scene
        let light = SCNNode()
        light.light = SCNLight()
        light.light!.type = SCNLightTypeOmni
        light.position = SCNVector3(x: 0, y: 5, z: 15)
        scene.rootNode.addChildNode(light)
        lightNode = light
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = NSColor(calibratedWhite: 0.1, alpha: 1)
//        scene.rootNode.addChildNode(ambientLightNode)
        
        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(scnVector4: SCNVector4(x: CGFloat(1), y: CGFloat(0), z: CGFloat(1), w: CGFloat(M_PI)*2))
        animation.duration = 3
        animation.repeatCount = MAXFLOAT //repeat forever
        torus.add(animation, forKey: nil)
      
        let base = SCNNode(geometry: SCNTorus(ringRadius: 3, pipeRadius: 1))
        scene.rootNode.addChildNode(base)
        base.position = SCNVector3(x: -6, y: 0, z: 0)
        base.add(animation, forKey: nil)

        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.lightGray
        
        loadShader()
        shaderList.enumerated().forEach { index, shader in
            let menu = NSMenuItem(title: shader.name, action: #selector(tapShaderMenu), keyEquivalent: "")
            menu.tag = index
            shaderMenu.addItem(menu)
        }
        
        // TEST:
//        torus.rotation = SCNVector4(x: CGFloat(1), y: CGFloat(0), z: CGFloat(1), w: CGFloat(M_PI) / 4)
        applyShader(index: 7, target: torusNode.geometry!.firstMaterial!)
        applyShader(index: 6, target: base.geometry!.firstMaterial!)
    }
    
    func tapShaderMenu(sender: NSMenuItem) {
        guard let material = torusNode.geometry?.firstMaterial else { return }

        applyShader(index: sender.tag, target: material)
    }
    
    @IBAction func tapSaderReset(sender: NSMenuItem) {
        guard let material = torusNode.geometry?.firstMaterial else { return }

        material.program = nil
    }
    
    private func loadShader() {
        var light = LightData(lightPosition: float3(lightNode.position),
                              eyePosition: float3(cameraNode.position),
                              color: (lightNode.light!.color as! NSColor).rgba)
        var mat = MaterialData(diffuse: defaultDiffuseColor,
                               specular: defaultSpecularColor,
                               shininess: defaultSpecularShininess,
                               emission: defaultEmmisionColor,
                               roughness: 1)
        
        shaderList = [
            ShaderInfo(
                name: "VertexColor",
                vertexName: "colorVertex",
                fragmentName: "colorFragment",
                setup: { material in
                    var custom = ColorBuffer(color: float4(1, 0, 0, 1))
                    material.setValue(NSData(bytes: &custom, length:sizeof(ColorBuffer.self)), forKey: "custom")
            }),
            ShaderInfo(
                name: "TextureColor",
                vertexName: "textureVertex",
                fragmentName: "textureFragment",
                setup: { material in
                    material.setValue(SCNMaterialProperty(contents: NSImage(named: "texture")!), forKey: "texture")
            }),
            ShaderInfo(
                name: "Phong Shader",
                vertexName: "phongVertex",
                fragmentName: "phongFragment",
                setup: { material in
                    material.setValue(SCNMaterialProperty(contents: NSImage(named: "texture")!), forKey: "texture")
                    material.setValue(NSData(bytes: &light, length:sizeof(LightData.self)), forKey: "light")
                    material.setValue(NSData(bytes: &mat, length:sizeof(MaterialData.self)), forKey: "material")
            }),
            ShaderInfo(
                name: "Blinn Phong Shader",
                vertexName: "phongVertex",
                fragmentName: "blinnPhongFragment",
                setup: { material in
                    material.setValue(SCNMaterialProperty(contents: NSImage(named: "texture")!), forKey: "texture")
                    material.setValue(NSData(bytes: &light, length:sizeof(LightData.self)), forKey: "light")
                    material.setValue(NSData(bytes: &mat, length:sizeof(MaterialData.self)), forKey: "material")
            }),
            ShaderInfo(
                name: "Cook Torrance Shader",
                vertexName: "phongVertex",
                fragmentName: "cookTorranceFragment",
                setup: { material in
                    mat.diffuse = float4(0.1, 0.1, 0.1, 1)
                    mat.shininess = 2   //2
                    mat.roughness = 0.2
                    //                    material.setValue(SCNMaterialProperty(contents: NSImage(named: "texture")!), forKey: "texture")
                    material.setValue(NSData(bytes: &light, length:sizeof(LightData.self)), forKey: "light")
                    material.setValue(NSData(bytes: &mat, length:sizeof(MaterialData.self)), forKey: "material")
            }),
            ShaderInfo(
                name: "Cook Torrance Shader",
                vertexName: "phongVertex",
                fragmentName: "cookTorranceFragment",
                setup: { material in
                    mat.diffuse = float4(0.1, 0.1, 0.1, 1)
                    mat.shininess = 2
                    mat.roughness = 0.3
                    //                    material.setValue(SCNMaterialProperty(contents: NSImage(named: "texture")!), forKey: "texture")
                    material.setValue(NSData(bytes: &light, length:sizeof(LightData.self)), forKey: "light")
                    material.setValue(NSData(bytes: &mat, length:sizeof(MaterialData.self)), forKey: "material")
            }),
            ShaderInfo(
                name: "Lambert Shader",
                vertexName: "lambertVertex",
                fragmentName: "lambertFragment",
                setup: { material in
                    material.setValue(SCNMaterialProperty(contents: NSImage(named: "texture")!), forKey: "texture")
                    material.setValue(NSData(bytes: &light, length:sizeof(LightData.self)), forKey: "light")
                    material.setValue(NSData(bytes: &mat, length:sizeof(MaterialData.self)), forKey: "material")
            }),
            ShaderInfo(
                name: "Oren-Nayar Shader",
                vertexName: "orenNayarVertex",
                fragmentName: "orenNayarFragment",
                setup: { material in
                    material.setValue(SCNMaterialProperty(contents: NSImage(named: "texture")!), forKey: "texture")
                    material.setValue(NSData(bytes: &light, length:sizeof(LightData.self)), forKey: "light")
                    material.setValue(NSData(bytes: &mat, length:sizeof(MaterialData.self)), forKey: "material")
            }),
        ]
    }
    
    private func applyShader(index: Int, target: SCNMaterial) {
        guard shaderList.indices.contains(index) else { return }
        
        let shader = shaderList[index]
        target.program = shader.program
        shader.setup(material: target)
    }
}
