import SwiftUI

//BuilderBlock forms the out layout container for all components mimicking Blocks from response. As blocks can have layout direction of either horizontal or vertical a check is made and layout selected.

@MainActor
struct BuilderBlock: View {

  var blocks: [BuilderBlockModel]
  static let componentType: BuilderComponentType = .box

  init(blocks: [BuilderBlockModel]) {
    self.blocks = blocks
  }

  var body: some View {

    ForEach(blocks) { child in
      let responsiveStyles = CSSStyleUtil.getFinalStyle(responsiveStyles: child.responsiveStyles)
      let component = child.component

      //Only checking links for now, can be expanded to cover events in the future
      let isTappable =
        component?.name == BuilderComponentType.coreButton.rawValue
        || !(component?.options?["Link"].isEmpty ?? true) || !(child.linkUrl?.isEmpty ?? true)

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
            BuilderBlock(blocks: children)
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
    let scroll = responsiveStyles["overflow"] == "auto" && direction == "row"

    let justify = responsiveStyles["justifyContent"]
    let alignItems = responsiveStyles["alignItems"]
    let alignSelf = responsiveStyles["alignSelf"]

    let marginLeft = responsiveStyles["marginLeft"]?.lowercased()
    let marginRight = responsiveStyles["marginRight"]?.lowercased()
    let marginTop = responsiveStyles["marginTop"]?.lowercased()
    let marginBottom = responsiveStyles["marginBottom"]?.lowercased()

    let spacing = extractPixels(responsiveStyles["gap"]) ?? 0
    let padding = extractEdgeInsets(
      for: "padding", from: responsiveStyles, with: getBorderWidth(from: responsiveStyles))
    let margin = extractEdgeInsets(for: "margin", from: responsiveStyles)

    let minHeight = extractPixels(responsiveStyles["minHeight"])
    let maxHeight = extractPixels(responsiveStyles["maxHeight"])
    let width = extractPixels(responsiveStyles["width"])
    let height = extractPixels(responsiveStyles["height"])

    let minWidth = extractPixels(responsiveStyles["minWidth"])
    let maxWidth =
      extractPixels(responsiveStyles["maxWidth"])
      ?? ((marginLeft == "auto" || marginRight == "auto" || alignSelf == "center")
        ? nil : .infinity)

    let borderRadius = extractPixels(responsiveStyles["borderRadius"]) ?? 0

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
        .if(frameAlignment == .center && component == nil) { view in
          view.fixedSize(horizontal: false, vertical: false)
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
      //      .if(component == nil) { view in
      //        view.builderBackground(responsiveStyles: responsiveStyles)
      //      }
      .padding(margin)  //margin

  }

  func extractPixels(_ value: String?) -> CGFloat? {
    guard let value = value?.replacingOccurrences(of: "px", with: ""),
      let number = Int(value)
    else { return nil }
    return CGFloat(number)
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
      top: (extractPixels(styles["\(insetType)Top"]) ?? 0) + bufferWidth,
      leading: (extractPixels(styles["\(insetType)Left"]) ?? 0) + bufferWidth,
      bottom: (extractPixels(styles["\(insetType)Bottom"]) ?? 0) + bufferWidth,
      trailing: (extractPixels(styles["\(insetType)Right"]) ?? 0) + bufferWidth
    )
    return edgeInsets
  }

}
