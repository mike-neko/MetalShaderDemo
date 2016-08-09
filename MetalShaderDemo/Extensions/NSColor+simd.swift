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
    var rgb: float3 { return float3(Float(self.redComponent), Float(self.greenComponent), Float(self.blueComponent)) }
    var rgba: float4 { return float4(Float(self.redComponent), Float(self.greenComponent), Float(self.blueComponent), Float(self.alphaComponent)) }
}
