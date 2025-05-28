//
//  BuilderComponentRegistry.swift
//  BuilderIO
//
//  Created by Aaron de Melo on 28/05/25.
//

import Foundation
import SwiftUI
import SwiftyJSON



class BuilderComponentRegistry {
    static let shared = BuilderComponentRegistry()
    
    private var registry: [BuilderComponentType: any BuilderViewProtocol] = [:]
    
    func register(type: BuilderComponentType, viewType: any BuilderViewProtocol) {
        registry[type] = factory
    }
    
    func create(type: String, data: ComponentData) -> UIComponent? {
        return registry[type]?(data)
    }
}
