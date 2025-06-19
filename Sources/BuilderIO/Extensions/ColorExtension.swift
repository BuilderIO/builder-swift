import SwiftUI

extension Color {
  init?(rgbaString: String) {
    let scanner = Scanner(string: rgbaString)
    scanner.charactersToBeSkipped = CharacterSet(charactersIn: "rgba(), ")

    var r: Double = 0
    var g: Double = 0
    var b: Double = 0
    var a: Double = 1

    if scanner.scanDouble(&r),
      scanner.scanDouble(&g),
      scanner.scanDouble(&b),
      scanner.scanDouble(&a)
    {
      self.init(
        red: r / 255.0,
        green: g / 255.0,
        blue: b / 255.0,
        opacity: a
      )
    } else {
      return nil
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

      if nsColor.usingColorSpace(.deviceRGB)?
        .getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) ?? false
      {
        brightness = min(max(brightness + brightnessDelta, 0), 1)
        nsColor = NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        return Color(nsColor)
      }
    #endif

    return self
  }
}
