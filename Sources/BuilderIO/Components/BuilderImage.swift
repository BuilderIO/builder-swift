import SwiftUI

struct BuilderImage: BuilderViewProtocol {
  static let componentType: BuilderComponentType = .image

  var block: BuilderBlockModel
  var children: [BuilderBlockModel]?

  var imageURL: URL?
  var aspectRatio: CGFloat? = nil
  var lockAspectRatio: Bool = false
  var contentMode: ContentMode = .fit
  var fitContent: Bool = false

  @State private var imageLoadedSuccessfully: Bool = false

  init(block: BuilderBlockModel) {
    self.block = block
    self.imageURL = URL(string: block.component?.options?["image"].string ?? "")
    if let ratio = block.component?.options?["aspectRatio"].float {
      self.aspectRatio = CGFloat(1 / ratio)
    }

    self.children = block.children
    self.contentMode = block.component?.options?["backgroundSize"] == "cover" ? .fill : .fit
    self.fitContent =
      (block.component?.options?["fitContent"].boolValue ?? false)
      && !(block.children?.isEmpty ?? true)

  }

  var body: some View {

    AsyncImage(url: imageURL) { phase in
      switch phase {
      case .empty:
        ProgressView()
      case .success(let image):
        if fitContent {
          Group {
            if let children = children, !children.isEmpty {
              VStack(spacing: 0) {
                Spacer()
                BuilderBlock(blocks: children).fixedSize(horizontal: false, vertical: true)
                Spacer()
              }
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .padding(0)
              .background(
                image.resizable()
                  .aspectRatio(self.aspectRatio ?? 1, contentMode: self.contentMode)
                  .clipped()
              )
            } else {
              EmptyView()
            }
          }

        } else {
          Rectangle().fill(Color.clear)
            .aspectRatio(self.aspectRatio ?? 1, contentMode: self.contentMode)
            .background(
              image.resizable()
                .aspectRatio(contentMode: self.contentMode)
                .clipped()
            )
            .overlay(
              Group {
                if let children = children, !children.isEmpty {
                  VStack(spacing: 0) {
                    BuilderBlock(blocks: children).fixedSize(horizontal: true, vertical: false)
                  }
                } else {
                  EmptyView()
                }
              }
            )
        }

      case .failure:
        EmptyView()
      @unknown default:
        EmptyView()
      }
    }

  }
}
