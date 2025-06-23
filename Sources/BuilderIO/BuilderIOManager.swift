import SwiftUI

@MainActor
public final class BuilderIOManager: ObservableObject {
  public static private(set) var shared: BuilderIOManager!

  public let apiKey: String
  private static var registered = false

  private init(apiKey: String) {
    self.apiKey = apiKey
    if !Self.registered {
      BuilderComponentRegistry.shared.initialize()
      Self.registered = true
    }
  }

  /// Call once during app launch
  public static func configure(apiKey: String) {
    guard shared == nil else {
      return
    }
    shared = BuilderIOManager(apiKey: apiKey)
  }

  public func fetchBuilderPageContent(url: String) async -> Result<BuilderContent, Error> {
    do {
      if let content = await BuilderContentAPI.getContent(
        model: "page",
        apiKey: apiKey,
        url: url,
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
          ))
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
}
