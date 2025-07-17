import Foundation
import SwiftUI
import UIKit

extension Font {
  public static func registerFonts() {
    _ = UIFont.registerFont(bundle: .module, fontName: "Lato-Regular", fontExtension: "ttf")
    _ = UIFont.registerFont(bundle: .module, fontName: "Poppins-Regular", fontExtension: "ttf")
    _ = UIFont.registerFont(bundle: .module, fontName: "Inter", fontExtension: "ttf")
    _ = UIFont.registerFont(bundle: .module, fontName: "Inter-Italic", fontExtension: "ttf")
    _ = UIFont.registerFont(bundle: .module, fontName: "SourceCodePro", fontExtension: "ttf")
    _ = UIFont.registerFont(bundle: .module, fontName: "SourceCodePro-Italic", fontExtension: "ttf")
    _ = UIFont.registerFont(bundle: .module, fontName: "Roboto", fontExtension: "ttf")
    _ = UIFont.registerFont(bundle: .module, fontName: "Roboto-Italic", fontExtension: "ttf")
    _ = UIFont.registerFont(bundle: .module, fontName: "OpenSans", fontExtension: "ttf")
    _ = UIFont.registerFont(bundle: .module, fontName: "OpenSans-Italic", fontExtension: "ttf")
  }
  
}

extension UIFont {
  
  static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) -> Bool {
    guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
      fatalError("Couldn't find font \(fontName)")
    }
    guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
      fatalError("Couldn't load data from the font \(fontName)")
    }
    guard let font = CGFont(fontDataProvider) else {
      fatalError("Couldn't create font from data")
    }
    var error: Unmanaged<CFError>?
    return CTFontManagerRegisterGraphicsFont(font, &error)
  }
}
