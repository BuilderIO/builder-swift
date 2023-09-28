import Foundation
import SwiftUI

private typealias CSS = CSSStyleUtil

struct BuilderColumn: Codable {
    var blocks: [BuilderBlock] = []
}

@available(iOS 15.0, macOS 10.15, *)
struct BuilderColumns: View {
    var columns: [BuilderColumn]
    var space: CGFloat = 0
    var responsiveStyles: [String: String]?;
    
    @available(iOS 15.0, *)
    var body: some View {
        let bgColor = CSS.getColor(value: responsiveStyles?["backgroundColor"]);
        let cornerRadius = CSS.getFloatValue(cssString:responsiveStyles?["borderRadius"] ?? "0px")
        let _ = print("COLUMN FOUND WITH STYLES_____", responsiveStyles ?? "NO RESPONSIVE STYLES");
        Color.clear
            .overlay(
                VStack {
                    ForEach(0...columns.count - 1, id: \.self) { index in
                        let blocks = columns[index].blocks
                        RenderBlocks(blocks: blocks)
                    }
                }
            )
        
        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(bgColor))
        .padding(CSS.getBoxStyle(boxStyleProperty: "padding", finalStyles: responsiveStyles ?? [:]))
            
        
        
    }
}
