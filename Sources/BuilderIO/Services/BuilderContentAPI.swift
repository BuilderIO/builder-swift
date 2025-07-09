import Foundation
import os

public struct BuilderContentAPI {

  public static func isPreviewing() -> Bool {
    let isAppetize = UserDefaults.standard.bool(forKey: "isAppetize")
    return isAppetize
  }

  public static func getContent(
    model: String,
    apiKey: String,
    url: String? = nil,
    locale: String? = nil,
    preview: String? = nil
  ) async -> BuilderContent? {

    var str = "https://cdn.builder.io/api/v3/content/\(model)"

    let overrideLocale = UserDefaults.standard.string(forKey: "builderLocale")
    let overridePreviewContent = UserDefaults.standard.string(forKey: "builderContentId")

    let useLocale = overrideLocale ?? locale
    let usePreview = overridePreviewContent ?? preview

    // Append content ID if it's a specific preview ID
    if let localPreview = usePreview, !localPreview.isEmpty {
      str += "/\(localPreview)"
    }

    str += "?apiKey=\(apiKey)"

    if let url = url, !url.isEmpty {
      guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
      else {
        return nil
      }
      str += "&url=\(encodedUrl)"
    }

    if let locale = useLocale, !locale.isEmpty {
      str += "&locale=\(locale)"
    }

    if let localPreview = usePreview, !localPreview.isEmpty {
      str += "&preview=true"
      str += "&cachebust=true"  // Consider if this is strictly needed or can be dynamic
      // Using a timestamp instead of random float for better debuggability and consistency
      str += "&cachebuster=\(Date().timeIntervalSince1970)"
    }

    guard let finalURL = URL(string: str) else {
      return nil
    }

    let session =
      !(usePreview ?? "").isEmpty
      ? URLSession(configuration: .ephemeral)  // For preview, ephemeral is good
      : URLSession.shared  // For live content, shared is fine (can utilize cache)

    os_log(
      "BuilderContentAPI: Fetching URL = %{public}@", log: .default, type: .info,
      finalURL.absoluteString)

    do {
      let (data, response) = try await session.data(from: finalURL)

      // Basic HTTP status code check
      if let httpResponse = response as? HTTPURLResponse,
        !(200..<300).contains(httpResponse.statusCode)
      {
        let errorData = String(data: data, encoding: .utf8) ?? "No error data"
        os_log(
          "BuilderContentAPI: HTTP Error %{public}d: %{public}@",
          log: .default, type: .error, httpResponse.statusCode, errorData)
        return nil
      }

      let decoder = JSONDecoder()

      if let localPreview = usePreview, !localPreview.isEmpty {
        os_log(
          "BuilderContentAPI: Decoding single content for preview.", log: .default, type: .debug)
        let content = try decoder.decode(BuilderContent.self, from: data)
        return content
      } else {
        os_log(
          "BuilderContentAPI: Decoding content list for live content.", log: .default, type: .debug)
        let contentList = try decoder.decode(BuilderContentList.self, from: data)
        if let firstContent = contentList.results.first {
          return firstContent
        } else {
          os_log(
            "BuilderContentAPI: Content list results were empty for %{public}@", log: .default,
            type: .info, url ?? "")
          return nil
        }
      }
    } catch {
      os_log(
        "BuilderContentAPI: Decoding error for %{public}@: %{public}@",
        log: .default, type: .error, url ?? "", error.localizedDescription)
      return nil
    }
  }

  static func registerCustomComponentInEditor(
    component: BuilderCustomComponent, apiKey: String, sessionId: String, sessionToken: String
  ) async -> Bool {
    let overrideUrl = UserDefaults.standard.string(forKey: "builderRemoteUrl")
    let urlString = overrideUrl ?? "https://cdn.builder.io/api/v1/remote-sessions/\(sessionId)"

    guard var components = URLComponents(string: urlString) else {
      print("Error: Bad URL components.")
      return false  // Indicate failure due to bad URL
    }

    components.queryItems = [
      URLQueryItem(name: "apiKey", value: apiKey),
      URLQueryItem(name: "sessionToken", value: sessionToken),
    ]

    guard let url = components.url else {
      print("Error: Could not form URL.")
      return false  // Indicate failure due to bad URL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
      let jsonData = try JSONEncoder().encode(component)
      request.httpBody = jsonData
    } catch {
      print("Error serializing JSON data: \(error)")
      return false  // Indicate failure due to JSON serialization error
    }

    do {
      let (data, response) = try await URLSession.shared.data(for: request)

      if let httpResponse = response as? HTTPURLResponse {
        if !(200...299).contains(httpResponse.statusCode) {
          print(
            "Server error with status code: \(httpResponse.statusCode). Response: \(String(data: data, encoding: .utf8) ?? "N/A")"
          )
          return false  // Indicate failure due to non-success status code
        }
      }

      print("Successfully registered component. Response data size: \(data.count) bytes")
      return true  // Indicate success
    } catch {
      print("Network or unexpected error during registration: \(error)")
      return false  // Indicate failure for any other network/URLSession error
    }
  }

}
