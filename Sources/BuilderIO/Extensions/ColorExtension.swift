import SwiftUI

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

extension Color {
  /// Initializes a Color from a string representation, supporting RGBA, Hex, and a basic set of named colors.
  ///
  /// Supported formats:
  /// - RGBA: "rgba(r, g, b, a)", "rgb(r, g, b)"
  /// - Hex: "#RRGGBB", "#RGB", "#RRGGBBAA", "#RGBA"
  /// - Named Colors: "red", "blue", "green", "white", "black", "gray", "clear" (and more can be added)
  init?(string: String) {
    let cleanedString = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

    // MARK: - 1. Try to parse RGBA string
    if cleanedString.hasPrefix("rgba(") || cleanedString.hasPrefix("rgb(") {
      let scanner = Scanner(string: cleanedString)
      scanner.charactersToBeSkipped = CharacterSet(charactersIn: "rgba(), ")

      var r: Double = 0
      var g: Double = 0
      var b: Double = 0
      var a: Double = 1.0  // Default alpha for rgb() strings

      // Move past "rgba(" or "rgb("
      _ = scanner.scanUpToCharacters(from: CharacterSet.decimalDigits)

      if scanner.scanDouble(&r),
        scanner.scanDouble(&g),
        scanner.scanDouble(&b)
      {
        // Try to scan alpha if it's an rgba string
        if cleanedString.hasPrefix("rgba(") {
          _ = scanner.scanUpToCharacters(from: CharacterSet.decimalDigits)  // Move past comma if any
          scanner.scanDouble(&a)
        }

        self.init(
          red: r / 255.0,
          green: g / 255.0,
          blue: b / 255.0,
          opacity: a
        )
        return
      }
    }

    // MARK: - 2. Try to parse Hex string
    if cleanedString.hasPrefix("#") {
      let hexString = String(cleanedString.dropFirst())
      let scanner = Scanner(string: hexString)
      var hexValue: UInt64 = 0

      guard scanner.scanHexInt64(&hexValue) else { return nil }

      let r: Double
      let g: Double
      let b: Double
      let a: Double
      let length = hexString.count

      switch length {
      case 3:  // #RGB
        r = Double((hexValue & 0xF00) >> 8) / 15.0
        g = Double((hexValue & 0x0F0) >> 4) / 15.0
        b = Double(hexValue & 0x00F) / 15.0
        a = 1.0
      case 4:  // #RGBA
        r = Double((hexValue & 0xF000) >> 12) / 15.0
        g = Double((hexValue & 0x0F00) >> 8) / 15.0
        b = Double((hexValue & 0x00F0) >> 4) / 15.0
        a = Double(hexValue & 0x000F) / 15.0
      case 6:  // #RRGGBB
        r = Double((hexValue & 0xFF0000) >> 16) / 255.0
        g = Double((hexValue & 0x00FF00) >> 8) / 255.0
        b = Double(hexValue & 0x0000FF) / 255.0
        a = 1.0
      case 8:  // #RRGGBBAA
        r = Double((hexValue & 0xFF00_0000) >> 24) / 255.0
        g = Double((hexValue & 0x00FF_0000) >> 16) / 255.0
        b = Double((hexValue & 0x0000_FF00) >> 8) / 255.0
        a = Double(hexValue & 0x0000_00FF) / 255.0
      default:
        return nil  // Invalid hex string length
      }

      self.init(red: r, green: g, blue: b, opacity: a)
      return
    }

    // MARK: - 3. Try to parse named color constants
    switch cleanedString {
    case "red": self = .red
    case "green": self = .green
    case "blue": self = .blue
    case "white": self = .white
    case "black": self = .black
    case "gray", "grey": self = .gray
    case "orange": self = .orange
    case "yellow": self = .yellow
    case "pink": self = .pink
    case "purple": self = .purple
    case "clear": self = .clear
    case "primary": self = .primary  // SwiftUI system colors
    case "secondary": self = .secondary
    // Add more named colors as needed
    default:
      return nil  // Could not parse
    }
  }

  func darker(by percentage: CGFloat = 30) -> Color {
    adjust(brightnessDelta: -percentage / 100.0)
  }

  func lighter(by percentage: CGFloat = 30) -> Color {
    adjust(brightnessDelta: percentage / 100.0)
  }

  private func adjust(brightnessDelta: CGFloat) -> Color {
    #if canImport(UIKit)
      var uiColor = UIColor(self)
      var hue: CGFloat = 0
      var saturation: CGFloat = 0
      var brightness: CGFloat = 0
      var alpha: CGFloat = 0

      if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
        brightness = min(max(brightness + brightnessDelta, 0), 1)
        uiColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        return Color(uiColor)
      }

    #elseif canImport(AppKit)
      var nsColor = NSColor(self)
      var hue: CGFloat = 0
      var saturation: CGFloat = 0
      var brightness: CGFloat = 0
      var alpha: CGFloat = 0

      if nsColor.usingColorSpace(.deviceRGB)?.getHue(
        &hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) ?? false
      {
        brightness = min(max(brightness + brightnessDelta, 0), 1)
        nsColor = NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        return Color(nsColor)
      }
    #endif

    return self
  }
}
