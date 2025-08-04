import SwiftUI

@MainActor
public struct BuilderIOPage: View {

  let url: String
  let model: String
  @State private var locale: String

  @StateObject private var buttonActionManager = BuilderActionManager()
  var onClickEventHandler: ((BuilderAction) -> Void)? = nil

  @State private var activeNavigationTarget: NavigationTarget? = nil

  public init(
    url: String, model: String = "page", locale: String = "Default",
    onClickEventHandler: ((BuilderAction) -> Void)? = nil
  ) {
    self.url = url
    self.model = model
    self.onClickEventHandler = onClickEventHandler
    self._locale = State(initialValue: locale)
  }

  public func updateLocale(locale: String) {

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
