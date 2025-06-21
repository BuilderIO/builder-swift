import SwiftUI

struct BuilderButton: BuilderViewProtocol {

  var componentType: BuilderComponentType = .coreButton

  var block: BuilderBlockModel
  var responsiveStyles: [String: String]?
  var buttonAction: ((String, String?) -> Void)?

  init(block: BuilderBlockModel) {
    self.block = block
    self.responsiveStyles = getFinalStyle(responsiveStyles: block.responsiveStyles)
  }

  func defaultHandleButtonClick() {

  }

  var body: some View {
    Button(action: {

    }) {
      let textAlignment = CSSAlignments.textAlignment(
        responsiveStyles: self.responsiveStyles ?? [:])
      let frameAlignment: Alignment =
        switch textAlignment {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        default: .leading
        }

      HStack {
        BuilderText(block: block)
      }.frame(alignment: frameAlignment)
    }
  }
}
