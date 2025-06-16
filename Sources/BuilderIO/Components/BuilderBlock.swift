import SwiftUI
import SwiftyJSON

//BuilderBlock forms the out layout container for all components mimicking Blocks from response. As blocks can have layout direction of either horizontal or vertical a check is made and layout selected.

struct BuilderBlock: View {

  var blocks: [BuilderBlockModel]
  var componentType: BuilderComponentType = .box

  init(blocks: [BuilderBlockModel]) {
    self.blocks = blocks
  }

  var body: some View {

    ForEach(Array(blocks.enumerated()), id: \.offset) { index, child in
      let responsiveStyles = CSSStyleUtil.getFinalStyle(responsiveStyles: child.responsiveStyles)

      BuilderBlockLayout(responsiveStyles: responsiveStyles ?? [:]) {
        if let component = child.component {
          BuilderComponentRegistry.shared.view(for: child)
        } else if let children = child.children, !children.isEmpty {
          BuilderBlock(blocks: children)
        } else {
          Spacer()
        }
      }

    }

  }

}

struct BuilderBlockLayout<Content: View>: View {
  let responsiveStyles: [String: String]
  @ViewBuilder let content: () -> Content

  var body: some View {

    // 1. Extract basic layout parameters
    let direction = responsiveStyles["flexDirection"] ?? "column"
    let wrap = responsiveStyles["flexWrap"] == "wrap"
    let scroll = responsiveStyles["overflow"] == "auto" && direction == "row"

    let justify = responsiveStyles["justifyContent"]
    let alignItems = responsiveStyles["alignItems"]

    let marginLeft = responsiveStyles["marginLeft"]?.lowercased()
    let marginRight = responsiveStyles["marginRight"]?.lowercased()

    let spacing = extractPixels(responsiveStyles["gap"]) ?? 0
    let padding = extractEdgeInsets(for: "padding", from: responsiveStyles)
    let margin = extractEdgeInsets(for: "margin", from: responsiveStyles)

    let minHeight = extractPixels(responsiveStyles["minHeight"])
    let maxHeight = extractPixels(responsiveStyles["maxHeight"]) ?? .infinity
    let minWidth = extractPixels(responsiveStyles["minWidth"])
    let maxWidth = extractPixels(responsiveStyles["maxWidth"]) ?? .infinity

    let borderRadius = extractPixels(responsiveStyles["borderRadius"]) ?? 0

    // 2. Build base layout (wrapped or not)
    let layoutView: some View = Group {
      if wrap {
        LazyVGrid(
          columns: [GridItem(.adaptive(minimum: 100), spacing: spacing)],
          alignment: BuilderBlockLayout<Content>.horizontalAlignment(
            marginsLeft: marginLeft, marginsRight: marginRight, justify: justify,
            alignItems: alignItems),
          spacing: spacing,
          content: content
        )
      } else if direction == "row" {
        let hStackAlignment = BuilderBlockLayout<Content>.verticalAlignment(
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
              alignment: frameAlignment)
        }
      } else {

        let vStackAlignment = BuilderBlockLayout<Content>.horizontalAlignment(
          marginsLeft: marginLeft, marginsRight: marginRight, justify: justify,
          alignItems: alignItems)

        let frameAlignment: Alignment =
          switch vStackAlignment {
          case .leading: .leading
          case .center: .center
          case .trailing: .trailing
          default: .center
          }

        VStack(
          alignment: vStackAlignment, spacing: spacing
        ) {

          content().padding(padding)
            .frame(
              minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight,
              alignment: frameAlignment)
        }
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
      .cornerRadius(borderRadius)
  }

  func extractPixels(_ value: String?) -> CGFloat? {
    guard let value = value?.replacingOccurrences(of: "px", with: ""),
      let number = Double(value)
    else { return nil }
    return CGFloat(number)
  }

  func extractEdgeInsets(for insetType: String, from styles: [String: String]) -> EdgeInsets {

    return EdgeInsets(
      top: extractPixels(styles["\(insetType)Top"]) ?? 0,
      leading: extractPixels(styles["\(insetType)Left"]) ?? 0,
      bottom: extractPixels(styles["\(insetType)Bottom"]) ?? 0,
      trailing: extractPixels(styles["\(insetType)Right"]) ?? 0
    )
  }

  static func horizontalAlignment(
    marginsLeft: String?, marginsRight: String?, justify: String?, alignItems: String?
  ) -> HorizontalAlignment {

    if (marginsLeft == "auto" && marginsRight == "auto") || justify == "center"
      || alignItems == "center"
    {
      return .center
    } else if marginsLeft == "auto" || justify == "flex-start" || alignItems == "flex-start" {
      return .leading
    } else if marginsRight == "auto" || justify == "flex-end" || alignItems == "flex-end" {
      return .trailing
    }
    return .center
  }

  static func verticalAlignment(justify: String?, alignItems: String?) -> VerticalAlignment {

    if justify == "center" || alignItems == "center" {
      return .center
    } else if justify == "flex-start" || alignItems == "flex-start" {
      return .top
    } else if justify == "flex-end" || alignItems == "flex-end" {
      return .bottom
    }
    return .center
  }

}
