import SwiftUI

struct RenderBlocks: View {
    var blocks: [BuilderBlock]
    
    var body: some View {
        BuilderBox(children: blocks, styles: nil)
    }
    
   
}
