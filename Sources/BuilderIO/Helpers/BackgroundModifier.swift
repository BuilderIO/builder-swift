import SwiftUI

struct BackgroundModifier: ViewModifier {
  let responsiveStyles: [String: String]

  func body(content: Content) -> some View {

    if let hexColor = responsiveStyles["backgroundColor"],
      let color = Color(string: hexColor)
    {
      content.background(color)
    } else {
      content  // Return the original view if no valid background color is found
    }

  }
}

extension View {
  func builderBackground(responsiveStyles: [String: String]) -> some View {
    self.modifier(BackgroundModifier(responsiveStyles: responsiveStyles))
  }
}
