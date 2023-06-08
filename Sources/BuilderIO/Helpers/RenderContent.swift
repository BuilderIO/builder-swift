import SwiftUI

@available(iOS 15.0, macOS 10.15, *)
public struct RenderContent: View {
    static var registered = false;
    
    public init(content: BuilderContent) {
        self.content = content
        if (!RenderContent.registered) {
            // TODO: move these out of here?
            registerComponent(name: "Text", factory: { (options, styles) in
                return BuilderText(text: options["text"].stringValue, responsiveStyles: styles)
            })
            registerComponent(name: "Image", factory: { (options, styles) in
                return BuilderImage(image: options["image"].stringValue, backgroundSize: options["backgroundSize"].stringValue, aspectRatio: CSSStyleUtil.getFloatValue(cssString: options["aspectRatio"].stringValue),  responsiveStyles: styles)
            })
            registerComponent(name: "Core:Button", factory: { (options, styles) in
                return BuilderButton(text: options["text"].stringValue, urlStr: options["link"].stringValue, openInNewTab: options["openLinkInNewTab"].boolValue, responsiveStyles: styles)
            })
            registerComponent(name: "Columns", factory: { (options, styles) in
                let decoder = JSONDecoder()
                let jsonString = options["columns"].rawString()!
                let columns = try! decoder.decode([BuilderColumn].self, from: Data(jsonString.utf8))
                return BuilderColumns(columns: columns, space: CGFloat(options["space"].floatValue))
            })
            RenderContent.registered = true
        }
        
    }
    
    var content: BuilderContent
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RenderBlocks(blocks: content.data.blocks)
        }
    }
}
