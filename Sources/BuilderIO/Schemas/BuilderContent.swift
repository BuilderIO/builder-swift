import Foundation  // For UUID and Codable

public struct BuilderContent: Codable {  // Add Equatable
  public var data: BuilderContentData
  public var screenshot: String? = nil
  public var ownerId: String? = nil

  // Equatable conformance (synthesized if all properties are Equatable)
}

public struct BuilderContentData: Codable, Identifiable {  // Add Identifiable and Equatable
  // CRITICAL: Stable ID for ForEach loops. Generate a UUID once.
  public var id: UUID = UUID()  // Use UUID for Identifiable conformance

  public var blocks: [BuilderBlockModel] = []  // Ensure BuilderBlockModel conforms to Equatable

  public var width: Double? = nil  // Optional width for the content block

  // Custom init(from decoder:) - required because of 'id'
  public init(from decoder: Decoder) throws {
    self.id = UUID()  // Generate a UUID when decoded
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.blocks = try container.decodeIfPresent([BuilderBlockModel].self, forKey: .blocks) ?? []
    self.width = try container.decodeIfPresent(Double.self, forKey: .width) ?? nil
  }

  // Custom init for manual creation
  public init(blocks: [BuilderBlockModel], width: Double? = nil) {
    self.id = UUID()
    self.blocks = blocks
    self.width = width
  }

  enum CodingKeys: String, CodingKey {
    case blocks
    case width
  }

  // Equatable conformance (synthesized if all properties are Equatable)
}

public struct BuilderContentList: Codable {  // Add Equatable
  public var results: [BuilderContent] = []  // Ensure BuilderContent conforms to Equatable

  // Equatable conformance (synthesized if all properties are Equatable)
}
