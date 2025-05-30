import Foundation
import SwiftUI
import SwiftyJSON



class BuilderComponentRegistry {
    static let shared = BuilderComponentRegistry()
    
    private var registry: [BuilderComponentType: any BuilderViewProtocol.Type] = [:]
    
    func register(type: BuilderComponentType, viewClass: any BuilderViewProtocol.Type) {
        registry[type] = viewClass
    }
    
}
