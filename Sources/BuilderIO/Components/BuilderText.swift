import SwiftUI
import SwiftyJSON

struct BuilderText: BuilderViewProtocol {
  var block: BuilderBlockModel

  var componentType: BuilderComponentType = .text

  var responsiveStyles: [String: String]?
  var text: String?

  init(block: BuilderBlockModel) {
    self.block = block
    self.text = block.component?.options?["text"].string ?? ""
    self.responsiveStyles = getFinalStyle(responsiveStyles: block.responsiveStyles)
  }

  var body: some View {
    Text(CSSStyleUtil.getTextWithoutHtml(text ?? ""))
  }

}
