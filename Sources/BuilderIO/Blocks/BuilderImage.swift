import SwiftUI
private typealias CSS = CSSStyleUtil

@available(iOS 15.0, macOS 10.15, *)
struct BuilderImage: View {
    var image: String
    var backgroundSize: String;
    var aspectRatio: CGFloat;
    var responsiveStyles: [String: String]?;
    var children: [BuilderBlock]?;

    
    var body: some View {
        let _ = UIScreen.main.scale;
        let foregroundColor = CSS.getColor(value: responsiveStyles?["color"] ?? "black");
        let bgColor = CSS.getColor(value: responsiveStyles?["backgroundColor"] ?? "white");
        let cornerRadius = CSS.getFloatValue(cssString:responsiveStyles?["borderRadius"] ?? "0px")
        let horizontalAlignmentFrame = CSS.getFrameFromHorizontalAlignment(styles: responsiveStyles ?? [:], isText: false);
        let maxWidth = CSS.getFloatValue(cssString: responsiveStyles?["maxWidth"], defaultValue: .infinity) ;
//        let _ = print("BACKGROUND SIZE ----", backgroundSize, " CONTENT MODE ", backgroundSize == "cover" ? ContentMode.fill : ContentMode.fit);
//        let _ = print("ASPECT RATIO", aspectRatio, 1/aspectRatio)
//        let _ = print("Max Width?", maxWidth == .infinity ? nil : maxWidth);

        BackportAsyncImage(url: URL(string: image)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(1/aspectRatio, contentMode: backgroundSize == "cover" ? .fill : .fit)
                    .frame(width: maxWidth == .infinity ? nil : maxWidth)

            } else if phase.error != nil {
                Color.red
            } else {
                Color.blue
            }
        }
        .frame(idealWidth: horizontalAlignmentFrame.idealWidth, maxWidth: horizontalAlignmentFrame.maxWidth, alignment: horizontalAlignmentFrame.alignment)
        .foregroundColor(foregroundColor)
        .overlay(content: {
            if (children != nil) {
                RenderBlocks(blocks: children!)
            }
        })
        .cornerRadius(cornerRadius)
    }
}
