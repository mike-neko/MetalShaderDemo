//
//  PreviewController.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

class PreviewController: NSViewController {
    @IBOutlet weak var preview: SCNView!
    private weak var targetMaterial: SCNMaterial!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        
        let geometry = SCNTorus(ringRadius: 3, pipeRadius: 1)
        targetMaterial = geometry.firstMaterial
        let torus = SCNNode(geometry: geometry)
        torus.name = "torus"
        scene.rootNode.addChildNode(torus)
        
        let camera = SCNNode()
        camera.camera = SCNCamera()
        scene.rootNode.addChildNode(camera)
        camera.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let light = SCNNode()
        light.light = SCNLight()
        light.light!.type = SCNLight.LightType.omni
        light.position = SCNVector3(x: 0, y: 1, z: 0)
        scene.rootNode.addChildNode(light)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = NSColor(calibratedWhite: 0.1, alpha: 1)
        scene.rootNode.addChildNode(ambientLightNode)
        
        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(scnVector4: SCNVector4(x: CGFloat(1), y: CGFloat(0), z: CGFloat(1), w: CGFloat(M_PI)*2))
        animation.duration = 3
        animation.repeatCount = MAXFLOAT //repeat forever
        torus.addAnimation(animation, forKey: nil)
        
        preview.scene = scene
        preview.allowsCameraControl = true
        preview.showsStatistics = true
        preview.backgroundColor = NSColor.lightGray
        
        ShaderManager.sharedInstance.targetMaterial = targetMaterial
        
        
//        loadShader()
//        shaderList.enumerated().forEach { index, shader in
//            let menu = NSMenuItem(title: shader.name, action: #selector(tapShaderMenu), keyEquivalent: "")
//            menu.tag = index
//            //            shaderMenu.addItem(menu)
//        }
//        
//        // TEST:
//        //torus.rotation = SCNVector4(x: CGFloat(0), y: CGFloat(0), z: CGFloat(1), w: CGFloat(M_PI) / 2)
//        //        torusNode.geometry!.firstMaterial!.diffuse.contents = NSImage(named: "texture")
//        //torus.rotation = SCNVector4(x: CGFloat(0), y: CGFloat(0), z: CGFloat(1), w: CGFloat(M_PI) / 2)
//        applyShader(index: 3, target: torusNode.geometry!.firstMaterial!)
//        applyShader(index: 5, target: base.geometry!.firstMaterial!)
    }
    
}
