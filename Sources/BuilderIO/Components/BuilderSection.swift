import Foundation
import SwiftUI
import SwiftyJSON

struct BuilderSection: BuilderViewProtocol {
    
    var componentType: BuilderComponentType = .section

    var block: BuilderBlock
    var columns: [BuilderContentData]
    var space: CGFloat = 0
    var responsiveStyles: [String: String]?;
    
    init(block: BuilderBlock) {
        self.block = block
        let decoder = JSONDecoder()
        let jsonString = block.component!.options!["columns"].rawString()!
        let columns = try! decoder.decode([BuilderContentData].self, from: Data(jsonString.utf8))
        self.columns = columns
        self.responsiveStyles = getFinalStyle(responsiveStyles: block.responsiveStyles)
        self.space = block.component!.options?["space"].doubleValue ?? 0;
    }
    
    var body: some View {
        let hasBgColor = responsiveStyles?["backgroundColor"] != nil;
        let bgColor = CSSStyleUtil.getColor(value: responsiveStyles?["backgroundColor"]);

        VStack(spacing: space) {
        
            ForEach(0...columns.count - 1, id: \.self) { index in
                BuilderBox(blocks: columns[index].blocks)
            }
           
        }
        .padding(CSSStyleUtil.getBoxStyle(boxStyleProperty: "padding", finalStyles: responsiveStyles ?? [:]))
        .if(hasBgColor) { view in
            view.background(bgColor)
        }.padding(CSSStyleUtil.getBoxStyle(boxStyleProperty: "margin", finalStyles: responsiveStyles ?? [:]))
        
    }
}
