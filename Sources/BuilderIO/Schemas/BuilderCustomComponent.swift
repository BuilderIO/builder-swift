public struct BuilderInput {
    public init(name: String, friendlyName: String? = nil, description: String? = nil, defaultValue: Any? = nil, type: String, required: Bool? = nil, subFields: [BuilderInput]? = nil, helperText: String? = nil, allowedFileTypes: [String]? = nil, imageHeight: Int? = nil, imageWidth: Int? = nil, mediaHeight: Int? = nil, mediaWidth: Int? = nil, hideFromUI: Bool? = nil, modelId: String? = nil, max: Int? = nil, min: Int? = nil, step: Int? = nil, broadcast: Bool? = nil, bubble: Bool? = nil, localized: Bool? = nil, options: [String : Any]? = nil, `enum`: [EnumValue]? = nil, advanced: Bool? = nil, onChange: String? = nil, code: Bool? = nil, richText: Bool? = nil, showIf: String? = nil, copyOnAdd: Bool? = nil, model: String? = nil) {
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
        self.options = options
        self.`enum` = `enum`
        self.advanced = advanced
        self.onChange = onChange
        self.code = code
        self.richText = richText
        self.showIf = showIf
        self.copyOnAdd = copyOnAdd
        self.model = model
    }
    
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
    public init(label: String, value: Any, helperText: String? = nil) {
        self.label = label
        self.value = value
        self.helperText = helperText
    }

    var label: String
    var value: Any
    var helperText: String?
}

public struct BuilderCustomComponent {
    public init(name: String, docsLink: String? = nil, image: String? = nil, screenshot: String? = nil, `override`: Bool? = nil, inputs: [BuilderInput]? = nil, `class`: Any? = nil, defaultStyles: [String : String]? = nil, noWrap: Bool? = nil, hideFromInsertMenu: Bool? = nil, models: [String]? = nil) {
        self.name = name
        self.docsLink = docsLink
        self.image = image
        self.screenshot = screenshot
        self.`override` = `override`
        self.inputs = inputs
        self.`class` = `class`
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
    var `class`: Any?
    var defaultStyles: [String: String]?
    var noWrap: Bool?
    var hideFromInsertMenu: Bool?
    var models: [String]?
}
