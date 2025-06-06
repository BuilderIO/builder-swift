import SwiftUI
import SwiftyJSON

struct BuilderImage: BuilderViewProtocol {
    var componentType: BuilderComponentType = .image

    var block: BuilderBlockModel
    var responsiveStyles: [String: String]?
    var imageURL: URL?
    

    init(block: BuilderBlockModel) {
        self.block = block
        self.responsiveStyles = getFinalStyle(responsiveStyles: block.responsiveStyles)
        self.imageURL = URL(string: block.component?.options?["image"].string ?? "")
    }
    
    var body: some View {
       AsyncImage(url:imageURL).frame(width: 5,height: 5)
        EmptyView()
    }
    

}
