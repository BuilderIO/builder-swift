import SwiftUI

public typealias ButtonActionHandler = (String, String?) -> Void

public class ButtonActionManager: ObservableObject {
  public var actionHandler: ButtonActionHandler?

  public init() {
    // Explicit public initializer
  }

  public func setHandler(_ handler: @escaping ButtonActionHandler) {
    self.actionHandler = handler
  }

  public func handleButtonPress(buttonId: String, data: String?) {
    actionHandler?(buttonId, data)
  }
}

public struct ButtonActionManagerKey: EnvironmentKey {
  public static let defaultValue: ButtonActionManager? = nil
}

extension EnvironmentValues {
  public var buttonActionManager: ButtonActionManager? {
    get { self[ButtonActionManagerKey.self] }
    set { self[ButtonActionManagerKey.self] = newValue }
  }
}
