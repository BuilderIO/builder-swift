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

  public var stateBoundObjectModel: StateModel? = nil
  public var stateRepeatCollectionKey: StateRepeatCollectionKey? = nil

  public var locale: String? = nil  // Optional locale for the block

}

public struct StateRepeatCollectionKey: Codable {
  public var index: Int
  public var collection: String

}

extension BuilderBlockModel {
  /// Recursively sets the `stateBoundObjectModel` for this block and all its children.
  public mutating func propagateStateBoundObjectModel(
    _ model: StateModel?, stateRepeatCollectionKey: StateRepeatCollectionKey? = nil
  ) {
    self.stateBoundObjectModel = model
    self.stateRepeatCollectionKey = stateRepeatCollectionKey

    if var children = self.children {
      for index in children.indices {
        children[index].propagateStateBoundObjectModel(
          model, stateRepeatCollectionKey: stateRepeatCollectionKey)
      }
      self.children = children
    }
  }

  public func codeBindings(for key: String) -> AnyCodable? {
    guard let code = code,
      let codeConfig = code.dictionaryValue,
      let bindingsConfig = codeConfig["bindings"],
      let bindings = bindingsConfig.dictionaryValue
    else {
      return nil
    }

    if let stateModel = stateBoundObjectModel {

      //binding is in a list
      if let stateRepeatCollectionKey = stateRepeatCollectionKey {
        let collection = stateModel.getCollectionFromStateData(
          keyString: stateRepeatCollectionKey.collection)

        let model = collection?[stateRepeatCollectionKey.index].dictionaryValue

        for (bindingKey, value) in bindings {
          let lastComponent = bindingKey.split(separator: ".").last.map(String.init)
          if key == lastComponent {
            if let lookupKey = value.stringValue {

              return model?[lookupKey.split(separator: ".").last.map(String.init) ?? ""]
            }

          }
        }
      } else {

        for (bindingKey, value) in bindings {
          let lastComponent = bindingKey.split(separator: ".").last.map(String.init)
          if key == lastComponent {
            return stateModel.getValueFromStateData(
              keyString: value.stringValue ?? "")
          }

        }
      }

    }

    return nil
  }

  public mutating func setLocaleRecursively(_ newLocale: String) {
    self.locale = newLocale
    self.id = UUID().uuidString  // Reset ID to ensure uniqueness after locale change
    if let children = self.children {
      var newChildren = children
      for i in 0..<newChildren.count {
        newChildren[i].setLocaleRecursively(newLocale)
      }
      self.children = newChildren
    }
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
