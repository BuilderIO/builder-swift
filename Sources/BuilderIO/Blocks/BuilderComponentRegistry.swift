import Foundation
import SwiftUI
import SwiftyJSON


class BuilderComponentRegistry {
    static let shared = BuilderComponentRegistry()

    
    private var registry: [BuilderComponentType: any BuilderViewProtocol.Type] = [:]
    
    func register(type: BuilderComponentType, viewClass: any BuilderViewProtocol.Type) {
        registry[type] = viewClass
    }
    
    func view(for component: BuilderBlockComponent, responsiveStyles: [String: String]) -> AnyView {
        let type = BuilderComponentType(rawValue: component.name)
        
        
        guard let viewType = registry[type] else {
            return AnyView(BuilderEmptyView(options: [:], styles: nil))
        }

        
        let view = viewType.init(options: component.options ?? [:], styles: responsiveStyles)
        return AnyView(view)
    }
    
    
    func initialize() {
        register(type: .text, viewClass: BuilderText.self)
        register(type: .image, viewClass: BuilderImage.self)
        register(type: .column, viewClass: BuilderColumns.self)
    }
    
}
