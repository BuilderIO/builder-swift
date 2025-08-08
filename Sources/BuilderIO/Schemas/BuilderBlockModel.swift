import Foundation

// MARK: - Core Data Models

/// Represents a single Builder.io block, conforming to Codable and Identifiable.
public struct BuilderBlockModel: Codable, Identifiable {
  public var id: String
  public var properties: [String: String]?
  public var bindings: [String: String]?
  public var children: [BuilderBlockModel]?
  public var component: BuilderBlockComponent?
  public var responsiveStyles: BuilderBlockResponsiveStyles
  public var actions: AnyCodable?
  public var code: AnyCodable?
  public var meta: AnyCodable?
  public var linkUrl: String?
  public var `repeat`: [String: String]?
  public var locale: String?

  // Internal state properties
  var stateBoundObjectModel: StateModel?
  var stateRepeatCollectionKey: StateRepeatCollectionKey?

  public init(
    id: String = UUID().uuidString,
    properties: [String: String]? = nil,
    bindings: [String: String]? = nil,
    children: [BuilderBlockModel]? = nil,
    component: BuilderBlockComponent? = nil,
    responsiveStyles: BuilderBlockResponsiveStyles = .init(),
    actions: AnyCodable? = nil,
    code: AnyCodable? = nil,
    meta: AnyCodable? = nil,
    linkUrl: String? = nil,
    `repeat`: [String: String]? = nil,
    locale: String? = nil
  ) {
    self.id = id
    self.properties = properties
    self.bindings = bindings
    self.children = children
    self.component = component
    self.responsiveStyles = responsiveStyles
    self.actions = actions
    self.code = code
    self.meta = meta
    self.linkUrl = linkUrl
    self.repeat = `repeat`
    self.locale = locale
  }
}

/// Represents component-specific data for a block.
public struct BuilderBlockComponent: Codable {
  public var name: String
  public var options: AnyCodable?
}

/// Defines responsive style properties for a block.
public struct BuilderBlockResponsiveStyles: Codable {
  public var large: [String: String]?
  public var medium: [String: String]?
  public var small: [String: String]?

  public init(
    large: [String: String]? = nil,
    medium: [String: String]? = nil,
    small: [String: String]? = nil
  ) {
    self.large = large
    self.medium = medium
    self.small = small
  }
}

/// Stores information for repeating a block based on a collection.
public struct StateRepeatCollectionKey: Codable {
  public var index: Int
  public var collection: String
}

// MARK: - Extension for Logic

extension BuilderBlockModel {
  /// Recursively propagates state and applies bindings to this block and its children.
  public mutating func propagateStateBoundObjectModel(
    _ model: StateModel?, stateRepeatCollectionKey: StateRepeatCollectionKey? = nil
  ) {
    self.stateBoundObjectModel = model
    self.stateRepeatCollectionKey = stateRepeatCollectionKey

    applyCodeBindings()
    propagateStateToChildren(model, stateRepeatCollectionKey: stateRepeatCollectionKey)
  }

  /// Sets the locale for the current block and all its children recursively.
  public mutating func setLocaleRecursively(_ newLocale: String) {
    self.locale = newLocale
    self.id = UUID().uuidString  // Reset ID for uniqueness after a locale change

    guard var children = children else { return }
    for index in children.indices {
      children[index].setLocaleRecursively(newLocale)
    }
    self.children = children
  }
}

// MARK: - Private Helpers

extension BuilderBlockModel {
  /// Applies code bindings to component options like 'text' and 'image'.
  fileprivate mutating func applyCodeBindings() {
    var options = component?.options?.dictionaryValue
    var styling = responsiveStyles.small ?? [:]

    if var options = options {
      if let bindingText = evaluateCodeBinding(for: "text") {
        options["text"] = bindingText
      }

      if let bindingImage = evaluateCodeBinding(for: "image") {
        options["image"] = bindingImage
      }

      if let bindingVideo = evaluateCodeBinding(for: "video") {
        options["video"] = bindingVideo
      }

      self.component?.options = AnyCodable.dictionary(options)
    }

    if let bindingColor = evaluateCodeBinding(for: "color") {
      styling["color"] = bindingColor.stringValue
    }

    if let backgroundColor = evaluateCodeBinding(for: "backgroundColor") {
      styling["backgroundColor"] = backgroundColor.stringValue
    }

    if let borderColor = evaluateCodeBinding(for: "borderColor") {
      styling["borderColor"] = borderColor.stringValue
    }

    self.responsiveStyles.small = styling

  }

  /// Recursively propagates the state model to child blocks.
  fileprivate mutating func propagateStateToChildren(
    _ model: StateModel?, stateRepeatCollectionKey: StateRepeatCollectionKey?
  ) {
    guard var children = children else { return }
    for index in children.indices {
      children[index].propagateStateBoundObjectModel(
        model, stateRepeatCollectionKey: stateRepeatCollectionKey)
    }
    self.children = children
  }

  /// Evaluates a single code binding for a given key.
  fileprivate func evaluateCodeBinding(for key: String) -> AnyCodable? {
    guard let bindings = getBindings() else { return nil }

    if let stateRepeatCollectionKey = stateRepeatCollectionKey,
      let stateModel = stateBoundObjectModel
    {
      return resolveBindingInRepeatCollection(
        key: key, bindings: bindings, stateModel: stateModel,
        stateRepeatCollectionKey: stateRepeatCollectionKey)
    } else if let stateModel = stateBoundObjectModel {
      return resolveBindingInStandardState(key: key, bindings: bindings, stateModel: stateModel)
    }

    return nil
  }

  /// Extracts the bindings dictionary from the code property.
  fileprivate func getBindings() -> [String: AnyCodable]? {
    return code?.dictionaryValue?["bindings"]?.dictionaryValue
  }

  /// Resolves a binding within a repeated collection.
  fileprivate func resolveBindingInRepeatCollection(
    key: String, bindings: [String: AnyCodable], stateModel: StateModel,
    stateRepeatCollectionKey: StateRepeatCollectionKey
  ) -> AnyCodable? {
    guard
      let collection = stateModel.getCollectionFromStateData(
        keyString: stateRepeatCollectionKey.collection),
      stateRepeatCollectionKey.index < collection.count,
      let model = collection[stateRepeatCollectionKey.index].dictionaryValue
    else {
      return nil
    }

    for (bindingKey, value) in bindings {
      if bindingKey.split(separator: ".").last.map(String.init) == key,
        let lookupKey = value.stringValue,
        let finalKey = lookupKey.split(separator: ".").last.map(String.init)
      {
        return model[finalKey]
      }
    }
    return nil
  }

  /// Resolves a binding from the standard state model.
  fileprivate func resolveBindingInStandardState(
    key: String, bindings: [String: AnyCodable], stateModel: StateModel
  ) -> AnyCodable? {
    for (bindingKey, value) in bindings {
      if bindingKey.split(separator: ".").last.map(String.init) == key,
        let keyString = value.stringValue
      {
        return stateModel.getValueFromStateData(keyString: keyString)
      }
    }
    return nil
  }
}
