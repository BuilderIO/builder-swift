import SwiftUI

@MainActor
public struct BuilderIOContentView: View {

  let model: String
  let url: String?

  @State private var viewModel: BuilderIOViewModel

  public init(model: String) {
    self.model = model
    self.url = nil
    _viewModel = State(wrappedValue: BuilderIOViewModel())
  }

  init(url: String, model: String = "page") {
    self.url = url
    self.model = model
    _viewModel = State(wrappedValue: BuilderIOViewModel())
  }

  public var body: some View {
    Group {
      if viewModel.isLoading {
        ProgressView("")
      } else if let errorMessage = viewModel.errorMessage {
        Text("Error: \(errorMessage)")
          .foregroundColor(.red)
      } else if let builderContent = viewModel.builderContent {

        let builderBlockView = BuilderBlock(
          blocks: builderContent.data.blocks, builderLayoutDirection: .vertical
        )
        .onAppear {
          if !BuilderContentAPI.isPreviewing() {
            viewModel.sendTrackingPixel()
          }
        }

        // Conditionally apply ScrollView and refreshable
        if url != nil && !url!.isEmpty {
          ScrollView {
            builderBlockView
          }
          .refreshable {
            await loadContent()
          }
        } else {
          VStack(spacing: 0) {
            builderBlockView
          }
        }
      } else {
        Rectangle().background(.clear)

      }
    }.onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
      if isPreviewing() {
        Task {
          await loadContent()
        }
      }
    }.task {
      // This is where you add the task to load content on view appearance
      if viewModel.builderContent == nil && !viewModel.isLoading {
        await loadContent()
      }
    }
  }

  func loadContent() async {
    if !viewModel.isLoading {
      print("Calling fetchBuilderPageContent from .task for section model : \(model)")
      await viewModel.fetchBuilderContent(model: model, url: url ?? "")
    } else if viewModel.isLoading {
      print("Already loading content for section model: \(model). Not re-fetching.")
    }
  }

  func isPreviewing() -> Bool {
    let isAppetize = UserDefaults.standard.bool(forKey: "isAppetize")
    return isAppetize
  }
}
