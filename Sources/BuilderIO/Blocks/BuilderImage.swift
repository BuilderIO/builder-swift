import SwiftUI
private typealias CSS = CSSStyleUtil

@available(iOS 15.0, macOS 10.15, *)
struct BuilderImage: View {
    var image: String
    var backgroundSize: String;
    var aspectRatio: CGFloat;
    var responsiveStyles: [String: String]?;

    
    var body: some View {
        let currentScale = UIScreen.main.scale;
        let foregroundColor = CSS.getColor(value: responsiveStyles?["color"] ?? "black");
        let bgColor = CSS.getColor(value: responsiveStyles?["backgroundColor"] ?? "white");
        let cornerRadius = CSS.getFloatValue(cssString:responsiveStyles?["borderRadius"] ?? "0px")
        let horizontalAlignmentFrame = CSS.getFrameFromHorizontalAlignment(styles: responsiveStyles ?? [:]);
        let maxWidth = CSS.getFloatValue(cssString: responsiveStyles?["maxWidth"], defaultValue: .infinity) ;

        BackportAsyncImage(url: URL(string: image)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(1/aspectRatio, contentMode: backgroundSize == "cover" ? .fill : .fit)
                    .frame(width: maxWidth)
            } else if phase.error != nil {
                Color.red
            } else {
                Color.blue
            }
        }
        .padding(CSS.getBoxStyle(boxStyleProperty: "padding", finalStyles: responsiveStyles ?? [:])) // padding for the button
        .frame(idealWidth: horizontalAlignmentFrame.idealWidth, maxWidth: horizontalAlignmentFrame.maxWidth, alignment: horizontalAlignmentFrame.alignment)
        .foregroundColor(foregroundColor)
        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(bgColor))
    }
}
