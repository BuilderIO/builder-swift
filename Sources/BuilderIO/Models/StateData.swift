import Foundation

public class StateModel: Codable {
  public var apiResponses: [String: AnyCodable] = [:]

  func findCollection(keys: [String], currentData: [String: AnyCodable]) -> [AnyCodable]? {

    if keys.count == 1 {
      return currentData[keys[0]]?.arrayValue
    }

    let nextLevelObject = currentData[keys[0]]?.dictionaryValue

    var nextKeys = Array(keys.dropFirst())

    if let nextLevelObject = nextLevelObject {
      return findCollection(keys: nextKeys, currentData: nextLevelObject)
    }

    return nil

  }

  func getCollectionFromStateData(keyString: String) -> [AnyCodable]? {

    var keys = Array(
      keyString.replacingOccurrences(of: "@", with: "").components(separatedBy: ".").dropFirst())

    return findCollection(keys: keys, currentData: apiResponses)

  }

  func findValue(keys: [String], currentData: [String: AnyCodable]) -> AnyCodable? {

    if keys.count == 1 {
      return currentData[keys[0]]
    }

    let nextLevelObject = currentData[keys[0]]?.dictionaryValue

    var nextKeys = Array(keys.dropFirst())

    if let nextLevelObject = nextLevelObject {
      return findValue(keys: nextKeys, currentData: nextLevelObject)
    }

    return nil

  }

  func getValueFromStateData(keyString: String) -> AnyCodable? {

    var keys = Array(
      keyString.replacingOccurrences(of: "@", with: "").components(separatedBy: ".").dropFirst())

    return findValue(keys: keys, currentData: apiResponses)

  }

}
