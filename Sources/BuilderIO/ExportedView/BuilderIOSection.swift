import SwiftUI

@MainActor
public struct BuilderIOSection: View {

  let model: String

  @StateObject private var viewModel: BuilderIOViewModel

  public init(apiKey: String, model: String) {
    self.model = model
    _viewModel = StateObject(wrappedValue: BuilderIOViewModel())
  }

  public var body: some View {
    Group {
      if viewModel.isLoading {
        ProgressView("Loading remote content...")
      } else if let errorMessage = viewModel.errorMessage {
        Text("Error: \(errorMessage)")
          .foregroundColor(.red)
      } else if let builderContent = viewModel.builderContent {
        VStack(spacing: 0) {
          BuilderBlock(blocks: builderContent.data.blocks)
            .onAppear {
              if !BuilderContentAPI.isPreviewing() {
                viewModel.sendTrackingPixel()  // Use the tracker instance
              }
            }
        }
      } else {
        Text("No remote content available.")
      }
    }
    .task(id: model) {
      await loadSectionContent()
    }
  }

  func loadSectionContent() async {
    if !viewModel.isLoading {
      print("Calling fetchBuilderPageContent from .task for section model : \(model)")
      await viewModel.fetchBuilderContent(model: model)
    } else if viewModel.isLoading {
      print("Already loading content for section model: \(model). Not re-fetching.")
    }
  }
}
