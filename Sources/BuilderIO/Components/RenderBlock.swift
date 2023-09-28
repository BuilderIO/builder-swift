import SwiftUI

private typealias CSS = CSSStyleUtil

@available(iOS 15.0, macOS 10.15, *)
struct RenderBlock: View {
    var block: BuilderBlock
    var body: some View {
        let finalStyles = CSS.getFinalStyle(responsiveStyles: block.responsiveStyles );
        let textAlignValue = finalStyles["textAlign"]
        let horizontalAlignment = CSS.getHorizontalAlignmentFromMargin(styles: finalStyles)
        let alignment = horizontalAlignment == HorizontalAlignment.LeftAlign ? Alignment.leading : (horizontalAlignment == HorizontalAlignment.Center ? Alignment.center : Alignment.trailing)
        
        VStack(alignment: .center, spacing: 0) {
            if  finalStyles["display"] != "none" {
                let name = block.component?.name
                var childrenRendered = false;
                if name != nil {
                    let factoryValue = componentDict[name!]

                    if factoryValue != nil && block.component?.options! != nil {
                        AnyView(_fromValue: factoryValue!(block.component!.options!, finalStyles, block.children))
                    }
                }
                
                if name == nil || (componentDict[name!] != nil && block.component?.options! != nil) {
                    let _ = print("No Name for component or no factory", name!)
                    if block.children != nil {
                        RenderBlocks(blocks: block.children!)
                    }
                }
            }
        }
        .padding(CSS.getBoxStyle(boxStyleProperty: "margin", finalStyles: finalStyles)) // margin
        .multilineTextAlignment(textAlignValue == "center" ? .center : textAlignValue == "right" ? .trailing : .leading)
        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, alignment: alignment)

    }
    
}
