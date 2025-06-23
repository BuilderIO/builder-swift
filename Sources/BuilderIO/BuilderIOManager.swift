import SwiftUI

@MainActor
public final class BuilderIOManager: ObservableObject {

  @Published var builderContent: BuilderContent?
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  var apiKey: String
  static var registered = false

  public init(apiKey: String) {
    self.apiKey = apiKey

    if !BuilderIOManager.registered {
      BuilderComponentRegistry.shared.initialize()
      BuilderIOManager.registered = true
    }
  }

  func fetchBuilderPageContent(url: String) async {
    // 1. Set loading state *immediately*
    isLoading = true
    errorMessage = nil  // Clear any previous error
    builderContent = nil  // Clear previous content while loading new

    do {
      // 2. Await the content fetching
      let content = await BuilderContentAPI.getContent(
        model: "page",
        apiKey: apiKey,
        url: url,
        locale: "",
        preview: ""
      )

      // 3. Update state based on fetched content
      if let fetchedContent = content {
        self.builderContent = fetchedContent
      } else {
        // Handle cases where getContent returns nil but doesn't throw an error
        self.errorMessage = "Failed to load content. Please check the URL or API key."
      }
    } catch {
      // 4. Handle any errors during the async operation
      self.errorMessage = "Error fetching Builder.io content: \(error.localizedDescription)"
    }

    // 5. Always set loading to false when the operation completes (success or failure)
    isLoading = false
  }

  func sendTrackingPixel() {
    if let url = URL(string: "https://cdn.builder.io/api/v1/pixel?apiKey=\(apiKey)") {
      let task = URLSession.shared.dataTask(with: url) { _, _, error in
        if let error = error {
          print("Error sending tracking pixel: \(error.localizedDescription)")
        } else {
          print("Tracking pixel sent.")
        }
      }
      task.resume()
    }
  }

}

@MainActor
public struct BuilderIOPage: View {
    let url: String
    @EnvironmentObject private var builderIOManager: BuilderIOManager
    
    public init(url: String) {
        self.url = url
    }
    
    
    
    public var body: some View {
        Group {
            if builderIOManager.isLoading {
                ProgressView("Loading remote content...")
            } else if let errorMessage = builderIOManager.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else if let builderContent = builderIOManager.builderContent {
                ScrollView {
                    BuilderBlock(blocks: builderContent.data.blocks)
                }
                .onAppear {
                    if !BuilderContentAPI.isPreviewing() {
                        builderIOManager.sendTrackingPixel()
                    }
                }.refreshable {
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
        if !builderIOManager.isLoading {
            print("Calling fetchBuilderPageContent from .task for URL: \(url)")
            await builderIOManager.fetchBuilderPageContent(url: url)
        } else if builderIOManager.isLoading {
            print("Already loading content for URL: \(url). Not re-fetching.")
        }
    }
    
}
