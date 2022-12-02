import SwiftUI

private typealias CSS = CSSStyleUtil

@available(iOS 15.0, macOS 10.15, *)
struct RenderBlock: View {
    var block: BuilderBlock
    var body: some View {
        let finalStyles = CSS.getFinalStyle(responsiveStyles: block.responsiveStyles );
        let textAlignValue = finalStyles["textAlign"]
//        let displayValue = getStyleValue("display")
//        let flexDirection = getStyleValue("flexDirection")
//        let position = getStyleValue("position")
//        let flexShrink = getStyleValue("flexShrink")
//        let boxSizing = getStyleValue("boxSizing")
//        let marginTop = getStyleValue("marginTop")
//        let appearance = getStyleValue("appearance")
//        let color = getStyleValue("color")
//        let cursor = getStyleValue("cursor")
//        let marginLeft = getStyleValue("marginLeft")
//        let width = getStyleValue("width")
//        let alignSelf = getStyleValue("alignSelf")
//        let fontSize = getFloatValue(cssString: "fontSize") ?? 0.
        
        VStack {
            if #available(iOS 16.0, *) {
                
                
                VStack(alignment: .center) {
                    let name = block.component?.name
                    if name != nil {
                        let factoryValue = componentDict[name!]
                        //                    print("componentDict[name!] = \(componentDict[name!])")
                        
                        if factoryValue != nil && block.component?.options! != nil {
                            AnyView(_fromValue: factoryValue!(block.component!.options!, finalStyles))
                        } else {
                            let _ = print("Could not find component", name!)
                        }
                        
                    }
                    if block.children != nil {
                        RenderBlocks(blocks: block.children!)
                    }
                }
                .padding(CSS.getBoxStyle(boxStyleProperty: "margin", finalStyles: finalStyles)) // margin
                .multilineTextAlignment(textAlignValue == "center" ? .center : textAlignValue == "right" ? .trailing : .leading)
                .font(.title)
                .fontWeight(Font.Weight.bold)
            } else {
                // Fallback on earlier versions
            }
        }
    }

    
}
