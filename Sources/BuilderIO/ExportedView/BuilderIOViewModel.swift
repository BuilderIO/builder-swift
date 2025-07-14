import SwiftUI

@MainActor
public final class BuilderIOViewModel: ObservableObject {
  @Published public var builderContent: BuilderContent?
  @Published public var isLoading: Bool = false
  @Published public var errorMessage: String?

  /// Fetches the Builder.io page content for a given URL.
  /// Manages loading, content, and error states.
  public func fetchBuilderContent(model: String = "page", url: String = "") async {
    // Set loading state immediately
    isLoading = true
    errorMessage = nil  // Clear any previous error
    builderContent = nil  // Clear previous content while loading new

    do {
      // Await the content fetching
      let result = await BuilderIOManager.shared.fetchBuilderContent(model: model, url: url)
      switch result {

      case .success(let fetchedContent):
        self.builderContent = fetchedContent
      case .failure(_):
        self.errorMessage = "Failed to load content. Please check the URL or API key."
      }

    } catch {
      // Handle any errors during the async operation
      self.errorMessage = "Error fetching Builder.io content: \(error.localizedDescription)"
    }

    // Always set loading to false when the operation completes (success or failure)
    isLoading = false
  }

  public func sendTrackingPixel() {
    BuilderIOManager.shared.sendTrackingPixel()
  }
}
