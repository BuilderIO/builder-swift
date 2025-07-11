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
          Spacer()
            .aspectRatio(self.aspectRatio ?? 1, contentMode: self.contentMode)
            .background(
              image.resizable()
                .if(self.contentMode == .fill) { view in
                    view.aspectRatio(self.aspectRatio ?? 1, contentMode: self.contentMode)
                } .if(self.contentMode == .fit) { view in
                  view.scaledToFill().fixedSize(horizontal: false, vertical: false)
                }
                .clipped()
            )
            .overlay(
              Group {
                if let children = children, !children.isEmpty {
                  VStack(spacing: 0) {
                    BuilderBlock(blocks: children).fixedSize(horizontal: true, vertical: true)
                  }.frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                  EmptyView()
                }
              }
            )
        }

      case .failure:
        Color.gray
      @unknown default:
        EmptyView()
      }
    }

  }
}
