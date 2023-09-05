import Foundation

public struct BuilderInput: Encodable {
    internal init(name: String, friendlyName: String? = nil, description: String? = nil, defaultValue: BuilderInput.DefaultValue? = nil, type: String, required: Bool? = nil, subFields: [BuilderInput]? = nil, helperText: String? = nil, allowedFileTypes: [String]? = nil, imageHeight: Int? = nil, imageWidth: Int? = nil, mediaHeight: Int? = nil, mediaWidth: Int? = nil, hideFromUI: Bool? = nil, modelId: String? = nil, max: Int? = nil, min: Int? = nil, step: Int? = nil, broadcast: Bool? = nil, bubble: Bool? = nil, localized: Bool? = nil, `enum`: [BuilderInput.EnumValue]? = nil, advanced: Bool? = nil, onChange: String? = nil, code: Bool? = nil, richText: Bool? = nil, showIf: String? = nil, copyOnAdd: Bool? = nil, model: String? = nil) {
        self.name = name
        self.friendlyName = friendlyName
        self.description = description
        self.defaultValue = defaultValue
        self.type = type
        self.required = required
        self.subFields = subFields
        self.helperText = helperText
        self.allowedFileTypes = allowedFileTypes
        self.imageHeight = imageHeight
        self.imageWidth = imageWidth
        self.mediaHeight = mediaHeight
        self.mediaWidth = mediaWidth
        self.hideFromUI = hideFromUI
        self.modelId = modelId
        self.max = max
        self.min = min
        self.step = step
        self.broadcast = broadcast
        self.bubble = bubble
        self.localized = localized
        self.`enum` = `enum`
        self.advanced = advanced
        self.onChange = onChange
        self.code = code
        self.richText = richText
        self.showIf = showIf
        self.copyOnAdd = copyOnAdd
        self.model = model
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(friendlyName, forKey: .friendlyName)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(defaultValue, forKey: .defaultValue)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(required, forKey: .required)
        try container.encodeIfPresent(subFields, forKey: .subFields)
        try container.encodeIfPresent(helperText, forKey: .helperText)
        try container.encodeIfPresent(allowedFileTypes, forKey: .allowedFileTypes)
        try container.encodeIfPresent(imageHeight, forKey: .imageHeight)
        try container.encodeIfPresent(imageWidth, forKey: .imageWidth)
        try container.encodeIfPresent(mediaHeight, forKey: .mediaHeight)
        try container.encodeIfPresent(mediaWidth, forKey: .mediaWidth)
        try container.encodeIfPresent(hideFromUI, forKey: .hideFromUI)
        try container.encodeIfPresent(modelId, forKey: .modelId)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(step, forKey: .step)
        try container.encodeIfPresent(broadcast, forKey: .broadcast)
        try container.encodeIfPresent(bubble, forKey: .bubble)
        try container.encodeIfPresent(localized, forKey: .localized)
        try container.encodeIfPresent(`enum`, forKey: .enum)
        try container.encodeIfPresent(advanced, forKey: .advanced)
        try container.encodeIfPresent(onChange, forKey: .onChange)
        try container.encodeIfPresent(code, forKey: .code)
        try container.encodeIfPresent(richText, forKey: .richText)
        try container.encodeIfPresent(showIf, forKey: .showIf)
        try container.encodeIfPresent(copyOnAdd, forKey: .copyOnAdd)
        try container.encodeIfPresent(model, forKey: .model)
    }
    

    enum CodingKeys: String, CodingKey {
        case name
        case friendlyName
        case description
        case defaultValue
        case type
        case required
        case subFields
        case helperText
        case allowedFileTypes
        case imageHeight
        case imageWidth
        case mediaHeight
        case mediaWidth
        case hideFromUI
        case modelId
        case max
        case min
        case step
        case broadcast
        case bubble
        case localized
        case `enum`
        case advanced
        case onChange
        case code
        case richText
        case showIf
        case copyOnAdd
        case model
    }

    var name: String
    var friendlyName: String?
    var description: String?
    var defaultValue: DefaultValue?
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
    var `enum`: [EnumValue]?
    var advanced: Bool?
    var onChange: String?
    var code: Bool?
    var richText: Bool?
    var showIf: String?
    var copyOnAdd: Bool?
    var model: String?
    
    struct EnumValue: Encodable {
        var label: String
        var value: String
        var helperText: String?
    }
    
    enum DefaultValue: Encodable {
        case string(String)
        case int(Int)
        case hash([String: Any])
        case stringArray([String])
        case dictionaryArray([[String: Any]])

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
                try container.encode(value)
            case .int(let value):
                try container.encode(value)
            case .hash(let value):
                // Encode the dictionary manually as JSON data
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                try container.encode(jsonData)
            case .stringArray(let value):
                try container.encode(value)
            case .dictionaryArray(let value):
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                try container.encode(jsonData)
            }
        }
    }

}

public struct BuilderCustomComponent: Encodable {
    internal init(name: String, docsLink: String? = nil, image: String? = nil, screenshot: String? = nil, `override`: Bool? = nil, inputs: [BuilderInput]? = nil, defaultStyles: [String : String]? = nil, noWrap: Bool? = nil, hideFromInsertMenu: Bool? = nil, models: [String]? = nil) {
        self.name = name
        self.docsLink = docsLink
        self.image = image
        self.screenshot = screenshot
        self.`override` = `override`
        self.inputs = inputs
        self.defaultStyles = defaultStyles
        self.noWrap = noWrap
        self.hideFromInsertMenu = hideFromInsertMenu
        self.models = models
    }
    
    var name: String
    var docsLink: String?
    var image: String?
    var screenshot: String?
    var `override`: Bool?
    var inputs: [BuilderInput]?
    var defaultStyles: [String: String]?
    var noWrap: Bool?
    var hideFromInsertMenu: Bool?
    var models: [String]?
}
