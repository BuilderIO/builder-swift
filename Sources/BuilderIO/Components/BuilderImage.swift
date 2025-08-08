import SwiftUI

struct BuilderImage: BuilderViewProtocol {
  static let componentType: BuilderComponentType = .image

  var block: BuilderBlockModel
  var children: [BuilderBlockModel]?

  var imageURL: URL? = nil
  var aspectRatio: CGFloat? = nil
  var lockAspectRatio: Bool = false
  var contentMode: ContentMode = .fit
  var fitContent: Bool = false

  @State private var builderImageLoader: BuilderImageLoader = BuilderImageLoader()

  init(block: BuilderBlockModel) {
    self.block = block

    if let imageLink = block.component?.options?.dictionaryValue?["image"] {
      self.imageURL = URL(
        string: localize(localizedValue: imageLink) ?? "")
    }

    if let ratio = block.component?.options?.dictionaryValue?["aspectRatio"]?.doubleValue {
      self.aspectRatio = CGFloat(1 / ratio)
    }

    self.children = block.children
    self.contentMode =
      block.component?.options?.dictionaryValue?["backgroundSize"]?.stringValue == "cover"
      ? .fill : .fit
    self.fitContent =
      (block.component?.options?.dictionaryValue?["fitContent"]?.boolValue ?? false)
      && !(block.children?.isEmpty ?? true)

  }

  var body: some View {
    Group {
      switch builderImageLoader.imageStatus {
      case .loading:
        Rectangle()
          .fill(Color.clear)
          .aspectRatio(self.aspectRatio ?? 1, contentMode: self.contentMode)
          .overlay(ProgressView())
      case .error:
        Rectangle()
          .fill(Color.clear)
      case .loaded(let uiImage):
        if fitContent {
          // Content fits over the image, image acts as background
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
                Image(uiImage: uiImage)  // Use UIImage directly
                  .resizable()
                  .aspectRatio(self.aspectRatio ?? 1, contentMode: self.contentMode)
                  .clipped()
              )
            } else {
              EmptyView()  // No children, so nothing to show if fitContent is true without children
            }
          }
        } else {
          // Image fills the space, children overlay it
          Rectangle().fill(Color.clear)
            .aspectRatio(self.aspectRatio ?? 1, contentMode: self.contentMode)
            .background(
              Image(uiImage: uiImage)  // Use UIImage directly
                .resizable()
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

      }
    }
    .task {
      try? await Task.sleep(nanoseconds: 10_000_000)
      await builderImageLoader.loadImage(from: imageURL)
    }

  }
}
