import SwiftUI

@available(iOS 15.0, macOS 10.15, *)
public struct RenderContent: View {
    static var registered = false;
    var content: BuilderContent;
    var apiKey: String;

    public init(content: BuilderContent, apiKey: String) {
        self.content = content
        self.apiKey = apiKey
        if (!RenderContent.registered) {
            // TODO: move these out of here?
            registerComponent(component: BuilderCustomComponent(name: "Text", inputs: [
                BuilderInput(name: "text", type: "text")
            ]), factory: { (options, styles, _) in
                return BuilderText(text: options["text"].stringValue, responsiveStyles: styles)
            }, apiKey: nil)
            registerComponent(component: BuilderCustomComponent(name: "Image"), factory: { (options, styles, children) in
                return BuilderImage(image: options["image"].stringValue, backgroundSize: options["backgroundSize"].stringValue, aspectRatio: CSSStyleUtil.getFloatValue(cssString: options["aspectRatio"].stringValue),  responsiveStyles: styles, children: children)
            }, apiKey: nil)
            registerComponent(component: BuilderCustomComponent(name: "Core:Button"), factory: { (options, styles, _) in
                return BuilderButton(text: options["text"].stringValue, urlStr: options["link"].stringValue, openInNewTab: options["openLinkInNewTab"].boolValue, responsiveStyles: styles)
            }, apiKey: nil)
            registerComponent(component: BuilderCustomComponent(name: "Columns"), factory: { (options, styles, _) in
                let decoder = JSONDecoder()
                let jsonString = options["columns"].rawString()!
                let columns = try! decoder.decode([BuilderColumn].self, from: Data(jsonString.utf8))
                return BuilderColumns(columns: columns, space: CGFloat(options["space"].floatValue), responsiveStyles: styles)
            }, apiKey: nil)
            RenderContent.registered = true
        }
        
    }
    
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RenderBlocks(blocks: content.data.blocks)
                .onAppear{
                    if (!Content.isPreviewing()) {
                        sendTrackingPixel()
                    }
                }
        }.background(Color.white)
    }

    func sendTrackingPixel() {
        if let url = URL(string: "https://cdn.builder.io/api/v1/pixel?apiKey=\(self.apiKey)") {
            let task = URLSession.shared.dataTask(with: url)
            task.resume()
        }
    }
}
