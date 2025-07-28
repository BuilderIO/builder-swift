import SwiftUI
import UIKit  // Required for UIImage and URLSession

enum ImageStatus {
  case loading
  case loaded(UIImage)
  case error
}

@Observable
class BuilderImageLoader {

  // MARK: - Static Cache Properties
  // Static a single, shared cache across all uses of BuilderImageLoader.
  private static let imageCache = NSCache<NSString, CachedImageEntry>()
  private static let cacheDuration: TimeInterval = 5 * 60  // Cache duration in seconds (5 minutes)

  public var imageStatus: ImageStatus = .loading

  private class CachedImageEntry {
    let image: UIImage
    let timestamp: Date

    init(image: UIImage, timestamp: Date) {
      self.image = image
      self.timestamp = timestamp
    }

    /// Checks if the cached image is still valid based on the cache duration.
    func isValid(for duration: TimeInterval) -> Bool {
      return Date().timeIntervalSince(timestamp) < duration
    }
  }

  func loadImage(from url: URL?) async {
    guard let url = url else {
      print("BuilderImageLoader: Invalid URL provided.")
      imageStatus = .error
      return
    }

    let cacheKey = url.absoluteString as NSString

    // 1. Check if the image is in the static cache and is still valid
    if let cachedEntry = BuilderImageLoader.imageCache.object(forKey: cacheKey),
      cachedEntry.isValid(for: BuilderImageLoader.cacheDuration)
    {
      print("BuilderImageLoader: Image loaded from static cache for URL: \(url)")
      imageStatus = .loaded(cachedEntry.image)
      return
    }

    // 2. If not in cache or expired, download the image
    print("BuilderImageLoader: Downloading image for URL: \(url)")
    do {
      let (data, response) = try await URLSession.shared.data(from: url)

      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode)
      else {
        print("BuilderImageLoader: Server error or invalid response for URL: \(url)")
        imageStatus = .error
        return
      }

      guard let image = UIImage(data: data) else {
        print("BuilderImageLoader: Could not create image from data for URL: \(url)")
        imageStatus = .error
        return
      }

      // 3. Cache the newly downloaded image in the static cache
      let newCacheEntry = CachedImageEntry(image: image, timestamp: Date())
      BuilderImageLoader.imageCache.setObject(newCacheEntry, forKey: cacheKey)
      print("BuilderImageLoader: Image downloaded and cached in static cache for URL: \(url)")

      imageStatus = .loaded(image)

    } catch {
      print(
        "BuilderImageLoader: Failed to download image from URL: \(url), Error: \(error.localizedDescription)"
      )
      imageStatus = .error
    }
  }
}
