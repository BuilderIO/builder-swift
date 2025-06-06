import Foundation
import SwiftUI
import SwiftyJSON


class BuilderComponentRegistry {
    static let shared = BuilderComponentRegistry()

    //Component Registry
    private var registry: [BuilderComponentType: any BuilderViewProtocol.Type] = [:]
    
    
    func view(for block: BuilderBlock) -> AnyView {
        let type = BuilderComponentType(rawValue: block.component?.name ?? "")
        
        
        guard let viewType = registry[type] else {
            return AnyView(BuilderEmptyView(block: block))
        }

        
        let view = viewType.init(block: block)
        return AnyView(view)
    }
    
    
    func initialize() {
        register(type: .text, viewClass: BuilderText.self)
        register(type: .image, viewClass: BuilderImage.self)
        register(type: .column, viewClass: BuilderColumns.self)
    }
    
    //Register Custom component
    func register(type: BuilderComponentType, viewClass: any BuilderViewProtocol.Type) {
        registry[type] = viewClass
    }
    
    
}
