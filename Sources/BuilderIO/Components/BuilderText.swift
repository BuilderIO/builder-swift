import SwiftUI
import SwiftyJSON

struct BuilderText: BuilderViewProtocol {
    var block: BuilderBlock
    
    var componentType: BuilderComponentType = .text
    
    var responsiveStyles: [String: String]?
    var text: String?
    
    init(block: BuilderBlock) {
        self.block = block
        self.text = block.component?.options?["text"].string ?? ""
        self.responsiveStyles = getFinalStyle(responsiveStyles: block.responsiveStyles)
    }
    
    var body: some View {
        Text(CSSStyleUtil.getTextWithoutHtml(text ?? ""))
            .if(!(self.responsiveStyles?.isEmpty ?? true)){ view in
                view.responsiveStylesBuilderView(responsiveStyles: self.responsiveStyles!, isText: true) }
    }
    

}
