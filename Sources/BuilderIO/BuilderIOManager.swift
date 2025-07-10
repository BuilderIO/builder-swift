import SwiftUI

public final class BuilderIOManager {

  public static var shared: BuilderIOManager {
    guard let instance = _shared else {
      fatalError(
        "BuilderIOManager has not been configured. Call BuilderIOManager.configure(apiKey:) before accessing shared."
      )
    }
    return instance
  }

  private static var _shared: BuilderIOManager?

  private let apiKey: String
  public let customNavigationScheme: String

  private static var registered = false

  public static func configure(apiKey: String) {
    guard _shared == nil else {
      print(
        "Warning: BuilderIOManager has already been configured. Ignoring subsequent configuration.")
      return
    }
    _shared = BuilderIOManager(apiKey: apiKey)
  }

  // MARK: - Private Initialization

  private init(apiKey: String, customNavigationScheme: String = "builderio") {
    self.apiKey = apiKey
    self.customNavigationScheme = customNavigationScheme

    if !Self.registered {
      BuilderComponentRegistry.shared.initialize()
      Self.registered = true
    }
  }

  // MARK: - Public Methods

  public func getApiKey() -> String {
    return apiKey
  }

  func getCustomNavigationScheme() -> String {
    return customNavigationScheme
  }

  public func fetchBuilderContent(model: String = "page", url: String? = nil) async -> Result<
    BuilderContent, Error
  > {
    do {
      let resolvedUrl = url ?? ""

      if let content = await BuilderContentAPI.getContent(
        model: model,
        apiKey: apiKey,
        url: resolvedUrl,
        locale: "",
        preview: ""
      ) {
        return .success(content)
      } else {
        return .failure(
          NSError(
            domain: "BuilderIOManager",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "No content found for the given URL."]
          )
        )
      }
    } catch {
      return .failure(error)
    }
  }

  public func sendTrackingPixel() {
    guard let url = URL(string: "https://cdn.builder.io/api/v1/pixel?apiKey=\(apiKey)") else {
      return
    }
    URLSession.shared.dataTask(with: url).resume()
  }

  //Register Custom component
  func registerCustomComponentInEditor(_ componentView: any BuilderViewProtocol.Type) {
    let sessionId = UserDefaults.standard.string(forKey: "builderSessionId")
    let sessionToken = UserDefaults.standard.string(forKey: "builderSessionToken")

    if let sessionId = sessionId, let sessionToken = sessionToken {

      let componentDTO = (componentView as! any BuilderCustomComponentViewProtocol.Type)
        .builderCustomComponent

      Task {
        await BuilderContentAPI.registerCustomComponentInEditor(
          component: componentDTO, apiKey: apiKey, sessionId: sessionId,
          sessionToken: sessionToken)
      }
    }
  }
}
