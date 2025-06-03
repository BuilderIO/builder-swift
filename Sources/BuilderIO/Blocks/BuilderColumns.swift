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
        let hasBgColor = responsiveStyles?["backgroundColor"] != nil;
        let bgColor = CSS.getColor(value: responsiveStyles?["backgroundColor"]);

        VStack {
            ForEach(0...columns.count - 1, id: \.self) { index in
                let blocks = columns[index].blocks
                RenderBlocks(blocks: blocks)
            }
        }
        .padding(CSS.getBoxStyle(boxStyleProperty: "padding", finalStyles: responsiveStyles ?? [:]))
        .if(hasBgColor) { view in
            view.background(bgColor)
        }
        
        .padding(CSS.getBoxStyle(boxStyleProperty: "margin", finalStyles: responsiveStyles ?? [:]))
        
        
            
        
        
    }
}
