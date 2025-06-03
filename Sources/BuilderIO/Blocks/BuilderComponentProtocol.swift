import SwiftUI
import SwiftyJSON


protocol BuilderViewProtocol: View {
    var responsiveStyles: [String: String]? { get set }
    init(options: JSON?, styles: [String: String]?);
    
}

struct BuilderEmptyView: BuilderViewProtocol {
    
    var responsiveStyles: [String: String]?

    init(options: JSON?, styles: [String: String]?) {
        self.responsiveStyles = styles
    }

    var body: some View {
        EmptyView()
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

//Make the view modifier available to all Views
extension View {
    func responsiveStylesBuilderView(responsiveStyles: [String: String], isText: Bool = false) -> some View {
        self.modifier(ResponsiveStylesBuilderView(responsiveStyles: responsiveStyles, isText: isText))
    }
}



