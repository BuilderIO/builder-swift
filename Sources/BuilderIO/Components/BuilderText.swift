import SwiftUI

@MainActor
struct BuilderText: BuilderViewProtocol {
  var block: BuilderBlockModel

  static let componentType: BuilderComponentType = .text

  var responsiveStyles: [String: String]?
  var text: String?

  init(block: BuilderBlockModel) {
    self.block = block
    self.text = block.component?.options?.dictionaryValue?["text"]?.stringValue ?? ""
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
          let nsAttributedString = try NSAttributedString(
            data: data,
            options: [
              .documentType: NSAttributedString.DocumentType.html,
              .characterEncoding: String.Encoding.utf8.rawValue,
            ],
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

struct BuilderText_Previews: PreviewProvider {
  static let builderJSONString = """
    {
             "@type": "@builder.io/sdk:Element",
             "@version": 2,
             "id": "builder-54d67576377d4a9293c6f8d2efcda0ef",
             "meta": {
               "previousId": "builder-ad756879bc6c4ee3ac7977d5af0b6811"
             },
             "component": {
               "name": "Text",
              "options": {
                "text": "<h1><strong>Right<em> </em></strong><em>Align</em><strong><em> </em></strong><strong style=\\\"color: rgb(144, 19, 254);\\\"><em><u>Text</u></em></strong></h1><p> This is a paragraph with some content that will determine the height dynamically. This text should wrap to multiple lines if the width is constrained.</p>"
              },
               "isRSC": null
             },
             "responsiveStyles": {
               "large": {
                 "display": "flex",
                 "flexDirection": "column",
                 "position": "relative",
                 "flexShrink": "0",
                 "boxSizing": "border-box",
                 "marginTop": "20px",
                 "lineHeight": "normal",
                 "height": "auto",
                 "marginLeft": "auto",
                 "paddingLeft": "20px",
                 "marginRight": "20px"
               },
               "medium": {
                 "display": "none"
               },
               "small": {
                 "borderWidth": "2px",
                 "borderStyle": "solid",
                 "borderColor": "rgba(219, 20, 20, 1)",
                 "backgroundColor": "rgba(80, 227, 194, 1)",
                 "backgroundRepeat": "no-repeat",
                 "backgroundPosition": "center",
                 "backgroundSize": "cover",
                 "display": "flex",
                 "fontSize": "12px",
                 "fontWeight": "600",
                 "fontFamily": "Aldrich, sans-serif"
               }
             }
           }
    """

  static func decodeBuilderBlockModel(from jsonString: String) -> BuilderBlockModel? {
    let data = Data(jsonString.utf8)
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(BuilderBlockModel.self, from: data)
    } catch {
      print("Decoding failed:", error)
      return nil
    }
  }

  static var previews: some View {
    if let block = decodeBuilderBlockModel(from: builderJSONString) {
      BuilderText(block: block)
    } else {
      Text("Failed to decode block")
    }
  }
}
