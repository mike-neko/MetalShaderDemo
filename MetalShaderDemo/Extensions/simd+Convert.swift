//
//  simd+Convert.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/09.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import simd
import SceneKit

extension float4 {
    init(xyz: float3, w: Float) {
        self.init(xyz.x, xyz.y, xyz.z, w)
    }
    
    init(vector4: SCNVector4) {
        self.init(Float(vector4.x), Float(vector4.y), Float(vector4.z), Float(vector4.w))
    }
    
    init(vector3: SCNVector3, w: CGFloat) {
        self.init(Float(vector3.x), Float(vector3.y), Float(vector3.z), Float(w))
    }
}

extension SCNVector4 {
    init(vector3: SCNVector3, w: CGFloat) {
        self.init(Float(vector3.x), Float(vector3.y), Float(vector3.z), Float(w))
    }
}
