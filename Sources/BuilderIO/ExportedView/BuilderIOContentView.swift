import SwiftUI

@MainActor
public struct BuilderIOContentView: View {

  let model: String
  let url: String?

  @State private var viewModel: BuilderIOViewModel
  @Binding var locale: String

  public init(model: String, locale: String = "Default") {
    self.init(model: model, locale: .constant(locale))
  }

  public init(model: String, locale: Binding<String>) {
    self.model = model
    self.url = nil
    self._locale = locale
    _viewModel = State(wrappedValue: BuilderIOViewModel())
  }

  public init(url: String, model: String = "page", locale: String = "Default") {
    self.init(url: url, model: model, locale: .constant(locale))
  }

  init(url: String, model: String = "page", locale: Binding<String>) {
    self.url = url
    self.model = model
    self._locale = locale
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
    }.onChange(of: locale) {
      Task {
        await loadContent()
      }
    }
  }

  func loadContent() async {
    if !viewModel.isLoading {
      print("Calling fetchBuilderPageContent from .task for section model : \(model)")
      await viewModel.fetchBuilderContent(
        model: model, url: url ?? "", locale: _locale.wrappedValue)
    } else if viewModel.isLoading {
      print("Already loading content for section model: \(model). Not re-fetching.")
    }
  }

  func isPreviewing() -> Bool {
    let isAppetize = UserDefaults.standard.bool(forKey: "isAppetize")
    return isAppetize
  }
}
