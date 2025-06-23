import SwiftUI

@MainActor
public final class BuilderIOPageViewModel: ObservableObject {
  @Published public var builderContent: BuilderContent?
  @Published public var isLoading: Bool = false
  @Published public var errorMessage: String?

  /// Fetches the Builder.io page content for a given URL.
  /// Manages loading, content, and error states.
  public func fetchBuilderPageContent(url: String) async {
    // Set loading state immediately
    isLoading = true
    errorMessage = nil  // Clear any previous error
    builderContent = nil  // Clear previous content while loading new

    do {
      // Await the content fetching
      let result = await BuilderIOManager.shared.fetchBuilderPageContent(url: url)
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
}

@MainActor
public struct BuilderIOPage: View {

  let url: String
  @StateObject private var viewModel = BuilderIOPageViewModel()

  public init(url: String) {
    self.url = url
  }

  public var body: some View {
    Group {
      if viewModel.isLoading {
        ProgressView("Loading remote content...")
      } else if let errorMessage = viewModel.errorMessage {
        Text("Error: \(errorMessage)")
          .foregroundColor(.red)
      } else if let builderContent = viewModel.builderContent {
        ScrollView {
          BuilderBlock(blocks: builderContent.data.blocks)
        }
        .onAppear {
          if !BuilderContentAPI.isPreviewing() {
            BuilderIOManager.shared.sendTrackingPixel()  // Use the tracker instance
          }
        }
        .refreshable {
          await loadPageContent()
        }
      } else {
        Text("No remote content available.")
      }
    }
    .task(id: url) {
      await loadPageContent()
    }
  }

  func loadPageContent() async {
    if !viewModel.isLoading {
      print("Calling fetchBuilderPageContent from .task for URL: \(url)")
      await viewModel.fetchBuilderPageContent(url: url)
    } else if viewModel.isLoading {
      print("Already loading content for URL: \(url). Not re-fetching.")
    }
  }
}
