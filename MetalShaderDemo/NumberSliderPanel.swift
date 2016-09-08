//
//  NumberSliderPanel.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/07.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import Cocoa

class NumberSliderPanel: NSCollectionViewItem {
    @IBOutlet private weak var parentBox: NSBox!
    @IBOutlet private weak var slider: NSSlider!
    @IBOutlet private weak var minText: NSTextField!
    @IBOutlet private weak var maxText: NSTextField!
    @IBOutlet private weak var nowText: NSTextField!

    var changedValueCallback: ((_ value: Float, _ key: String, _ name: String) -> Void)? = nil
    
    var value: Float = 0 {
        didSet {
            slider.floatValue = value
            value = slider.floatValue
            nowText.stringValue = String(format: "%.03f", value)

            if oldValue != value {
                changedValueCallback?(value, key, name)
            }
        }
    }

    var range = (min: Float(0), max: Float(1)) {
        didSet {
            guard range.min < range.max else {
                range = oldValue
                return
            }
            minText.stringValue = String(format: "%.03f", range.min)
            maxText.stringValue = String(format: "%.03f", range.max)
            slider.minValue = Double(range.min)
            slider.maxValue = Double(range.max)
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
        value = sender.floatValue
    }

}
