import SwiftUI

//Wrapped Text Click event handle externally at the layout level
struct BuilderButton: BuilderViewProtocol {

  var componentType: BuilderComponentType = .coreButton

  var block: BuilderBlockModel

  init(block: BuilderBlockModel) {
    self.block = block
  }

  var body: some View {
    BuilderText(block: block)
  }
}
