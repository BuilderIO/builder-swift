import SwiftUI

struct BuilderImage: BuilderViewProtocol {
  var componentType: BuilderComponentType = .image

  var block: BuilderBlockModel
  var children: [BuilderBlockModel]?

  var imageURL: URL?

  @State private var imageLoadedSuccessfully: Bool = false

  init(block: BuilderBlockModel) {
    self.block = block
    self.imageURL = URL(string: block.component?.options?["image"].string ?? "")
    self.children = block.children
  }

  var body: some View {
    // Create a ZStack to layer the image and its children
    ZStack {
      AsyncImage(url: imageURL) { phase in
        switch phase {
        case .empty:
          ProgressView()
        case .success(let image):
          image.resizable().scaledToFill()
            .clipped().zIndex(0)
            .if((children?.count ?? 0) > 0) { view in
              view.overlay(content: {
                if let children = children {
                  BuilderBlock(blocks: children).zIndex(1)
                }
              })
            }
        case .failure:
          Color.gray
        @unknown default:
          EmptyView()
        }
      }
    }

  }
}
