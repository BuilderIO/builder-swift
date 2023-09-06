
import Foundation
import UIKit

public let deviceDidShakeNotification = NSNotification.Name("BuilderIOShakeNotification")

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        NotificationCenter.default.post(name: deviceDidShakeNotification, object: event)
    }
}
