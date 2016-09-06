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
        
        color.color = float4(1, 0, 0, 1)
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
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ShaderManager.sharedInstance.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return ShaderManager.sharedInstance.name(index: row)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let man = ShaderManager.sharedInstance
        man.apply(index: listView.selectedRow)
        if let material = man.materials.first {
            material.rawData.diffuse = float4(1, 1, 0.5, 1)
            ShaderManager.sharedInstance.changeProperty(property: material)
        }
    }
}
