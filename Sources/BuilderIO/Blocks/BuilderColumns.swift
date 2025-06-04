import Foundation
import SwiftUI
import SwiftyJSON

private typealias CSS = CSSStyleUtil


struct BuilderColumns: BuilderViewProtocol {
    
    
    var columns: [BuilderContentData]
    var space: CGFloat = 0
    var responsiveStyles: [String: String]?;
    
    init(options: JSON?, styles: [String : String]?) {
        let decoder = JSONDecoder()
        let jsonString = options!["columns"].rawString()!
        let columns = try! decoder.decode([BuilderContentData].self, from: Data(jsonString.utf8))
        self.columns = columns
        self.responsiveStyles = styles
        self.space = options?["space"].doubleValue ?? 0;
    }
    
    @available(iOS 15.0, *)
    var body: some View {
        let hasBgColor = responsiveStyles?["backgroundColor"] != nil;
        let bgColor = CSS.getColor(value: responsiveStyles?["backgroundColor"]);

        VStack(spacing: space) {
        
            ForEach(0...columns.count - 1, id: \.self) { index in
                BuilderBox(children: columns[index].blocks, styles: nil)
            }
           
        }
        .padding(CSS.getBoxStyle(boxStyleProperty: "padding", finalStyles: responsiveStyles ?? [:]))
        .if(hasBgColor) { view in
            view.background(bgColor)
        }
        
        .padding(CSS.getBoxStyle(boxStyleProperty: "margin", finalStyles: responsiveStyles ?? [:]))
        
        
            
        
        
    }
}
