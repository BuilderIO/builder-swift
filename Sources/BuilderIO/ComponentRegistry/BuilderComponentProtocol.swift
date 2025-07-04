import SwiftUI

public protocol BuilderViewProtocol: View {
  static var componentType: BuilderComponentType { get }
  var block: BuilderBlockModel { get }
  init(block: BuilderBlockModel)
}

public protocol BuilderCustomComponentViewProtocol: BuilderViewProtocol {
  static var builderCustomComponent: BuilderCustomComponent { get }
}

extension BuilderViewProtocol {
  func getFinalStyle(responsiveStyles: BuilderBlockResponsiveStyles?) -> [String: String] {
    return CSSStyleUtil.getFinalStyle(responsiveStyles: responsiveStyles)
  }
}

struct BuilderEmptyView: BuilderViewProtocol {
  static let componentType: BuilderComponentType = .empty

  var block: BuilderBlockModel

  init(block: BuilderBlockModel) {
    self.block = block
  }

  var body: some View {
    EmptyView()
  }
}
