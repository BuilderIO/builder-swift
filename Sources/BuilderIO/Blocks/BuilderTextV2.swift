import SwiftUI
import SwiftyJSON

struct BuilderTextV2: BuilderViewProtocol {
      
    var componentType: BuilderComponentType = .text
    
    var responsiveStyles: [String: String]?
    var text: String?
    
    init(options: JSON?, styles: [String: String]?) {
        self.responsiveStyles = styles
        self.text = options?["text"].string ?? ""
    }
    
    var body: some View {
        Text(CSSStyleUtil.getTextWithoutHtml(text ?? ""))
            .if(!(self.responsiveStyles?.isEmpty ?? true)){ view in
                view.responsiveStylesBuilderView(responsiveStyles: self.responsiveStyles!, isText: true) }
    }
    

}
