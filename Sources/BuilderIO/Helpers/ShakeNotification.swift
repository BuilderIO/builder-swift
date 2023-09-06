//
//  File.swift
//  
//
//  Created by Shyam Seshadri on 9/6/23.
//

import Foundation
import UIKit

extension NSNotification.Name {
    public static let deviceDidShakeNotification = NSNotification.Name("BuilderIOShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        NotificationCenter.default.post(name: .deviceDidShakeNotification, object: event)
    }
}
