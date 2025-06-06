import SwiftUI
import SwiftyJSON

struct BuilderImage: BuilderViewProtocol {
    var componentType: BuilderComponentType = .image

    var block: BuilderBlock
    var responsiveStyles: [String: String]?
    var imageURL: URL?
    

    init(block: BuilderBlock) {
        self.block = block
        self.responsiveStyles = getFinalStyle(responsiveStyles: block.responsiveStyles)
        self.imageURL = URL(string: block.component?.options?["image"].string ?? "")
    }
    
    var body: some View {
        AsyncImage(url:imageURL).frame(width: 50,height: 50)
        EmptyView()
    }
    

}
