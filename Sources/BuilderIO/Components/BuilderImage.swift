import SwiftUI

struct BuilderImage: BuilderViewProtocol {
  var componentType: BuilderComponentType = .image

  var block: BuilderBlockModel
  var children: [BuilderBlockModel]?

  var imageURL: URL?
  var aspectRatio: CGFloat? = nil
  var lockAspectRatio: Bool = false
  //  var height: CGFloat? = nil
  //  var width: CGFloat? = nil

  @State private var imageLoadedSuccessfully: Bool = false

  init(block: BuilderBlockModel) {
    self.block = block
    self.imageURL = URL(string: block.component?.options?["image"].string ?? "")
    if let ratio = block.component?.options?["aspectRatio"].float {
      self.aspectRatio = CGFloat(ratio)
    }
    self.children = block.children
  }

  var body: some View {

    AsyncImage(url: imageURL) { phase in
      switch phase {
      case .empty:
        ProgressView()
      case .success(let image):
        ZStack {
          image
            .resizable()
            .aspectRatio(1 / (self.aspectRatio ?? 1), contentMode: .fill)
            .clipped()
            .zIndex(0)

          if let children = children, !children.isEmpty {
            BuilderBlock(blocks: children)
              .zIndex(1)
          }
        }
      case .failure:
        Color.gray
      @unknown default:
        EmptyView()
      }
    }

  }
}
