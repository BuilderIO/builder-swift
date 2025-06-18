import SwiftUI
import SwiftyJSON

struct BuilderImage: BuilderViewProtocol {
  var componentType: BuilderComponentType = .image

  var block: BuilderBlockModel
  var responsiveStyles: [String: String]?
  var aspectRatio: CGSize?

  var imageURL: URL?

  init(block: BuilderBlockModel) {
    self.block = block
    self.responsiveStyles = getFinalStyle(responsiveStyles: block.responsiveStyles)
    self.imageURL = URL(string: block.component?.options?["image"].string ?? "")

    if let ratio = block.component?.options?["aspectRatio"].doubleValue {
      self.aspectRatio = CGSize(width: ratio, height: 1)
    } else {
      self.aspectRatio = nil
    }

  }

  var body: some View {
    AsyncImage(url: imageURL) { phase in
      switch phase {
      case .empty:
        ProgressView()
      case .success(let image):
        image
          .resizable()
          .if(aspectRatio != nil) { view in
            view.aspectRatio(self.aspectRatio!, contentMode: .fit)
          }
      case .failure:
        Color.gray
      @unknown default:
        EmptyView()
      }
    }.responsiveStylesBuilderView(responsiveStyles: self.responsiveStyles ?? [:], isText: false)

  }
}
