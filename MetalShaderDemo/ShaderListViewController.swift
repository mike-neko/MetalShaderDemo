//
//  ShaderListViewController.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

class ShaderListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var listView: NSTableView!
    
    @IBOutlet weak var propertyView: NSScrollView!
    @IBOutlet weak var color: ColorEditorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        color.color = float3(1, 0, 0)
        color.key = "colorBuffer"
        color.name = "Vertex Color"
        color.changedColorCallback = { newColor, key, name in
            ShaderManager.sharedInstance.changeProperty(key: key, name: name, value: newColor)
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        ShaderManager.sharedInstance.apply(index: 0)
        listView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
 
        let size = propertyView.bounds.size
        color.frame = NSRect(origin: CGPoint(x: 0, y: size.height - color.bounds.size.height),
                             size: CGSize(width: size.width, height: color.bounds.size.height))
        
        propertyView.addSubview(color)
   }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    // MARK: -
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ShaderManager.sharedInstance.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return ShaderManager.sharedInstance.name(index: row)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        applyShader(index: listView.selectedRow)
    }

    // MARK: -
    
    private func applyShader(index: Int) {
        let man = ShaderManager.sharedInstance
        let result = man.apply(index: index)
        guard result.result else { return }

        result.properties.forEach {
            let key = $0.key
            $0.variables.forEach {
                switch $0.type {
                case .rgbColor(_, let value):
                    color.color = value()
                    color.key = key
                    color.name = $0.name
                    ShaderManager.sharedInstance.changeProperty(key: key, name: $0.name, value: color.color)
                    // TODO: ???
                    color.changedColorCallback = { newColor, key, name in
                        ShaderManager.sharedInstance.changeProperty(key: key, name: name, value: newColor)
                    }
                default: break
                }
            }
        }
        
        
        
        
        // TODO:
//        guard let material = man.materials.first else { return }
//        if let material = man.materials.first {
//            material.rawData.diffuse = float3(1, 1, 0.5)
//            ShaderManager.sharedInstance.changeProperty(property: material)
//        }
    }
}
