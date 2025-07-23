import Foundation  // For Codable, Data, etc.

// Schema for Builder blocks
public struct BuilderBlockModel: Codable, Identifiable {
  public var id: String
  public var properties: [String: String]? = [:]
  public var bindings: [String: String]? = [:]
  public var children: [BuilderBlockModel]? = []
  public var component: BuilderBlockComponent? = nil
  public var responsiveStyles: BuilderBlockResponsiveStyles? = BuilderBlockResponsiveStyles()  // for inner style of the component
  public var actions: AnyCodable? = nil  // Replaced JSON? with AnyCodable?, default to nil
  public var code: AnyCodable? = nil  // Replaced JSON? with AnyCodable?, default to nil
  public var meta: AnyCodable? = nil  // Replaced JSON? with AnyCodable?, default to nil
  public var linkUrl: String? = nil

  // Important: Initialize optionals correctly.
  // If these fields are truly optional and might be missing from JSON,
  // they should be nil by default, not empty dictionaries,
  // unless an empty dictionary is the desired default for a missing field.
  // I've changed them to 'nil' for AnyCodable, as that's a more natural default
  // for a potentially missing arbitrary JSON value.
  // If the JSON for 'actions' for example is '{ "actions": {} }', it will decode
  // as .dictionary([:])
  // If the JSON for 'actions' is '{ "actions": null }' or '{ }' (missing), it will decode as nil.
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
