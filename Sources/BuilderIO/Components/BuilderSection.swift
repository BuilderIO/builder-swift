import Foundation
import SwiftUI
import SwiftyJSON

struct BuilderSection: BuilderViewProtocol {

  static let componentType: BuilderComponentType = .section
  var children: [BuilderBlockModel]?
  var block: BuilderBlockModel
  var lazyLoad: Bool = false
  var maxWidth: CGFloat?

  init(block: BuilderBlockModel) {
    self.block = block
    self.children = block.children
    self.lazyLoad = block.component?.options?["lazyLoad"].bool ?? false
    self.maxWidth =
      block.component?.options?["maxWidth"] != nil
      ? CGFloat(block.component?.options?["maxWidth"].float ?? .infinity) : nil
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
