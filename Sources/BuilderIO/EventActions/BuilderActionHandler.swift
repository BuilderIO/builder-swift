import SwiftUI
import SwiftyJSON

public typealias BuilderActionHandler = (BuilderAction) -> Void

public class BuilderActionManager: ObservableObject {
  public var actionHandler: BuilderActionHandler?

  public init() {
    // Explicit public initializer
  }

  public func setHandler(_ handler: @escaping BuilderActionHandler) {
    self.actionHandler = handler
  }

  public func handleButtonPress(builderAction: BuilderAction) {

    if let options = builderAction.options, let linkString = options["link"].string {
      // 2. Attempt to create a URL from the link string
      if let url = URL(string: linkString) {
        // 3. Open the URL in an external browser
        UIApplication.shared.open(url, options: [:]) { success in
          if success {
            print("Successfully opened link: \(linkString)")
          } else {
            print("Failed to open link: \(linkString)")
          }
        }
        return  // Exit the function as we've handled the link
      } else {
        print("Invalid URL string: \(linkString)")
      }
    } else {
      actionHandler?(builderAction)
    }
  }
}

public class BuilderAction {
  let componentId: String
  let options: JSON?
  let eventActions: JSON?

  public init(componentId: String, options: JSON?, eventActions: JSON?) {
    self.componentId = componentId
    self.options = options
    self.eventActions = eventActions
  }
}

public struct ButtonActionManagerKey: EnvironmentKey {
  public static let defaultValue: BuilderActionManager? = nil
}

extension EnvironmentValues {
  public var buttonActionManager: BuilderActionManager? {
    get { self[ButtonActionManagerKey.self] }
    set { self[ButtonActionManagerKey.self] = newValue }
  }
}
