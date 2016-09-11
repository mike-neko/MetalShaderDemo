//
//  PreviewController.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

class PreviewController: NSViewController {
    static let NeedPlayNotification = "NeedPlayNotification"
    static let NeedStopNotification = "NeedStopNotification"
    
    @IBOutlet weak var preview: SCNView!
    private weak var targetMaterial: SCNMaterial!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()

//        let geometry = SCNSphere(radius: 3)
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
        light.position = SCNVector3(x: 0.5, y: 1, z: 0.5)
        scene.rootNode.addChildNode(light)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = Color(white: 0.2, alpha: 1)
        scene.rootNode.addChildNode(ambientLightNode)
        
        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(scnVector4: SCNVector4(x: CGFloat(1), y: CGFloat(0), z: CGFloat(1), w: CGFloat(M_PI)*2))
        animation.duration = 3
        animation.repeatCount = MAXFLOAT //repeat forever
        torus.addAnimation(animation, forKey: "rotation")
        
        preview.scene = scene
        preview.allowsCameraControl = true
        preview.showsStatistics = true
        preview.backgroundColor = Color.gray
        
        ShaderManager.sharedInstance.targetMaterial = targetMaterial
        // 座標変換省略
        ShaderManager.sharedInstance.light.lightPosition = float3(0) - float3(light.position)
        ShaderManager.sharedInstance.light.eyePosition = float3(camera.position)
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(PreviewController.playAnimation),
                       name: NSNotification.Name(rawValue: PreviewController.NeedPlayNotification),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(PreviewController.stopAnimation),
                       name: NSNotification.Name(rawValue: PreviewController.NeedStopNotification),
                       object: nil)
    }
 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: -
    
    func playAnimation() {
        preview.scene?.isPaused = false
    }
    
    func stopAnimation() {
        preview.scene?.isPaused = true
    }
}
