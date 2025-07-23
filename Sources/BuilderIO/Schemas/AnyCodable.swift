import Foundation

// --- AnyCodable Type Definition ---
// This enum allows you to represent any valid JSON value and make it Codable.
public enum AnyCodable: Codable {
  case int(Int)
  case double(Double)
  case string(String)
  case bool(Bool)
  case array([AnyCodable])  // Can contain other AnyCodable values
  case dictionary([String: AnyCodable])  // Can contain other AnyCodable values
  case null

  // MARK: - Decodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let value = try? container.decode(Int.self) {
      self = .int(value)
    } else if let value = try? container.decode(Double.self) {
      self = .double(value)
    } else if let value = try? container.decode(String.self) {
      self = .string(value)
    } else if let value = try? container.decode(Bool.self) {
      self = .bool(value)
    } else if let value = try? container.decode([AnyCodable].self) {
      self = .array(value)
    } else if let value = try? container.decode([String: AnyCodable].self) {
      self = .dictionary(value)
    } else if container.decodeNil() {
      self = .null
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "AnyCodable: Unknown type or malformed JSON value.")
      )
    }
  }

  // MARK: - Encodable
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .int(let value):
      try container.encode(value)
    case .double(let value):
      try container.encode(value)
    case .string(let value):
      try container.encode(value)
    case .bool(let value):
      try container.encode(value)
    case .array(let value):
      try container.encode(value)
    case .dictionary(let value):
      try container.encode(value)
    case .null:
      try container.encodeNil()
    }
  }

  // MARK: - Convenience for accessing values (optional but highly recommended)
  // Add these so you can easily access specific types without a full switch
  public var intValue: Int? {
    if case .int(let val) = self { return val }
    if case .string(let str) = self, let val = Int(str) { return val }
    return nil
  }

  public var doubleValue: Double? {
    if case .double(let val) = self { return val }
    if case .int(let val) = self { return Double(val) }
    if case .string(let str) = self, let val = Double(str) { return val }
    return nil
  }

  public var stringValue: String? {
    if case .string(let val) = self { return val }
    if case .int(let val) = self { return String(val) }
    if case .double(let val) = self { return String(val) }
    if case .bool(let val) = self { return String(val) }
    return nil
  }

  public var boolValue: Bool? {
    if case .bool(let val) = self { return val }
    if case .int(let val) = self { return val != 0 }  // 0 = false, non-zero = true
    if case .string(let str) = self { return Bool(str) }  // "true", "false"
    return nil
  }

  public var arrayValue: [AnyCodable]? {
    if case .array(let val) = self { return val }
    return nil
  }

  public var dictionaryValue: [String: AnyCodable]? {
    if case .dictionary(let val) = self { return val }
    return nil
  }
}
