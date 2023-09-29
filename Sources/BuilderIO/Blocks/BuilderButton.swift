import SwiftUI
import WebKit
private typealias CSS = CSSStyleUtil

@available(iOS 15.0, macOS 10.15, *)
struct BuilderButton: View {
    var text: String
    var urlStr: String?
    var openInNewTab: Bool = false
    var responsiveStyles: [String: String]?;

    @State private var showWebView = false
    
    
    var body: some View {
        let foregroundColor = CSS.getColor(value: responsiveStyles?["color"]);
        let bgColor = CSS.getColor(value: responsiveStyles?["backgroundColor"]);
        // let _ = print("BG COLOR BUTTON ----", bgColor);
        let cornerRadius = CSS.getFloatValue(cssString:responsiveStyles?["borderRadius"] ?? "0px")
        let fontSize = CSS.getFloatValue(cssString: responsiveStyles?["fontSize"] ?? "16px")
        let fontWeight = CSS.getFontWeightFromNumber(value: CSS.getFloatValue(cssString: responsiveStyles?["fontWeight"] ?? "400"))
        let horizontalAlignmentFrame = CSS.getFrameFromHorizontalAlignment(styles: responsiveStyles ?? [:]);
        Button(action: {
            print(CSS.getTextWithoutHtml(text))
            // print("responsiveStyles = \(String(describing: responsiveStyles))")
            if let str = urlStr, let url = URL(string: str) {
                self.showWebView = !openInNewTab
                if openInNewTab == true {
                    UIApplication.shared.open(url)
                }
            }
        }) {
            Text(CSS.getTextWithoutHtml(text))
                .padding(CSS.getBoxStyle(boxStyleProperty: "padding", finalStyles: responsiveStyles ?? [:])) // padding for the button
                .font(.system(size: fontSize).weight(fontWeight))
                .frame(alignment: horizontalAlignmentFrame.alignment)
                
        }
        .frame(idealWidth: horizontalAlignmentFrame.idealWidth, maxWidth: horizontalAlignmentFrame.maxWidth, alignment: horizontalAlignmentFrame.alignment)
        .foregroundColor(foregroundColor)
        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(bgColor))
            
        
        .sheet(isPresented: $showWebView) {
            if let str = urlStr, let url = URL(string: str) {
                WebView(url: url)
            }
        }
//            .frame(maxWidth: .infinity)
    
//        .frame(maxWidth: .infinity)
    }
}


@available(iOS 15.0, *)
struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
