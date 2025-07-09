import SwiftyJSON

// Schema for Builder blocks
public struct BuilderBlockModel: Codable, Identifiable {
  public var id: String
  public var properties: [String: String]? = [:]
  public var bindings: [String: String]? = [:]
  public var children: [BuilderBlockModel]? = []
  public var component: BuilderBlockComponent? = nil
  public var responsiveStyles: BuilderBlockResponsiveStyles? = BuilderBlockResponsiveStyles()  // for inner style of the component
  public var actions: JSON? = [:]
  public var code: JSON? = [:]
  public var meta: JSON? = [:]
  public var linkUrl: String? = nil
}

public struct BuilderBlockComponent: Codable {
  public var name: String
  public var options: JSON? = [:]
}

public struct BuilderBlockResponsiveStyles: Codable {
  var large: [String: String]? = [:]
  var medium: [String: String]? = [:]
  var small: [String: String]? = [:]
}
