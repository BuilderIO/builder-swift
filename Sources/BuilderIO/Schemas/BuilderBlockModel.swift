import SwiftyJSON

// Schema for Builder blocks
public struct BuilderBlockModel: Codable, Identifiable {
  public var id: String
  var properties: [String: String]? = [:]
  var bindings: [String: String]? = [:]
  var children: [BuilderBlockModel]? = []
  var component: BuilderBlockComponent? = nil
  var responsiveStyles: BuilderBlockResponsiveStyles? = BuilderBlockResponsiveStyles()  // for inner style of the component
  var actions: JSON? = [:]
  var code: JSON? = [:]
  var meta: JSON? = [:]
  var linkUrl: String? = nil
}

public struct BuilderBlockComponent: Codable {
  var name: String
  var options: JSON? = [:]
}

public struct BuilderBlockResponsiveStyles: Codable {
  var large: [String: String]? = [:]
  var medium: [String: String]? = [:]
  var small: [String: String]? = [:]
}
