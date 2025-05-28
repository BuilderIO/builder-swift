//
//  BuilderComponentProtocol.swift
//  BuilderIO
//
//  Created by Aaron de Melo on 28/05/25.
//

import SwiftUI


public typealias BuilderComponentFactory = (Codable, BuilderBlockResponsiveStyles, [BuilderBlock]?) -> any View;


protocol BuilderViewProtocol: View {
    var responsiveStyles: [String: String]? { get set }
    
}

extension BuilderViewProtocol {

    func buildResponsiveStyles(responsiveStyles: BuilderBlockResponsiveStyles?) -> [String: String] {
        var finalStyle: [String:String] = [:]
        finalStyle = finalStyle.merging(responsiveStyles?.large ?? [:]) { (_, new) in new }
        finalStyle = finalStyle.merging(responsiveStyles?.medium ?? [:]) { (_, new) in new }
        finalStyle = finalStyle.merging(responsiveStyles?.small ?? [:]) { (_, new) in new }
        
        return finalStyle;
    }
    
}

struct ResponsiveStylesBuilderView: ViewModifier {
    var responsiveStyles: [String: String]?
    
    func body(content: Content) -> some View {
        content // or from responsiveStyles
    }
    
    
    
}

extension View where Self: BuilderViewProtocol {
    func responsiveStylesBuilderView() -> some View {
        self.modifier(ResponsiveStylesBuilderView(responsiveStyles: self.responsiveStyles))
    }
}

struct BuilderTextV2: BuilderViewProtocol {
    var componentType: BuilderComponentType = .coreButton
    
    
    var responsiveStyles: [String: String]?
    var text: String?
    
    init(responsiveStyles: BuilderBlockResponsiveStyles?) {
        self.responsiveStyles = buildResponsiveStyles(responsiveStyles: responsiveStyles)
    }
    
    var body: some View {
        Text(text ?? "")
    }
    
    

}



