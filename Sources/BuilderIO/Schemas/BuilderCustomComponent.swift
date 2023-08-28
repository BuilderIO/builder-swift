public struct BuilderInput {
    var name: String
    var friendlyName: String?
    var description: String?
    var defaultValue: Any?
    var type: String
    var required: Bool?
    var subFields: [BuilderInput]?
    var helperText: String?
    var allowedFileTypes: [String]?
    var imageHeight: Int?
    var imageWidth: Int?
    var mediaHeight: Int?
    var mediaWidth: Int?
    var hideFromUI: Bool?
    var modelId: String?
    var max: Int?
    var min: Int?
    var step: Int?
    var broadcast: Bool?
    var bubble: Bool?
    var localized: Bool?
    var options: [String: Any]?
    var `enum`: [EnumValue]?
    var advanced: Bool?
    var onChange: String?
    var code: Bool?
    var richText: Bool?
    var showIf: String?
    var copyOnAdd: Bool?
    var model: String?
}

public struct EnumValue {
    var label: String
    var value: Any
    var helperText: String?
}

public struct BuilderCustomComponent {
    public var name: String
    public var docsLink: String?
    public var image: String?
    public var screenshot: String?
    public var `override`: Bool?
    public var inputs: [BuilderInput]?
    public var `class`: Any?
    public var defaultStyles: [String: String]?
    public var noWrap: Bool?
    public var hideFromInsertMenu: Bool?
    public var models: [String]?
}
