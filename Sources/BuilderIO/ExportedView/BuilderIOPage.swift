import SwiftUI

@MainActor
public struct BuilderIOPage: View {

  let url: String
  let model: String
  @Binding var locale: String

  @StateObject private var buttonActionManager = BuilderActionManager()
  var onClickEventHandler: ((BuilderAction) -> Void)? = nil

  @State private var activeNavigationTarget: NavigationTarget? = nil

  public init(
    url: String, model: String = "page", locale: String = "Default",
    onClickEventHandler: ((BuilderAction) -> Void)? = nil
  ) {
    self.init(
      url: url, model: model, locale: .constant(locale), onClickEventHandler: onClickEventHandler)
  }

  public init(
    url: String, model: String = "page", locale: Binding<String>,
    onClickEventHandler: ((BuilderAction) -> Void)? = nil
  ) {
    self.url = url
    self.model = model
    self.onClickEventHandler = onClickEventHandler
    self._locale = locale
  }

  public var body: some View {
    NavigationStack(path: $buttonActionManager.path) {
      BuilderIOContentView(url: url, model: model, locale: $locale)
        .navigationDestination(for: NavigationTarget.self) { target in
          BuilderIOContentView(url: target.url, model: target.model, locale: $locale)
        }
    }.environmentObject(buttonActionManager).onAppear {
      if let onClickEventHandler = onClickEventHandler {
        buttonActionManager.setHandler(onClickEventHandler)
      }
    }

  }

}
