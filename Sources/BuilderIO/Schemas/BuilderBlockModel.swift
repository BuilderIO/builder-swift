import Foundation  // For Codable, Data, etc.

// Schema for Builder blocks
public struct BuilderBlockModel: Codable, Identifiable {
  public var id: String
  public var properties: [String: String]? = [:]
  public var bindings: [String: String]? = [:]
  public var children: [BuilderBlockModel]? = []
  public var component: BuilderBlockComponent? = nil
  public var responsiveStyles: BuilderBlockResponsiveStyles? = BuilderBlockResponsiveStyles()  // for inner style of the component
  public var actions: AnyCodable? = nil
  public var code: AnyCodable? = nil
  public var meta: AnyCodable? = nil
  public var linkUrl: String? = nil
  public var `repeat`: [String: String]? = [:]

  public var stateBoundObjectModel: AnyCodable? = nil
}

extension BuilderBlockModel {
  /// Recursively sets the `stateBoundObjectModel` for this block and all its children.
  public mutating func propagateStateBoundObjectModel(_ model: AnyCodable) {
    self.stateBoundObjectModel = model

    if var children = self.children {
      for index in children.indices {
        children[index].propagateStateBoundObjectModel(model)
      }
      self.children = children
    }
  }

  public func codeBindings(for key: String) -> AnyCodable? {
    guard let code = code,
      let codeConfig = code.dictionaryValue,
      let bindingsConfig = codeConfig["bindings"],
      let bindings = bindingsConfig.dictionaryValue,
      let stateDict = stateBoundObjectModel?.dictionaryValue
    else {
      return nil
    }

    for (bindingKey, value) in bindings {
      let lastComponent = bindingKey.split(separator: ".").last.map(String.init)
      if key == lastComponent {
        if let lookupKey = value.stringValue {

          return stateDict[lookupKey.split(separator: ".").last.map(String.init) ?? ""]
        }
      }
    }

    return nil
  }

}

public struct BuilderBlockComponent: Codable {
  public var name: String
  public var options: AnyCodable? = nil  // Replaced JSON? with AnyCodable?, default to nil
}

public struct BuilderBlockResponsiveStyles: Codable {
  var large: [String: String]? = [:]
  var medium: [String: String]? = [:]
  var small: [String: String]? = [:]
}
