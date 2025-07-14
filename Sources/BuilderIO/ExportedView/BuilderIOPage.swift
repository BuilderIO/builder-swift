import SwiftUI

@MainActor
public struct BuilderIOPage: View {

  let url: String
  let model: String

  @StateObject private var buttonActionManager = BuilderActionManager()
  var onClickEventHandler: ((BuilderAction) -> Void)? = nil

  @State private var activeNavigationTarget: NavigationTarget? = nil

  public init(
    url: String, model: String = "page", onClickEventHandler: ((BuilderAction) -> Void)? = nil
  ) {
    self.url = url
    self.model = model
    self.onClickEventHandler = onClickEventHandler
  }

  public var body: some View {
    NavigationStack(path: $buttonActionManager.path) {
      BuilderIOContentView(url: url, model: model)
        .navigationDestination(for: NavigationTarget.self) { target in
          BuilderIOContentView(url: target.url, model: target.model)
        }
    }.environmentObject(buttonActionManager).onAppear {
      if let onClickEventHandler = onClickEventHandler {
        buttonActionManager.setHandler(onClickEventHandler)
      }
    }

  }

}
