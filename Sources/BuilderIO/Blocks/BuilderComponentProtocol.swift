//
//  BuilderComponentProtocol.swift
//  BuilderIO
//
//  Created by Aaron de Melo on 28/05/25.
//

import SwiftUI
import SwiftyJSON


protocol BuilderViewProtocol: View {
    var responsiveStyles: [String: String]? { get set }
    init(options: JSON, styles: [String: String]?);
    
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




//--------------view modifier to apply responsive styles-------------------


struct ResponsiveStylesBuilderView: ViewModifier {
  
    var responsiveStyles: [String: String]
    let horizontalAlignmentFrame: FrameDimensions;
    let foregroundColor: Color?
    let cornerRadius: CGFloat?
    let fontSize: CGFloat?
    let fontWeight: Font.Weight?
    
    
    init(responsiveStyles: [String: String], isText: Bool) {
        self.responsiveStyles = responsiveStyles
        
        foregroundColor = responsiveStyles["color"].map { CSSStyleUtil.getColor(value: $0) }
        cornerRadius = responsiveStyles["borderRadius"].map { CSSStyleUtil.getFloatValue(cssString: $0) }
        fontSize = responsiveStyles["fontSize"].map { CSSStyleUtil.getFloatValue(cssString: $0) }
        fontWeight = responsiveStyles["fontWeight"].map { fontWeight in CSSStyleUtil.getFontWeightFromNumber(value: CSSStyleUtil.getFloatValue(cssString: fontWeight)) }
        
        horizontalAlignmentFrame = CSSStyleUtil.getFrameFromHorizontalAlignment(styles: responsiveStyles ?? [:], isText: true);
    }

    
    
    
    func body(content: Content) -> some View {
        content
            .frame(idealWidth: horizontalAlignmentFrame.idealWidth, maxWidth: horizontalAlignmentFrame.maxWidth, alignment: horizontalAlignmentFrame.alignment)
            .if(fontSize != nil){ view in
                view.font(.system(size: fontSize!).weight(fontWeight!))
            }
            .if(foregroundColor != nil){ view in
                view.foregroundColor(foregroundColor)
            }
            
    }
    
    
    
    
}

extension View {
    func responsiveStylesBuilderView(responsiveStyles: [String: String], isText: Bool = false) -> some View {
        self.modifier(ResponsiveStylesBuilderView(responsiveStyles: responsiveStyles, isText: isText))
    }
}

//--------------Core Button------------------- sample component

struct BuilderTextV2: BuilderViewProtocol {
  
    
    var componentType: BuilderComponentType = .coreButton
    
    
    var responsiveStyles: [String: String]?
    var text: String?
    

    init(options: JSON, styles: [String: String]?) {
        self.responsiveStyles = styles
        self.text = options["text"].string ?? ""
    }
    
    var body: some View {
        Text(CSSStyleUtil.getTextWithoutHtml(text ?? ""))
            .if(!(self.responsiveStyles?.isEmpty ?? true)){ view in
                view.responsiveStylesBuilderView(responsiveStyles: self.responsiveStyles!, isText: true) }
    }
    
    

}





