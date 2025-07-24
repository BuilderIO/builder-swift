import SwiftUI

//BuilderBlock forms the out layout container for all components mimicking Blocks from response. As blocks can have layout direction of either horizontal or vertical a check is made and layout selected.

//BuilderBlock forms the out layout container for all components mimicking Blocks from response. As blocks can have layout direction of either horizontal or vertical a check is made and layout selected.

enum BuilderLayoutDirection {
  case horizontal
  case vertical
  case parentLayout
}

@MainActor
struct BuilderBlock: View {

  var blocks: [BuilderBlockModel]
  static let componentType: BuilderComponentType = .box
  let builderLayoutDirection: BuilderLayoutDirection  // Default to vertical direction
  let spacing: CGFloat  // Default to vertical direction

  init(
    blocks: [BuilderBlockModel], builderLayoutDirection: BuilderLayoutDirection = .parentLayout,
    spacing: CGFloat = 0
  ) {
    self.blocks = blocks
    self.builderLayoutDirection = builderLayoutDirection
    self.spacing = spacing
  }

  var body: some View {

    Group {
      if builderLayoutDirection == .parentLayout {
        blockContent()
      } else if builderLayoutDirection == .horizontal {
        LazyHStack(spacing: spacing) {  // Adjust alignment and spacing as needed
          blockContent()
        }
      } else {  // Default to column
        LazyVStack(spacing: spacing) {  // Adjust alignment and spacing as needed
          blockContent()
        }
      }
    }
  }

  @ViewBuilder
  private func blockContent() -> some View {
    ForEach(blocks) { child in
      let responsiveStyles = CSSStyleUtil.getFinalStyle(responsiveStyles: child.responsiveStyles)
      let component = child.component
      let spacing = CSSStyleUtil.extractPixels(responsiveStyles["gap"]) ?? 0

      // Only checking links for now, can be expanded to cover events in the future
      let isTappable =
        component?.name == BuilderComponentType.coreButton.rawValue
        || !(component?.options?.dictionaryValue?["Link"]?.stringValue?.isEmpty ?? true)
        || !(child.linkUrl?.isEmpty ?? true)

      let builderAction: BuilderAction? =
        (isTappable)
        ? BuilderAction(
          componentId: child.id,
          options: child.component?.options,
          eventActions: child.actions,
          linkURL: child.linkUrl) : nil

      if responsiveStyles["display"] == "none" {
        EmptyView()
      } else {
        BuilderBlockLayout(
          responsiveStyles: responsiveStyles ?? [:], builderAction: builderAction,
          component: component
        ) {
          if let component = component {
            BuilderComponentRegistry.shared.view(for: child)
          } else if let children = child.children, !children.isEmpty {
            BuilderBlock(
              blocks: children,
              builderLayoutDirection: responsiveStyles["flexDirection"] == "row"
                ? .horizontal : .vertical, spacing: spacing)
          } else {
            Rectangle().fill(Color.clear)
          }
        }
      }
    }
  }
}

struct BuilderBlockLayout<Content: View>: View {
  let responsiveStyles: [String: String]
  let builderAction: BuilderAction?
  let component: BuilderBlockComponent?

  @EnvironmentObject var buttonActionManager: BuilderActionManager

  // The content closure now takes an optional Bool, which represents the alignment for nested blocks.
  @ViewBuilder let content: () -> Content

