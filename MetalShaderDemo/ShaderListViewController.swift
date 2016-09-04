//
//  ShaderListViewController.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import Cocoa

class ShaderListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var listView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        ShaderManager.sharedInstance.apply(index: 0)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ShaderManager.sharedInstance.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return ShaderManager.sharedInstance.name(index: row)
    }
}
