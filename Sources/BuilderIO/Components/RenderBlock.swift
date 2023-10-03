import SwiftUI

private typealias CSS = CSSStyleUtil

@available(iOS 15.0, macOS 10.15, *)
struct RenderBlock: View {
    var block: BuilderBlock
    
    func getIdealWidth(finalStyles: [String: String], maxWidth: CGFloat) -> CGFloat {
        let idealWidth = finalStyles["alignSelf"] == "stretch" || finalStyles["alignSelf"] == "center" ? .infinity : (finalStyles["width"] != nil ? CSS.getFloatValue(cssString: finalStyles["width"]) : .infinity);
        return maxWidth != .infinity && idealWidth == .infinity ? maxWidth : idealWidth;
    }
    
    var body: some View {
        let finalStyles = CSS.getFinalStyle(responsiveStyles: block.responsiveStyles );
        let hasBgColor = finalStyles["backgroundColor"] != nil;

        let hasMinHeight = finalStyles["minHeight"] != nil;
        let minHeight = CSS.getFloatValue(cssString: finalStyles["minHeight"] ?? "0px");
        let bgColor = CSS.getColor(value: finalStyles["backgroundColor"]);
        let textAlignValue = finalStyles["textAlign"]
        let horizontalAlignment = CSS.getHorizontalAlignment(styles: finalStyles)
        let cornerRadius = CSS.getFloatValue(cssString:finalStyles["borderRadius"] ?? "0px")
        let borderWidth = CSS.getFloatValue(cssString:finalStyles["borderWidth"] ?? "0px")
        let borderColor = CSS.getColor(value: finalStyles["borderColor"] ?? "none");
        let alignment = horizontalAlignment == HorizontalAlignment.LeftAlign ? Alignment.leading : (horizontalAlignment == HorizontalAlignment.Center ? Alignment.center : Alignment.trailing)
        let maxWidth = CSS.getFloatValue(cssString: finalStyles["maxWidth"], defaultValue: .infinity) ;
        let idealWidth = self.getIdealWidth(finalStyles: finalStyles, maxWidth: maxWidth)
        let hasWidth = idealWidth != .infinity;
        
        let name = block.component?.name
        let isEmptyView = (name == nil || componentDict[name!]  == nil) && block.children == nil;
        if  finalStyles["display"] != "none" {
            if (isEmptyView) {
                // SwiftUI Does not like empty vstacks and just does not
                // render it. SO instead, we render a rectangle just for a case
                // where we have an empty block with no children that we use
                // as spacers.
                Rectangle()
                    .if(hasMinHeight) { view in
                        view.frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: minHeight, idealHeight: minHeight, alignment: alignment)
                    }
                    .if(!hasMinHeight) { view in
                        view.frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, alignment: alignment)
                    }
                    .padding(CSS.getBoxStyle(boxStyleProperty: "padding", finalStyles: finalStyles))
                    
                    .if(hasBgColor) { view in
                        view.foregroundColor(bgColor)
                    }
                    .padding(CSS.getBoxStyle(boxStyleProperty: "margin", finalStyles: finalStyles))
                    
            } else {
                let _ = print("Block", block.id, "Ideal Width", idealWidth, "Max Width", maxWidth, "has width", hasWidth);
                VStack(alignment: .center, spacing: 0) {
                    
                    if name != nil {
                        let factoryValue = componentDict[name!]
                        
                        if factoryValue != nil && block.component?.options! != nil {
                            AnyView(_fromValue: factoryValue!(block.component!.options!, finalStyles, block.children))
                        }
                    }
                    
                    if name == nil || !(componentDict[name!] != nil && block.component?.options! != nil) {
    //                    let _ = print("No Name for component or no factory", name ?? "NO NAME")
                        if block.children != nil {
                            RenderBlocks(blocks: block.children!)
                        }
                    }
                }
                .if(hasWidth) { view in
                    view.frame(minWidth: 0, idealWidth: idealWidth, maxWidth: idealWidth, alignment: alignment)
                }
                .if(!hasWidth) { view in
                    view.frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, alignment: alignment)
                }
                .padding(CSS.getBoxStyle(boxStyleProperty: "padding", finalStyles: finalStyles))
                .if(hasBgColor) { view in
                    view.background(bgColor)
                }
                .background(Color.purple)
                .padding(CSS.getBoxStyle(boxStyleProperty: "margin", finalStyles: finalStyles))
                .multilineTextAlignment(textAlignValue == "center" ? .center : textAlignValue == "right" ? .trailing : .leading)
                
                
                
                .cornerRadius(cornerRadius)
            }
            
          
        }

        

    }
    
}