  var body: some View {

    // 1. Extract basic layout parameters
    let direction = responsiveStyles["flexDirection"] ?? "column"
    let wrap = responsiveStyles["flexWrap"] == "wrap" && direction == "row"
    let scroll =
      (responsiveStyles["overflow"] == "auto" || responsiveStyles["overflow"] == "scroll")
      && direction == "row"

    let justify = responsiveStyles["justifyContent"]
    let alignItems = responsiveStyles["alignItems"]
    let alignSelf = responsiveStyles["alignSelf"]

    let marginLeft = responsiveStyles["marginLeft"]?.lowercased()
    let marginRight = responsiveStyles["marginRight"]?.lowercased()
    let marginTop = responsiveStyles["marginTop"]?.lowercased()
    let marginBottom = responsiveStyles["marginBottom"]?.lowercased()

    let spacing = CSSStyleUtil.extractPixels(responsiveStyles["gap"]) ?? 0
    let padding = extractEdgeInsets(
      for: "padding", from: responsiveStyles, with: getBorderWidth(from: responsiveStyles))
    let margin = extractEdgeInsets(for: "margin", from: responsiveStyles)

    let minHeight = CSSStyleUtil.extractPixels(responsiveStyles["minHeight"])
    let maxHeight = CSSStyleUtil.extractPixels(responsiveStyles["maxHeight"])
    let width = CSSStyleUtil.extractPixels(responsiveStyles["width"])
    let height = CSSStyleUtil.extractPixels(responsiveStyles["height"])

    let minWidth = CSSStyleUtil.extractPixels(responsiveStyles["minWidth"])
    let maxWidth =
      CSSStyleUtil.extractPixels(responsiveStyles["maxWidth"])
      ?? ((marginLeft == "auto" || marginRight == "auto" || alignSelf == "center")
        ? nil : .infinity)

    let borderRadius = CSSStyleUtil.extractPixels(responsiveStyles["borderRadius"]) ?? 0

    // 2. Build base layout (wrapped or not)
    let layoutView: some View = Group {
      if wrap {
        LazyVGrid(
          columns: [
            GridItem(.adaptive(minimum: 50), spacing: spacing)  // Spacing between columns (0 for tight fit like image)
          ],
          spacing: spacing,
          content: content
        )
        .frame(maxWidth: maxWidth)
        .padding(padding)
        .builderBackground(responsiveStyles: responsiveStyles)
        .builderBorder(properties: BorderProperties(responsiveStyles: responsiveStyles))
      } else if direction == "row" {
        let hStackAlignment = CSSAlignments.verticalAlignment(
          justify: justify, alignItems: alignItems, alignSelf: alignSelf)

        let frameAlignment: Alignment =
          switch hStackAlignment {
          case .top: .top
          case .center: .center
          case .bottom: .bottom
          default: .center
          }

        HStack(
          spacing: spacing
        ) {
          // Call content with the determined alignment for its children
          content()
            .padding(padding)
            .if(frameAlignment == .center && component == nil) { view in
              view.fixedSize(
                horizontal: responsiveStyles["width"] == "100%" ? false : true, vertical: false)
            }
            .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: frameAlignment)
            .builderBackground(responsiveStyles: responsiveStyles)
            .builderBorder(properties: BorderProperties(responsiveStyles: responsiveStyles))
        }
      } else {  // Default to VStack (column direction)

        let vStackAlignment = CSSAlignments.horizontalAlignment(
          marginsLeft: marginLeft, marginsRight: marginRight, justify: justify,
          alignItems: alignItems, alignSelf: alignSelf, responsiveStyles: responsiveStyles)

        let frameAlignment: Alignment =
          switch vStackAlignment {
          case .leading: .leading
          case .center: .center
          case .trailing: .trailing
          default: .leading
          }
        VStack(spacing: 0) {
          if marginTop == "auto" { Spacer() }

          let componentView: some View = content()  // Call content with the determined alignment
            .padding(padding)
            .if(width == nil && height == nil) { view in
              view.frame(
                minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight,
                alignment: (component?.name == BuilderComponentType.text.rawValue)
                  ? (CSSAlignments.textAlignment(responsiveStyles: responsiveStyles)).toAlignment
                  : .center
              )
              .builderBackground(responsiveStyles: responsiveStyles)
              .builderBorder(
                properties: BorderProperties(responsiveStyles: responsiveStyles)
              )
            }
            .if(width == nil && height != nil) { view in
              view.frame(maxWidth: .infinity)
            }
            .if(width != nil || height != nil) { view in
              view.frame(
                width: width,
                height: height ?? minHeight ?? nil,
                alignment: (component?.name == BuilderComponentType.text.rawValue)
                  ? (CSSAlignments.textAlignment(responsiveStyles: responsiveStyles)).toAlignment
                  : .center
              ).builderBackground(responsiveStyles: responsiveStyles)
                .builderBorder(
                  properties: BorderProperties(responsiveStyles: responsiveStyles)
                )
            }

          if let builderAction = builderAction {
            Button {
              buttonActionManager.handleButtonPress(builderAction: builderAction)
            } label: {
              componentView
                .if(marginTop == "auto" || marginBottom == "auto") { view in
                  view.fixedSize(horizontal: false, vertical: true)
                }
            }
          } else {
            componentView
              .if(marginTop == "auto" || marginBottom == "auto") { view in
                view.fixedSize(horizontal: false, vertical: true)
              }
          }

          if marginBottom == "auto" { Spacer() }
        }
        .frame(maxWidth: frameAlignment == .center ? nil : .infinity, alignment: frameAlignment)
      }
    }

    // 3. Wrap in scroll if overflow: auto
    let scrollableView: some View = Group {
      if scroll {
        ScrollView(.horizontal, showsIndicators: false) {
          layoutView
        }
      } else {
        layoutView
      }
    }

    // 4. Apply visual and layout modifiers
    return
      scrollableView
      .padding(margin)  //margin

  }

  func getBorderWidth(from styles: [String: String]) -> CGFloat {
    var borderWidth: CGFloat = 0
    if let widthString = responsiveStyles["borderWidth"],
      let value = Double(widthString.replacingOccurrences(of: "px", with: ""))
    {
      borderWidth += CGFloat(value)
    }

    return borderWidth
  }

  func extractEdgeInsets(
    for insetType: String, from styles: [String: String], with bufferWidth: CGFloat = 0
  ) -> EdgeInsets {

    let edgeInsets = EdgeInsets(
      top: (CSSStyleUtil.extractPixels(styles["\(insetType)Top"]) ?? 0) + bufferWidth,
      leading: (CSSStyleUtil.extractPixels(styles["\(insetType)Left"]) ?? 0) + bufferWidth,
      bottom: (CSSStyleUtil.extractPixels(styles["\(insetType)Bottom"]) ?? 0) + bufferWidth,
      trailing: (CSSStyleUtil.extractPixels(styles["\(insetType)Right"]) ?? 0) + bufferWidth
    )
    return edgeInsets
  }

}
