import SwiftUI

struct BuilderImage: BuilderViewProtocol {
  var componentType: BuilderComponentType = .image

  var block: BuilderBlockModel
  var children: [BuilderBlockModel]?

  var imageURL: URL?
  var aspectRatio: CGFloat? = nil
  var lockAspectRatio: Bool = false
  var contentMode: ContentMode = .fit

  //  var height: CGFloat? = nil
  //  var width: CGFloat? = nil

  @State private var imageLoadedSuccessfully: Bool = false

  init(block: BuilderBlockModel) {
    self.block = block
    self.imageURL = URL(string: block.component?.options?["image"].string ?? "")
    if let ratio = block.component?.options?["aspectRatio"].float {
      self.aspectRatio = CGFloat(1 / ratio)
    }
    self.children = block.children
    self.contentMode = block.component?.options?["backgroundSize"] == "cover" ? .fill : .fit
  }

  var body: some View {

    AsyncImage(url: imageURL) { phase in
      switch phase {
      case .empty:
        ProgressView()
      case .success(let image):

        image
          .resizable()
          .aspectRatio(self.aspectRatio ?? 1, contentMode: .fill)
          .clipped()
          .overlay(
            Group {
              if let children = children, !children.isEmpty {
                VStack(spacing: 0) {
                  BuilderBlock(blocks: children)
                }
              } else {
                EmptyView()
              }
            }
          )

      case .failure:
        Color.gray
      @unknown default:
        EmptyView()
      }
    }

  }
}
