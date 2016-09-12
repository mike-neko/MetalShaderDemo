//
//  NotificationCommon.swift
//  MetalShaderDemo
//
//  Created by M.Ike on 2016/09/13.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import Foundation

struct NotificationKey {
    static let NeedPlay = "NeedPlayNotification"
    static let NeedStop = "NeedStopNotification"
    
    static let ChangeShader = "ChangeShaderNotification"    // arg..index
   
    static let ChangeGeometry = "ChangeGeometryNotification"    // arg..index
    
    static func notifcation(name: String) -> Notification {
        var notifcation = Notification(name: Notification.Name(rawValue: name))
        notifcation.object = index
        return notifcation
    }

    static func notifcation(name: String, index: Int) -> Notification {
        var notifcation = Notification(name: Notification.Name(rawValue: name))
        notifcation.object = index
        return notifcation
    }

    static func notifcation(name: String, key: String) -> Notification {
        var notifcation = Notification(name: Notification.Name(rawValue: name))
        notifcation.object = key
        return notifcation
    }
}
