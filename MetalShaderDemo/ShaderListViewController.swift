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
    @IBOutlet weak var geometryList: NSComboBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        PreviewController.Geometry.all.forEach {
            geometryList.addItem(withObjectValue: $0.rawValue)
        }
        geometryList.selectItem(at: 0)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        ShaderManager.sharedInstance.apply(index: 0)
        listView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
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
        let notification = NotificationKey.notifcation(name: NotificationKey.ChangeShader,
                                                       index: listView.selectedRow)
        NotificationCenter.default.post(notification)
    }

    // MARK: -

    @IBAction func tapAnimaitionPlaySegment(sender: NSSegmentedControl) {
        let name = (sender.selectedSegment == 0) ? NotificationKey.NeedPlay
                                                 : NotificationKey.NeedStop
        NotificationCenter.default.post(NotificationKey.notifcation(name: name))
    }
    
    @IBAction func changeGeometry(sender: NSComboBox) {
        NotificationCenter.default.post(NotificationKey.notifcation(name: NotificationKey.ChangeGeometry,
                                                                    key: sender.stringValue))
    }

    @IBAction func tapBackgroundSegment(sender: NSSegmentedControl) {
        NotificationCenter.default.post(NotificationKey.notifcation(name: NotificationKey.ChangeBackground,
                                                                    on: (sender.selectedSegment == 1)))
    }
}
