import SwiftUI

@MainActor
struct BuilderText: BuilderViewProtocol {
  var block: BuilderBlockModel

  static let componentType: BuilderComponentType = .text

  var responsiveStyles: [String: String]?
  var text: String?

  init(block: BuilderBlockModel) {
    self.block = block
    var processedText: String = ""
    if let textValue = block.component?.options?.dictionaryValue?["text"] {
      self.text = localize(localizedValue: textValue) ?? ""
    }

    self.responsiveStyles = getFinalStyle(responsiveStyles: block.responsiveStyles)

    if let textBinding = block.codeBindings(for: "text") {
      self.text = textBinding.stringValue
    }
  }

  var body: some View {
    HTMLTextView(
      html: text ?? "", htmlPlainText: getTextWithoutHtml(text ?? ""),
      responsiveStyles: responsiveStyles
    )
  }

  func getTextWithoutHtml(_ text: String) -> String {
    if let regex = try? NSRegularExpression(pattern: "<.*?>") {  // TODO: handle decimals
      let newString = regex.stringByReplacingMatches(
        in: text, options: .withTransparentBounds, range: NSMakeRange(0, text.count),
        withTemplate: "")

      return newString
    }

    return ""
  }

}

@MainActor
struct HTMLTextView: View {
  let html: String
  @State private var attributedString: AttributedString? = nil
  @State private var errorInProcessing: Bool?
  @State private var hasProcessed = false

  let htmlPlainText: String
  var responsiveStyles: [String: String]?

  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    Group {
      if let attributedString = attributedString {

        Text(attributedString).multilineTextAlignment(
          CSSAlignments.textAlignment(responsiveStyles: responsiveStyles ?? [:])
        )
        .padding(.bottom, -24)
      } else if let errorInProcessing = errorInProcessing {
        Text(htmlPlainText)
      } else {
        ProgressView("")
      }
    }.task {
      guard !hasProcessed else { return }
      hasProcessed = true

      let wrappedHTML = wrapHtmlWithStyledDiv(
        styleDictionary: responsiveStyles ?? [:],
        htmlString: html ?? "",
        colorScheme: colorScheme)

      await processHTMLInBackground(wrappedHTML: wrappedHTML)

    }.onChange(of: colorScheme) { oldScheme, newScheme in

      let wrappedHTML = wrapHtmlWithStyledDiv(
        styleDictionary: responsiveStyles ?? [:],
        htmlString: html ?? "",
        colorScheme: colorScheme)

      Task {
        await processHTMLInBackground(wrappedHTML: wrappedHTML)
      }
    }

  }

  private func processHTMLInBackground(wrappedHTML: String) async {
    attributedString = nil  // Clear current state on MainActor
    errorInProcessing = nil  // Clear current state on MainActor

    do {
      // Prepare data on a background thread if it's a heavy operation (e.g., large string)
      let data = try await Task.detached(priority: .userInitiated) {
        guard let data = wrappedHTML.data(using: .utf8) else {
          throw HTMLProcessingError.dataConversionFailed
        }
        return data
      }.value

      // Perform the NSAttributedString conversion on the MainActor
      await MainActor.run {
        do {

          var attributedOptions: [NSAttributedString.DocumentReadingOptionKey: Any] = [:]

          if #available(iOS 18.0, *) {
            attributedOptions = [
              .documentType: NSAttributedString.DocumentType.html,
              .characterEncoding: String.Encoding.utf8.rawValue,
              .textKit1ListMarkerFormatDocumentOption: true,
            ]
          } else {
            attributedOptions = [
              .documentType: NSAttributedString.DocumentType.html,
              .characterEncoding: String.Encoding.utf8.rawValue,
            ]
          }

          let nsAttributedString = try NSAttributedString(
            data: data,
            options: attributedOptions,
            documentAttributes: nil
          )

          guard
            let swiftUIAttributedString = try? AttributedString(
              nsAttributedString, including: \.uiKit)
          else {
            throw HTMLProcessingError.attributedStringConversionFailed
          }

          self.attributedString = swiftUIAttributedString
          self.errorInProcessing = nil  // Clear error if successful
        } catch {
          print("HTML Processing Error (MainActor): \(error.localizedDescription)")
          self.errorInProcessing = true
          self.attributedString = nil  // Ensure attributedString is nil on error
        }
      }
    } catch {
      print("HTML Processing Error: \(error.localizedDescription)")
      self.errorInProcessing = true
      self.attributedString = nil
    }
  }

  // Define a custom error for clarity
  enum HTMLProcessingError: Error, LocalizedError {
    case dataConversionFailed
    case attributedStringConversionFailed
    var errorDescription: String? {
      switch self {
      case .dataConversionFailed: return "Failed to convert HTML string to data."
      case .attributedStringConversionFailed:
        return "Failed to convert NSAttributedString to AttributedString."
      }
    }
  }

  func wrapHtmlWithStyledDiv(
    styleDictionary: [String: String], htmlString: String, colorScheme: ColorScheme
  ) -> String {

    var addDefaultFontSize = true
    var addDefaultColor = true

    // 1. Convert the dictionary to a CSS style string
    var cssProperties: [String] = []

    for (key, value) in styleDictionary {
      var cssValue = value
      // Convert Swift-style/camelCase keys to CSS-style (kebab-case) keys
      let cssKey: String
      switch key {
      case "fontFamily":
        cssKey = "font-family"
      case "fontSize":
        cssKey = "font-size"
        addDefaultFontSize = false
      case "fontWeight":
        cssKey = "font-weight"
      case "color":
        cssKey = "color"
        addDefaultColor = false
      default:
        continue
      }
      cssProperties.append("\(cssKey): \(cssValue);")
    }

    if addDefaultFontSize {
      cssProperties.append("font-size: 16px;")
    }

    if addDefaultColor {
      let defaultTextColor: String
      if colorScheme == .dark {
        // For dark mode, default text is usually light
        defaultTextColor = "#FFFFFF"  // White
      } else {
        // For light mode, default text is usually dark
        defaultTextColor = "#000000"  // Black
      }
      cssProperties.append("color: \(defaultTextColor);")
    }

    let inlineCssStyle = cssProperties.joined(separator: " ")
    //extra trailing p tags

    var finalHtmlString: String

    if wrappedInTags(htmlString) {
      finalHtmlString = "<div style=\"\(inlineCssStyle)\">\(htmlString)</div><p></p>"
    } else {
      finalHtmlString = "<div style=\"\(inlineCssStyle)\"><p>\(htmlString)</p></div><p></p>"
    }

    return finalHtmlString
  }

  func wrappedInTags(_ text: String) -> Bool {

    let pattern = #"^\s*<[^>]+>.*<\/[^>]+>\s*$"#

    do {

      let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
      let range = NSRange(location: 0, length: text.utf16.count)

      return regex.firstMatch(in: text, options: [], range: range) != nil
    } catch {
      print("Error creating regex: \(error)")  // Log the error for debugging
      return false
    }
  }

}
