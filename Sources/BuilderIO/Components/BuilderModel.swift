import SwiftUI
import SwiftyJSON

//BuilderBox forms the out layout container for all components mimicking Blocks from response. As blocks can have layout direction of either horizontal or vertical a check is made and layout selected.

struct BuilderModel:  View {
    
    var blocks: [BuilderBlockModel]
    var componentType: BuilderComponentType = .box
    
    init(blocks: [BuilderBlockModel]) {
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
                
                Group {
                    if isHorizontal {
                        ScrollView(.horizontal, showsIndicators: false) {
                            layout {
                                layoutContent(for: child)
                            }.modifier(ResponsiveStylesBuilderView(responsiveStyles: responsiveStyles ?? [:], isText: false))
                        }
                    } else {
                        layout {
                            layoutContent(for: child)
                        }.modifier(ResponsiveStylesBuilderView(responsiveStyles: responsiveStyles ?? [:], isText: false))
                    }
                }
               
                
            }
        }
    }
    
    @ViewBuilder
     private func layoutContent(for child: BuilderBlockModel) -> some View {
         if let component = child.component {
             BuilderComponentRegistry.shared.view(for: child)
         } else if let children = child.children, !children.isEmpty {
             BuilderModel(blocks: children)
         } else {
             Spacer()
         }
     }
    
}
        


