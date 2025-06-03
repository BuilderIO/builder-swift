import SwiftUI
import SwiftyJSON

struct BuilderBox: View {
    
    var componentType: BuilderComponentType = .box
    var responsiveStyles: [String: String]?
    var children: [BuilderBlock]?
    var isHorizontal: Bool = false
    
    init(children: [BuilderBlock]?, styles: [String: String]?) {
        self.responsiveStyles = styles
        self.children = children
        self.isHorizontal = (styles?["flexDirection"] == CSSConstants.FlexDirection.row.rawValue)
        
    }
    
    var body: some View {
        let layout = isHorizontal ? AnyLayout(HStackLayout(alignment: .center))
        : AnyLayout(VStackLayout(alignment: .center))
        
        ScrollView {
            layout {
                if let children = children {
                    ForEach(children.indices, id: \.self) { index in
                        
                        // nil check on component
                        if let component = children[index].component  {
                            BuilderComponentRegistry.shared.view(for:  component, responsiveStyles: CSSStyleUtil.getFinalStyle(responsiveStyles: children[index].responsiveStyles))
                            //if children then zstack below
                            if (children[index].children != nil && children[index].children!.count > 0) {
                            }
                        } else {
                            EmptyView()
                        }
                        
                      
                    }
                }
            }.modifier(ResponsiveStylesBuilderView(responsiveStyles: responsiveStyles ?? [:], isText: false))
            
        }
        
    }
        

}
