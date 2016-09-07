//
//  ColorEditPanel.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/07.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

class ColorEditPanel: NSCollectionViewItem {
    @IBOutlet private weak var parentBox: NSBox!
    @IBOutlet private weak var rSlider: NSSlider!
    @IBOutlet private weak var gSlider: NSSlider!
    @IBOutlet private weak var bSlider: NSSlider!
    @IBOutlet private weak var rText: NSTextField!
    @IBOutlet private weak var gText: NSTextField!
    @IBOutlet private weak var bText: NSTextField!
    
    @IBOutlet private weak var colorButton: NSColorWell!
    
    var changedColorCallback: ((_ color: float3, _ key: String, _ name: String) -> Void)? = nil
    
    var color: float3 = float3(1) {
        didSet {
            rSlider.integerValue = Int(color.x * 255)
            gSlider.integerValue = Int(color.y * 255)
            bSlider.integerValue = Int(color.z * 255)
            rText.stringValue = String(format: "%.02f", color.x)
            gText.stringValue = String(format: "%.02f", color.y)
            bText.stringValue = String(format: "%.02f", color.z)
            
            colorButton.color = NSColor(calibratedRed: CGFloat(color.x), green: CGFloat(color.y),
                                        blue: CGFloat(color.z), alpha: CGFloat(1))
            
            if oldValue.x != color.x || oldValue.y != color.y || oldValue.z != color.z {
                changedColorCallback?(color, key, name)
            }
        }
    }
    
    var key: String = "" {
        didSet {
            parentBox.title = "\(key) - \(name)"
        }
    }
    
    var name: String = "" {
        didSet {
            parentBox.title = "\(key) - \(name)"
        }
    }
    
    @IBAction func changeSlider(_ sender: NSSlider) {
        color = float3(rSlider.floatValue / 255, gSlider.floatValue / 255, bSlider.floatValue / 255)
    }
    
    @IBAction func changeColorButton(_ sender: NSColorWell) {
        color = sender.color.rgb
    }
}
