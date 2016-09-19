//
//  PreviewController.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

class PreviewController: NSViewController {
    
    private let ModelNodeName = "model"
    
    enum Geometry: String {
        case torus, box, sphere
        
        static let all = [
            torus, box, sphere
        ]
    }
    
    @IBOutlet weak var preview: SCNView!
    private weak var targetMaterial: SCNMaterial!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        preview.scene = scene
        preview.allowsCameraControl = true
        preview.showsStatistics = true
        preview.backgroundColor = Color.gray
        
        applyGeometry(type: .torus)
        
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
        
        // 座標変換省略
        ShaderManager.sharedInstance.light.lightPosition = float3(light.position)
        ShaderManager.sharedInstance.light.eyePosition = float3(camera.position)
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(PreviewController.playAnimation),
                       name: NSNotification.Name(rawValue: NotificationKey.NeedPlay),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(PreviewController.stopAnimation),
                       name: NSNotification.Name(rawValue: NotificationKey.NeedStop),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(PreviewController.changeGeometry),
                       name: NSNotification.Name(rawValue: NotificationKey.ChangeGeometry),
                       object: nil)
    }
 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @discardableResult
    private func applyGeometry(type: Geometry) -> Bool {
        guard let scene = preview.scene else { return false }
        
        let geometry: SCNGeometry
        switch type {
        case .torus:
            geometry = SCNTorus(ringRadius: 3, pipeRadius: 1)
        case .box:
            geometry = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 0)
        case .sphere:
            geometry = SCNSphere(radius: 3)
        }
        
        if let old = scene.rootNode.childNode(withName: ModelNodeName, recursively: true) {
            old.removeFromParentNode()
        }
        
        let model = SCNNode(geometry: geometry)
        model.name = ModelNodeName
        scene.rootNode.addChildNode(model)

        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(scnVector4: SCNVector4(x: CGFloat(1), y: CGFloat(0), z: CGFloat(1), w: CGFloat(M_PI)*2))
        animation.duration = 3
        animation.repeatCount = MAXFLOAT //repeat forever
        model.addAnimation(animation, forKey: "rotation")
        
        targetMaterial = geometry.firstMaterial
        let man = ShaderManager.sharedInstance
        man.targetMaterial = targetMaterial
        man.apply(index: man.activeIndex)
        
        return true
    }
    
    // MARK: -
    
    func playAnimation() {
        preview.scene?.isPaused = false
    }
    
    func stopAnimation() {
        preview.scene?.isPaused = true
    }

    func changeGeometry(notification: NSNotification) {
        guard let key = notification.object as? String,
            let type = Geometry(rawValue: key) else { return }
        applyGeometry(type: type)
    }
}
