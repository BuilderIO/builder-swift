import SwiftUI
import WebKit

private typealias CSS = CSSStyleUtil

@available(iOS 15.0, macOS 10.15, *)
struct BuilderText: View {
    var text: String
    var responsiveStyles: [String: String]?;

    
    var body: some View {
        
        let foregroundColor = CSS.getColor(value: responsiveStyles?["color"] ?? "black");
        
//        let bgColor = Color.green; // CSS.getColor(value: responsiveStyles?["backgroundColor"] ?? "rgba(0,0,0,0)");
        let cornerRadius = CSS.getFloatValue(cssString:responsiveStyles?["borderRadius"] ?? "0px")
        let fontSize = CSS.getFloatValue(cssString: responsiveStyles?["fontSize"] ?? "16px")
        let fontWeight = CSS.getFontWeightFromNumber(value: CSS.getFloatValue(cssString: responsiveStyles?["fontWeight"] ?? "400"))
        
        let horizontalAlignmentFrame = CSS.getFrameFromHorizontalAlignment(styles: responsiveStyles ?? [:]);
//        let roundedRectangle = RoundedRectangle(cornerRadius: cornerRadius);
//        if ((responsiveStyles?["backgroundColor"]) != nil) {
//            roundedRectangle.fill(Color.green)
//        } else {
//            roundedRectangle.fill(Color.yellow)
//        }
        let _ = print("BUILDER TEXT", text, responsiveStyles ?? "No Styles", horizontalAlignmentFrame);
        Text(CSS.getTextWithoutHtml(text))
//            .padding(CSS.getBoxStyle(boxStyleProperty: "padding", finalStyles: responsiveStyles ?? [:])) // padding for the text
            .frame(idealWidth: horizontalAlignmentFrame.idealWidth, maxWidth: horizontalAlignmentFrame.maxWidth, alignment: horizontalAlignmentFrame.alignment)
            .font(.system(size: fontSize).weight(fontWeight))
            .foregroundColor(foregroundColor)
            .background(Color.green)
//            .padding(CSS.getBoxStyle(boxStyleProperty: "margin", finalStyles: responsiveStyles ?? [:])) // margin for the text
    }
}


/**
 Can be used, but restrictive. Can render HTML strings, but styling the wrapper is hard. Keep as a backup for now.
 */
@available(iOS 13.0, *)
struct TextCustom: UIViewRepresentable {
  let html: String
  func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
    DispatchQueue.main.async {
      let data = Data(self.html.utf8)
      if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
        uiView.isEditable = false
        uiView.attributedText = attributedString
      }
    }
  }
  func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
    let label = UITextView()
    return label
  }
}
