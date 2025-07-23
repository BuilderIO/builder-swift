import Foundation
import SwiftUI

struct BuilderSection: BuilderViewProtocol {

  static let componentType: BuilderComponentType = .section
  var children: [BuilderBlockModel]?
  var block: BuilderBlockModel
  var lazyLoad: Bool = false
  var maxWidth: CGFloat?

  init(block: BuilderBlockModel) {
    self.block = block
    self.children = block.children
    self.lazyLoad = block.component?.options?.dictionaryValue?["lazyLoad"]?.boolValue ?? false
    self.maxWidth =
      block.component?.options?.dictionaryValue?["maxWidth"] != nil
      ? CGFloat(block.component?.options?.dictionaryValue?["maxWidth"]?.doubleValue ?? .infinity)
      : nil
  }

  var body: some View {
    if let children = children {
      VStack(spacing: 0) {
        BuilderBlock(blocks: children)
      }
    } else {
      Rectangle().fill(Color.clear)
    }
  }
}
