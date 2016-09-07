//
//  ShaderListViewController.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import SceneKit

class ShaderListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate,
                                NSCollectionViewDelegate, NSCollectionViewDataSource,
                                NSCollectionViewDelegateFlowLayout {
    
    private struct CellData {
        let key: String
        let data: ShaderParameter
    }
    
    @IBOutlet weak var listView: NSTableView!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    private var parameters = [CellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
        applyShader(index: listView.selectedRow)
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return parameters.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let param = parameters[indexPath.item]
        switch param.data.type {
        case .rgbColor(_, let value):
            if let item = collectionView.makeItem(withIdentifier: "ColorEditPanel", for: indexPath) as? ColorEditPanel {
                item.color = value()
                item.key = param.key
                item.name = param.data.name
                item.changedColorCallback = { newColor, key, name in
                    ShaderManager.sharedInstance.changeProperty(key: key, name: name, value: newColor)
                }
                return item
            }
        default: break
        }

        return NSCollectionViewItem()
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {

        return NSSize(width: collectionView.bounds.size.width, height: 130)
    }
    
    // MARK: -
    
    private func applyShader(index: Int) {
        parameters.removeAll()
        
        let man = ShaderManager.sharedInstance
        let result = man.apply(index: index)
        guard result.result else { return }

        result.properties.forEach {
            let key = $0.key
            $0.variables.forEach {
                parameters.append(CellData(key: key, data: $0))
            }
        }
        
        collectionView.reloadData()
//        result.properties.forEach {
//            let key = $0.key
//            $0.variables.forEach {
//                switch $0.type {
//                case .rgbColor(_, let value):
//                    //                    color.color = value()
//                    //                    color.key = key
//                    //                    color.name = $0.name
//                    //                    ShaderManager.sharedInstance.changeProperty(key: key, name: $0.name, value: color.color)
//                    //                    // TODO: ???
//                    //                    color.changedColorCallback = { newColor, key, name in
//                    //                        ShaderManager.sharedInstance.changeProperty(key: key, name: name, value: newColor)
//                    //                    }
//                    break
//                default: break
//                }
//            }
//        }
        
        
        
        // TODO:
//        guard let material = man.materials.first else { return }
//        if let material = man.materials.first {
//            material.rawData.diffuse = float3(1, 1, 0.5)
//            ShaderManager.sharedInstance.changeProperty(property: material)
//        }
    }
}
