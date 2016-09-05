//
//  ColorEditorView.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/05.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

class ColorEditorView: NSBox {
    @IBOutlet private weak var rSlider: NSSlider!
    @IBOutlet private weak var gSlider: NSSlider!
    @IBOutlet private weak var bSlider: NSSlider!
    @IBOutlet private weak var rText: NSTextField!
    @IBOutlet private weak var gText: NSTextField!
    @IBOutlet private weak var bText: NSTextField!
    
    @IBOutlet private weak var valueText: NSTextField!
    @IBOutlet private weak var colorButton: NSColorWell!
    
    var changedColorCallback: ((_ color: float4) -> Void)? = nil
    
    var color: float4 = float4(1) {
        didSet {
            rSlider.integerValue = Int(color.x * 255)
            gSlider.integerValue = Int(color.y * 255)
            bSlider.integerValue = Int(color.z * 255)
            rText.stringValue = String(rSlider.integerValue)
            gText.stringValue = String(gSlider.integerValue)
            bText.stringValue = String(bSlider.integerValue)
            
            valueText.stringValue = String(format: "R: %.02f G: %.02f B: %02.f",
                                           color.x, color.y, color.z)
            colorButton.color = NSColor(calibratedRed: CGFloat(color.x), green: CGFloat(color.y),
                                        blue: CGFloat(color.z), alpha: CGFloat(color.w))
            
            if oldValue.x != color.x || oldValue.y != color.y
                || oldValue.z != color.z || oldValue.w != color.w {
                changedColorCallback?(color)
            }
        }
    }
    
    var name: String {
        get {
            return title
        }
        set {
            title = newValue
        }
    }
    
    @IBAction func changeSlider(_ sender: NSSlider) {
        color = float4(rSlider.floatValue / 255, gSlider.floatValue / 255, bSlider.floatValue / 255, 1)
    }
    
    @IBAction func changeColorButton(_ sender: NSColorWell) {
        color = sender.color.rgba
    }
}
