//
//  PreviewController.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

class PreviewController: NSViewController, SCNSceneRendererDelegate {
    
    private let ModelNodeName = "model"
    
    enum Model: String {
        case torus, box, sphere
        case head

        func makeModel() -> (node: SCNNode, material: SCNMaterial)? {
            let geometry: SCNGeometry
            switch self {
            case .torus:
                geometry = SCNTorus(ringRadius: 3, pipeRadius: 1)
            case .box:
                geometry = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 0)
            case .sphere:
                geometry = SCNSphere(radius: 3)
            case .head:
                guard let root = SCNScene(named: "head.dae")?.rootNode,
                      let model = root.childNode(withName: "model", recursively: true)?.geometry else {
                        return nil
                }
                geometry = model
            }
            
            guard let material = geometry.firstMaterial else {
                return nil
            }
            return (node: SCNNode(geometry: geometry), material: material)
        }
        
        var texture: String? {
            switch self {
            case .torus, .box, .sphere:
                return "brick_texture.png"
            case .head:
                return nil
            }
        }
        
        var normal: String? {
            switch self {
            case .torus, .box, .sphere:
                return "brick_texture.png"
            case .head:
                return "brick_normal.png"
            }
        }

        static let names = [
            torus, box, sphere,
            head
        ]
    }
    
    @IBOutlet weak var preview: SCNView!
    private weak var targetMaterial: SCNMaterial!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        preview.delegate = self
        
        let scene = SCNScene()
        preview.scene = scene
        preview.allowsCameraControl = true
        preview.showsStatistics = true
        preview.backgroundColor = Color.gray
        
        applyModel(type: .torus)
        
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
                       selector: #selector(PreviewController.changeModel),
                       name: NSNotification.Name(rawValue: NotificationKey.ChangeModel),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(PreviewController.changeBackground),
                       name: NSNotification.Name(rawValue: NotificationKey.ChangeBackground),
                       object: nil)
    }
 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @discardableResult
    private func applyModel(type: Model) -> Bool {
        guard let scene = preview.scene else { return false }
        
        guard let model = type.makeModel() else { return false }
        
        if let old = scene.rootNode.childNode(withName: ModelNodeName, recursively: true) {
            old.removeFromParentNode()
        }
        
        let node = model.node
        node.name = ModelNodeName
        scene.rootNode.addChildNode(node)

        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        if case .head = type {
            animation.toValue = NSValue(scnVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
            node.position = SCNVector3(0, 2, 0)
            node.scale = SCNVector3(18, 18, 18)
        } else {
            animation.toValue = NSValue(scnVector4: SCNVector4(x: CGFloat(1), y: CGFloat(0), z: CGFloat(1), w: CGFloat(M_PI)*2))
        }
        animation.duration = 3
        animation.repeatCount = MAXFLOAT //repeat forever
        node.addAnimation(animation, forKey: "rotation")
       
        targetMaterial = model.material
        let man = ShaderManager.sharedInstance
        man.targetMaterial = targetMaterial
        man.apply(index: man.activeIndex)
        
        return true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let camera = renderer.pointOfView {
            ShaderManager.sharedInstance.light.eyePosition = float3(camera.position)
        }
    }
    
    // MARK: -
    
    func playAnimation() {
        preview.scene?.isPaused = false
    }
    
    func stopAnimation() {
        preview.scene?.isPaused = true
    }

    func changeModel(notification: NSNotification) {
        guard let key = notification.object as? String,
            let type = Model(rawValue: key) else { return }
        applyModel(type: type)
    }

    func changeBackground(notification: NSNotification) {
        guard let on = notification.object as? Bool else { return }
        preview.scene?.background.contents
            = on ? ["px", "nx", "py", "ny", "pz", "nz"] : nil
    }
}
