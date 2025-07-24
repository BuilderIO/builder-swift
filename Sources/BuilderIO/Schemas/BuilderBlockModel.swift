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

public struct BuilderBlockComponent: Codable {
  public var name: String
  public var options: AnyCodable? = nil  // Replaced JSON? with AnyCodable?, default to nil
}

public struct BuilderBlockResponsiveStyles: Codable {
  var large: [String: String]? = [:]
  var medium: [String: String]? = [:]
  var small: [String: String]? = [:]
}
