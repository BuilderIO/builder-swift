import SwiftUI
import SwiftyJSON

public typealias BuilderActionHandler = (BuilderAction) -> Void

public class BuilderActionManager: ObservableObject {
  public var actionHandler: BuilderActionHandler?
  public let customNavigationScheme: String

  @Published public var path = NavigationPath()

  //<CUSTOM_SCHEME>://<MODEL_NAME>/<PAGE_URL>?<OPTIONAL_PARAMETERS>
  //"builderio://page/my-awesome-page
  public init(customNavigationScheme: String = "builderio") {
    self.customNavigationScheme = customNavigationScheme
  }

  public func setHandler(_ handler: @escaping BuilderActionHandler) {
    self.actionHandler = handler
  }

  public func handleButtonPress(builderAction: BuilderAction) {

    var url: String? = builderAction.options?["link"].string ?? builderAction.linkURL

    if let linkString = url {
      if let url = URL(string: linkString) {

        if url.scheme == customNavigationScheme {
          let model = url.host ?? "page"
          let pagePath = "\(url.path)" + (!(url.query?.isEmpty ?? true) ? "?\(url.query)" : "")
          path.append(NavigationTarget(model: model, url: pagePath))

        } else {
          UIApplication.shared.open(url, options: [:]) { success in
            if success {
              print("Successfully opened link: \(linkString)")
            } else {
              print("Failed to open link: \(linkString)")
            }
          }
        }
        return
      } else {
        print("Invalid URL string: \(linkString)")
      }
    } else {
      actionHandler?(builderAction)
    }
  }

  public func popLast() {
    path.removeLast()
    print("Popped last view from navigation path.")
  }

  /// Pops to the root view of the navigation stack.
  public func popToRoot() {
    path = NavigationPath()
    print("Popped to root of navigation path.")
  }
}

public class BuilderAction {
  let componentId: String
  let linkURL: String?
  let options: JSON?
  let eventActions: JSON?

  public init(componentId: String, options: JSON?, eventActions: JSON?, linkURL: String? = nil) {
    self.componentId = componentId
    self.options = options
    self.eventActions = eventActions
    self.linkURL = linkURL
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

public struct NavigationTarget: Identifiable, Hashable {
  public let id = UUID()  // Unique ID for Identifiable conformance
  let model: String  // The Builder.io model name for the destination page
  let url: String  // The URL path for the destination page

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)  // Ensure ID is part of the hash
    hasher.combine(model)
    hasher.combine(url)
  }

  public static func == (lhs: NavigationTarget, rhs: NavigationTarget) -> Bool {
    // Ensure ID is part of the equality check
    lhs.id == rhs.id && lhs.model == rhs.model && lhs.url == rhs.url
  }
}
