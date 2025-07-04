import SwiftUI

public protocol BuilderViewProtocol: View {
  var componentType: BuilderComponentType { get }
  var block: BuilderBlockModel { get }
  init(block: BuilderBlockModel)
}

extension BuilderViewProtocol {
  func getFinalStyle(responsiveStyles: BuilderBlockResponsiveStyles?) -> [String: String] {
    return CSSStyleUtil.getFinalStyle(responsiveStyles: responsiveStyles)
  }
}

struct BuilderEmptyView: BuilderViewProtocol {
  var block: BuilderBlockModel

  var componentType: BuilderComponentType = .empty

  init(block: BuilderBlockModel) {
    self.block = block
  }

  var body: some View {
    EmptyView()
  }
}
