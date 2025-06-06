import SwiftUI
import SwiftyJSON

//Builder Block grouping from response
struct BuilderBox:  View {
    
    var blocks: [BuilderBlock]
    var componentType: BuilderComponentType = .box
    
    init(blocks: [BuilderBlock]) {
        self.blocks = blocks
    }
    
    
    var body: some View {

        ScrollView {
            
            ForEach(Array(blocks.enumerated()), id: \.offset) { index, child in
                let responsiveStyles = CSSStyleUtil.getFinalStyle(responsiveStyles: child.responsiveStyles)
                
                //Calculate the layout direction based on the responsive styles
                let isHorizontal = (responsiveStyles["flexDirection"] == CSSConstants.FlexDirection.row.rawValue)
                let layout = isHorizontal ? AnyLayout(HStackLayout(alignment: .center))
                : AnyLayout(VStackLayout(alignment: .center))
                
                layout {
                    // nil check on component
                    if let component = child.component  {
                        BuilderComponentRegistry.shared.view(for: child)
                    } else if(child.children != nil && child.children!.count > 0){
                        BuilderBox(blocks: child.children!)
                    } else {
                        EmptyView()
                    }
                }.modifier(ResponsiveStylesBuilderView(responsiveStyles: responsiveStyles ?? [:], isText: false))
                
                
                
            }
        }
    }
    
}
        


