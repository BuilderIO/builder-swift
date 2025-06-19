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
                            alignment: frameAlignment
                        ).builderBackground(responsiveStyles: responsiveStyles).builderBackground(
                            responsiveStyles: responsiveStyles
                        ).builderBorder(properties: BorderProperties(responsiveStyles: responsiveStyles))
                }
            } else {
                
                let vStackAlignment = BuilderBlockLayout<Content>.horizontalAlignment(
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
                    
                    content().padding(padding)
                        .frame(
                            minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight,
                            alignment: frameAlignment
                        ).builderBackground(responsiveStyles: responsiveStyles).builderBorder(
                            properties: BorderProperties(responsiveStyles: responsiveStyles)
                        )
                    
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
              let number = Double(value)
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
        
        return EdgeInsets(
            top: (extractPixels(styles["\(insetType)Top"]) ?? 0) + bufferWidth,
            leading: (extractPixels(styles["\(insetType)Left"]) ?? 0) + bufferWidth,
            bottom: (extractPixels(styles["\(insetType)Bottom"]) ?? 0) + bufferWidth,
            trailing: (extractPixels(styles["\(insetType)Right"]) ?? 0) + bufferWidth
        )
    }
    
    static func horizontalAlignment(
        marginsLeft: String?, marginsRight: String?, justify: String?, alignItems: String?,
        responsiveStyles: [String: String]
    ) -> HorizontalAlignment {
        
        if let textAlign = responsiveStyles["textAlign"] {
            switch textAlign {
            case "center":
                return .center
            case "left", "start":  // "start" is also a common value in some contexts
                return .leading
            case "right", "end":  // "end" is also a common value
                return .trailing
            case "justify":
                break  // Fall through to next checks
            default:
                break  // Unknown textAlign value, fall through
            }
        }
        
        if (marginsLeft == "auto" && marginsRight == "auto") || justify == "center"
            || alignItems == "center"
        {
            return .center
        } else if marginsRight == "auto" || justify == "flex-start" || alignItems == "flex-start" {
            return .leading
        } else if marginsLeft == "auto" || justify == "flex-end" || alignItems == "flex-end" {
            return .trailing
        }
        return .leading
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
