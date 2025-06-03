import SwiftUI

@available(iOS 15.0, macOS 10.15, *)
public struct RenderContent: View {
    static var registered = false;
    var content: BuilderContent;
    var apiKey: String;

    public init(content: BuilderContent, apiKey: String, clickActionHandler: ((String, String?) -> Void)? = nil) {
        self.content = content
        self.apiKey = apiKey
        
        if (!RenderContent.registered) {
            BuilderComponentRegistry.shared.initialize()
            RenderContent.registered = true
        }
        
    }
    
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BuilderBox(children: content.data.blocks, styles: nil)
                .onAppear{
                    if (!BuilderContentAPI.isPreviewing()) {
                        sendTrackingPixel()
                    }
                }
        }
        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
        .background(Color.white)
    }

    func sendTrackingPixel() {
        if let url = URL(string: "https://cdn.builder.io/api/v1/pixel?apiKey=\(self.apiKey)") {
            let task = URLSession.shared.dataTask(with: url)
            task.resume()
        }
    }
}
