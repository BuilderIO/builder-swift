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

  func codeBindings() -> [String: String]? {
    return nil
  }

  func localize(localizedValue: AnyCodable) -> String? {

    if let localeDictionary = localizedValue.dictionaryValue {
      if let currentLocale = BuilderIOManager.shared.locale {
        if let localizedString = localeDictionary[currentLocale]?.stringValue {
          return localizedString
        }
      }

      return localeDictionary["Default"]?.stringValue

    } else {
      return localizedValue.stringValue
    }
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
