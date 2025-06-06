import Foundation
import SwiftUI
import SwiftyJSON

//BuilderComponentRegistry single instance factory for building preregistered components
class BuilderComponentRegistry {
    static let shared = BuilderComponentRegistry()

    //Component Registry
    private var registry: [BuilderComponentType: any BuilderViewProtocol.Type] = [:]
    
    // Returns the view for a given block by looking up the component type in the registry.
    // Wrapped in anyview as Swift UI does not support dynamic type instantiation directly
    func view(for block: BuilderBlock) -> AnyView {
        let type = BuilderComponentType(rawValue: block.component?.name ?? "")
        
        guard let viewType = registry[type] else {
            // If the type is not registered, return an empty view
            return AnyView(BuilderEmptyView(block: block))
        }
        
        let view = viewType.init(block: block)
        return AnyView(view)
    }
    
    //Register default components
    func initialize() {
        register(type: .text, viewClass: BuilderText.self)
        register(type: .image, viewClass: BuilderImage.self)
        register(type: .columns, viewClass: BuilderColumns.self)
    }
    
    //Register Custom component
    func register(type: BuilderComponentType, viewClass: any BuilderViewProtocol.Type) {
        registry[type] = viewClass
    }
    
    
}
