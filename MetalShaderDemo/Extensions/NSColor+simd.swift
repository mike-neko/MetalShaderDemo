//
//  NSColor+simd.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/08/09.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import Cocoa
import simd

extension NSColor {
    var rgb: float3 {
        guard let color = self.usingColorSpace(NSColorSpace.genericRGB) else {
            return float3(0)
        }
        return float3(Float(color.redComponent),
                      Float(color.greenComponent),
                      Float(color.blueComponent))
    }
    
    var rgba: float4 {
        guard let color = self.usingColorSpace(NSColorSpace.genericRGB) else {
            return float4(0)
        }
        return float4(Float(color.redComponent),
                      Float(color.greenComponent),
                      Float(color.blueComponent),
                      Float(color.alphaComponent))
    }
}
