import UIKit

extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Post a notification when a shake gesture is detected
            NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
        }
    }
}

extension Notification.Name {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}
