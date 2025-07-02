import SwiftUI

public final class BuilderIOManager {

  private let apiKey: String
  private static var registered = false

  init(apiKey: String) {
    self.apiKey = apiKey
    if !Self.registered {
      BuilderComponentRegistry.shared.initialize()
      Self.registered = true
    }
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
}
