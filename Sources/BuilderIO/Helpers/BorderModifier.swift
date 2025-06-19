import SwiftUI

struct BorderProperties {
  var width: CGFloat = 0.0  // Default to no border
  var style: String = "none"  // Default to no border style
  var color: Color = .clear  // Default to clear color
  var radius: CGFloat = 0.0  // Default to no corner radius

  init(responsiveStyles: [String: String]) {
    // Parse width
    if let widthString = responsiveStyles["borderWidth"],
      let value = Double(widthString.replacingOccurrences(of: "px", with: ""))
    {
      self.width = CGFloat(value)
    }

    // Parse style
    if let styleString = responsiveStyles["borderStyle"] {
      self.style = styleString.lowercased()
    }

    // Parse color
    if let colorString = responsiveStyles["borderColor"],
      let parsedColor = Color(rgbaString: colorString)
    {
      self.color = parsedColor
    } else {
      self.color = Color.clear
    }

    // Parse radius
    if let radiusString = responsiveStyles["borderRadius"],
      let value = Double(radiusString.replacingOccurrences(of: "px", with: ""))
    {
      self.radius = CGFloat(value)
    }
  }
}

struct BorderModifier: ViewModifier {
  var properties: BorderProperties

  func body(content: Content) -> some View {
    content
      .cornerRadius(properties.radius)  // Apply corner radius to the content itself
      .overlay(
        Group {
          if properties.width > 0 {  // Only draw border if width > 0
            switch properties.style {
            case "solid":
              RoundedRectangle(cornerRadius: properties.radius)
                .stroke(properties.color, lineWidth: properties.width)
            case "dotted":
              RoundedRectangle(cornerRadius: properties.radius)
                .stroke(
                  properties.color,
                  style: StrokeStyle(
                    lineWidth: properties.width, lineCap: .round, dash: [0.1, properties.width * 2])
                )
                .border(Color.clear, width: 0.1)  // Workaround
            case "dashed":
              RoundedRectangle(cornerRadius: properties.radius)
                .stroke(
                  properties.color,
                  style: StrokeStyle(
                    lineWidth: properties.width, dash: [properties.width * 2, properties.width])
                )
                .border(Color.clear, width: 0.1)  // Workaround
            case "double":
              RoundedRectangle(cornerRadius: properties.radius)
                .stroke(properties.color, lineWidth: properties.width * 2 + 1)  // Outer line

              RoundedRectangle(cornerRadius: properties.radius)
                .stroke(Color.white, lineWidth: properties.width)  // Inner line (adjust for contrast)
            case "ridge":
              RoundedRectangle(cornerRadius: properties.radius)
                .strokeBorder(
                  LinearGradient(
                    gradient: Gradient(colors: [
                      properties.color.lighter(), properties.color.darker(),
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  ),
                  lineWidth: properties.width
                )
            case "groove":
              RoundedRectangle(cornerRadius: properties.radius)
                .strokeBorder(
                  LinearGradient(
                    gradient: Gradient(colors: [
                      properties.color.darker(), properties.color.lighter(),
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  ),
                  lineWidth: properties.width
                )
            case "none":  // Explicitly handle 'none' style
              EmptyView()
            default:
              EmptyView()  // Fallback for unknown/unsupported styles
            }
          } else {
            EmptyView()  // If borderWidth is 0 or less, don't draw border
          }
        }
      )
  }
}

// MARK: - View Extension for Modifier

extension View {
  func builderBorder(properties: BorderProperties) -> some View {
    self.modifier(BorderModifier(properties: properties))
  }
}
