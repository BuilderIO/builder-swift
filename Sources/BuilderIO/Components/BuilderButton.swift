import SwiftUI

struct BuilderButton: BuilderViewProtocol {

  var componentType: BuilderComponentType = .coreButton

  var block: BuilderBlockModel
  var responsiveStyles: [String: String]?
  @State private var isPressed: Bool = false

  @Environment(\.buttonActionManager) private var buttonActionManager

  init(block: BuilderBlockModel) {
    self.block = block
    self.responsiveStyles = getFinalStyle(responsiveStyles: block.responsiveStyles)
  }

  var body: some View {
    Button(action: {
      let buttonId = block.id ?? "unknown_button"
      let buttonData = "button_data"

      buttonActionManager?.handleButtonPress(buttonId: buttonId, data: buttonData)
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
        
    }.buttonStyle(PressEffectButtonStyle(isPressed: $isPressed))

  }
}

struct PressEffectButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Apply the scale effect and animation here
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Shrinks to 95% when pressed
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed) // Smooth animation

            // Update the binding to reflect the button's pressed state.
            // This is primarily useful if you need the isPressed state for other
            // logic outside of the visual effect directly applied in this makeBody.
            // For older iOS versions:
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
            // For iOS 17+:
            // .onChange(of: configuration.isPressed, initial: true) { oldValue, newValue in
            //     isPressed = newValue
            // }
    }
}
