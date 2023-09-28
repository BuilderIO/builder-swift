import Foundation
import SwiftUI

private typealias CSS = CSSStyleUtil


@available(iOS 15.0, macOS 10.15, *)
struct BuilderSection: View {
    var responsiveStyles: [String: String]?;
    var children: [BuilderBlock]?;
    
    @available(iOS 15.0, *)
    var body: some View {
        let bgColor = CSS.getColor(value: responsiveStyles?["backgroundColor"]);
        let cornerRadius = CSS.getFloatValue(cssString:responsiveStyles?["borderRadius"] ?? "0px")
        let _ = print("SECTION FOUND WITH STYLES_____", responsiveStyles ?? "NO RESPONSIVE STYLES");
        VStack {
            RenderBlocks(blocks: children!)
        }
        .padding(CSS.getBoxStyle(boxStyleProperty: "padding", finalStyles: responsiveStyles ?? [:]))
        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(bgColor))
        
            
        
        
    }
}
