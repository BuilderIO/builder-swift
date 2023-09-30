import SwiftUI

private typealias CSS = CSSStyleUtil

@available(iOS 15.0, macOS 10.15, *)
struct RenderBlock: View {
    var block: BuilderBlock
    var body: some View {
        let finalStyles = CSS.getFinalStyle(responsiveStyles: block.responsiveStyles );
        let bgColor = CSS.getColor(value: finalStyles["backgroundColor"]);
        let textAlignValue = finalStyles["textAlign"]
        let horizontalAlignment = CSS.getHorizontalAlignmentFromMargin(styles: finalStyles)
        let cornerRadius = CSS.getFloatValue(cssString:finalStyles["borderRadius"] ?? "0px")
        let borderWidth = CSS.getFloatValue(cssString:finalStyles["borderWidth"] ?? "0px")
        let borderColor = CSS.getColor(value: finalStyles["borderColor"] ?? "none");
        let padding = CSS.getBoxStyle(boxStyleProperty: "padding", finalStyles: finalStyles)
        let alignment = horizontalAlignment == HorizontalAlignment.LeftAlign ? Alignment.leading : (horizontalAlignment == HorizontalAlignment.Center ? Alignment.center : Alignment.trailing)
        
        if  finalStyles["display"] != "none" {
            let view = VStack(alignment: .center, spacing: 0) {
                
                let name = block.component?.name
                if name != nil {
                    let factoryValue = componentDict[name!]
                    
                    if factoryValue != nil && block.component?.options! != nil {
                        AnyView(_fromValue: factoryValue!(block.component!.options!, finalStyles, block.children))
                    }
                }
                
                if name == nil || !(componentDict[name!] != nil && block.component?.options! != nil) {
                    let _ = print("No Name for component or no factory", name ?? "NO NAME")
                    if block.children != nil {
                        RenderBlocks(blocks: block.children!)
                    }
                }
            }
        
        
            .padding(CSS.getBoxStyle(boxStyleProperty: "padding", finalStyles: finalStyles));
        
            let _ = print("Block ID", block.id, " Background color ", finalStyles["backgroundColor"] ?? "No BG Color")
            if (finalStyles["backgroundColor"] != nil) {
                view.background(bgColor)
                    .padding(CSS.getBoxStyle(boxStyleProperty: "margin", finalStyles: finalStyles))
                    .multilineTextAlignment(textAlignValue == "center" ? .center : textAlignValue == "right" ? .trailing : .leading)
                    .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, alignment: alignment)
                    .cornerRadius(cornerRadius)
            } else {
                view
                    .padding(CSS.getBoxStyle(boxStyleProperty: "margin", finalStyles: finalStyles))
                    .multilineTextAlignment(textAlignValue == "center" ? .center : textAlignValue == "right" ? .trailing : .leading)
                    .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, alignment: alignment)
                    .cornerRadius(cornerRadius)
            }
        }

        

    }
    
}
