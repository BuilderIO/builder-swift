import SwiftUI

struct BuilderButton: BuilderViewProtocol {

  var componentType: BuilderComponentType = .coreButton

  var block: BuilderBlockModel
  var buttonAction: ((String, String?) -> Void)?

  init(block: BuilderBlockModel) {
    self.block = block
  }

  func defaultHandleButtonClick() {

  }

  var body: some View {
    Button(action: {
      print("Styled button tapped")
    }) {
      BuilderText(block: block)
    }
  }
}
