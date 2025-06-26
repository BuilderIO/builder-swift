import SwiftUI

//BuilderBlock forms the out layout container for all components mimicking Blocks from response. As blocks can have layout direction of either horizontal or vertical a check is made and layout selected.

@MainActor
struct BuilderBlock: View {

  var blocks: [BuilderBlockModel]
  var componentType: BuilderComponentType = .box

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

      BuilderBlockLayout(responsiveStyles: responsiveStyles ?? [:], builderAction: builderAction) {
        if let component = child.component {
          BuilderComponentRegistry.shared.view(for: child)
        } else if let children = child.children, !children.isEmpty {
          BuilderBlock(blocks: children)
        } else {
          EmptyView()
        }
      }

    }

  }

}

struct BuilderBlockLayout<Content: View>: View {
  let responsiveStyles: [String: String]
  let builderAction: BuilderAction?
  @Environment(\.buttonActionManager) private var buttonActionManager

  @ViewBuilder let content: () -> Content

  var body: some View {

    // 1. Extract basic layout parameters
    let direction = responsiveStyles["flexDirection"] ?? "column"
    let wrap = responsiveStyles["flexWrap"] == "wrap" && direction == "row"
    let scroll = responsiveStyles["overflow"] == "auto" && direction == "row"

    let justify = responsiveStyles["justifyContent"]
    let alignItems = responsiveStyles["alignItems"]

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
    let minWidth = extractPixels(responsiveStyles["minWidth"])
    let maxWidth =
      extractPixels(responsiveStyles["maxWidth"])
      ?? ((marginLeft == "auto" || marginRight == "auto") ? nil : .infinity)

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
        ).frame(maxWidth: maxWidth).padding(padding).builderBackground(
          responsiveStyles: responsiveStyles
        ).builderBackground(
          responsiveStyles: responsiveStyles
        ).builderBorder(properties: BorderProperties(responsiveStyles: responsiveStyles))
      } else if direction == "row" {
        let hStackAlignment = CSSAlignments.verticalAlignment(
          justify: justify, alignItems: alignItems)

        let frameAlignment: Alignment =
          switch hStackAlignment {
          case .top: .top
          case .center: .center
          case .bottom: .bottom
          default: .center
          }

        HStack(
          alignment: hStackAlignment, spacing: spacing
        ) {
          content().padding(padding)
            .frame(
              minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight,
              alignment: frameAlignment
            ).builderBackground(responsiveStyles: responsiveStyles).builderBackground(
              responsiveStyles: responsiveStyles
            ).builderBorder(properties: BorderProperties(responsiveStyles: responsiveStyles))
        }
      } else {

        let vStackAlignment = CSSAlignments.horizontalAlignment(
          marginsLeft: marginLeft, marginsRight: marginRight, justify: justify,
          alignItems: alignItems, responsiveStyles: responsiveStyles)

        let frameAlignment: Alignment =
          switch vStackAlignment {
          case .leading: .leading
          case .center: .center
          case .trailing: .trailing
          default: .leading
          }
        VStack {
          if marginTop == "auto" { Spacer() }

          let componentView: some View = content().padding(padding)
            .frame(
              minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight,
              alignment: frameAlignment
            ).builderBackground(responsiveStyles: responsiveStyles).builderBorder(
              properties: BorderProperties(responsiveStyles: responsiveStyles)
            )

          if let builderAction = builderAction {
            Button {
              buttonActionManager?.handleButtonPress(builderAction: builderAction)
            } label: {
              componentView
            }
          } else {
            componentView
          }

          if marginBottom == "auto" { Spacer() }
        }.frame(maxWidth: .infinity, alignment: frameAlignment)
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
      scrollableView.padding(margin)  //margin

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
