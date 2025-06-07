// Schema for Builder content
public struct BuilderContent: Codable {
  var data = BuilderContentData()
  var screenshot: String? = nil
  var ownerId: String? = nil
}

struct BuilderContentData: Codable {
  var blocks: [BuilderBlockModel] = []
}

struct BuilderContentList: Codable {
  var results: [BuilderContent] = []
}
