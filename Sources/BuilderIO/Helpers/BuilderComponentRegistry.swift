import Foundation
import SwiftUI
import SwiftyJSON


//component registry, TODO: factory for compoenents
class BuilderComponentRegistry {
    static let shared = BuilderComponentRegistry()
    
    private var registry: [BuilderComponentType: any BuilderViewProtocol.Type] = [:]
    
    func register(type: BuilderComponentType, viewClass: any BuilderViewProtocol.Type) {
        registry[type] = viewClass
    }
    
}
