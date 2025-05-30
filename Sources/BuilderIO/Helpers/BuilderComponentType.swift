struct BuilderComponentType: Equatable, Hashable {
    let rawValue: String

    static let text = BuilderComponentType(rawValue: "Text")
    static let image = BuilderComponentType(rawValue: "Image")
    static let coreButton = BuilderComponentType(rawValue: "Core:Button")
    static let columns = BuilderComponentType(rawValue: "Columns")

    // Add new types dynamically
    static func custom(_ name: String) -> BuilderComponentType {
        return BuilderComponentType(rawValue: name)
    }
}
