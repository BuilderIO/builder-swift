import SwiftUI

@MainActor
public struct BuilderIOPage: View {

  let url: String
  let model: String

  @StateObject private var viewModel: BuilderIOViewModel

  @EnvironmentObject var buttonActionManager: BuilderActionManager

  @State private var activeNavigationTarget: NavigationTarget? = nil

  public init(apiKey: String, url: String, model: String = "page") {
    self.url = url
    self.model = model
    _viewModel = StateObject(wrappedValue: BuilderIOViewModel(apiKey: apiKey))
  }

  public var body: some View {
    NavigationStack(path: $buttonActionManager.path) {
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
              viewModel.sendTrackingPixel()
            }
          }
          .refreshable {
            await loadPageContent()
          }
          //When running in Appetize.io, shake event will reload the content
          .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
            if isPreviewing() {
              Task {
                await loadPageContent()
              }
            }
          }
        } else {
          Text("No remote content available.")
        }
      }
      .task(id: url) {
        await loadPageContent()
      }
      .navigationDestination(for: NavigationTarget.self) { target in
        // Create a new BuilderIOPage with the model and URL from the navigation target
        BuilderIOPage(apiKey: viewModel.getApiKey(), url: target.url, model: target.model)
          // Pass the existing button action manager down to the new page's environment
          // using .environmentObject to ensure it's available to nested views.
          .environmentObject(buttonActionManager)
      }
    }
  }

  func loadPageContent() async {
    if !viewModel.isLoading {
      print("Calling fetchBuilderPageContent from .task for URL: \(url)")
      await viewModel.fetchBuilderContent(model: model, url: url)
    } else if viewModel.isLoading {
      print("Already loading content for URL: \(url). Not re-fetching.")
    }

    //$activeNavigationTarget.wrappedValue = nil
    // buttonActionManager?.navigationTarget = nil

  }

  func isPreviewing() -> Bool {
    let isAppetize = UserDefaults.standard.bool(forKey: "isAppetize")
    return isAppetize
  }

}
