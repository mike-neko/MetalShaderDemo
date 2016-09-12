//
//  PropertyViewController.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/12.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import Cocoa

class PropertyViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource,
                              NSCollectionViewDelegateFlowLayout {
    
    private struct CellData {
        let key: String
        let data: ShaderParameter
    }
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    private var parameters = [CellData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(PropertyViewController.changeShader),
                       name: NSNotification.Name(rawValue: NotificationKey.ChangeShader),
                       object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: -
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return parameters.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let param = parameters[indexPath.item]
        switch param.data.type {
        case .rgbColor(_, let value):
            if let item = collectionView.makeItem(withIdentifier: "ColorEditPanel", for: indexPath) as? ColorEditPanel {
                item.changedColorCallback = nil     // コールバック無効
                item.color = value()
                item.key = param.key
                item.name = param.data.name
                item.changedColorCallback = { newColor, key, name in
                    ShaderManager.sharedInstance.changeProperty(key: key, name: name, value: newColor)
                }
                return item
            }
        case .floatValue(let minValue, let maxValue, _, let value):
            if let item = collectionView.makeItem(withIdentifier: "NumberSliderPanel", for: indexPath) as? NumberSliderPanel {
                item.changedValueCallback = nil     // コールバック無効
                item.value = value()
                item.range = (min: minValue, max: maxValue)
                item.key = param.key
                item.name = param.data.name
                item.changedValueCallback = { newValue, key, name in
                    ShaderManager.sharedInstance.changeProperty(key: key, name: name, value: newValue)
                }
                return item
            }
        case .normalizeValue(_, let value):
            if let item = collectionView.makeItem(withIdentifier: "NumberSliderPanel", for: indexPath) as? NumberSliderPanel {
                item.changedValueCallback = nil     // コールバック無効
                item.value = value()
                item.range = (min: 0, max: 1)
                item.key = param.key
                item.name = param.data.name
                item.changedValueCallback = { newValue, key, name in
                    ShaderManager.sharedInstance.changeProperty(key: key, name: name, value: newValue)
                }
                return item
            }
        }
        
        return NSCollectionViewItem()
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        let height: CGFloat
        // TODO: magic number
        switch parameters[indexPath.item].data.type {
        case .rgbColor: height = 130
        case .normalizeValue, .floatValue: height = 100
        }
        return NSSize(width: collectionView.bounds.size.width, height: height)
    }
    
    func changeShader(notification: NSNotification) {
        guard let index = notification.object as? Int else { return }
        
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
    }
    
}
