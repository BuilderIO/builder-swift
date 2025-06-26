import SwiftUI

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
    HTMLTextView(
      html: wrapHtmlWithStyledDiv(styleDictionary: responsiveStyles ?? [:], htmlString: text ?? ""),
      htmlPlainText: getTextWithoutHtml(text ?? "")
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

  func wrapHtmlWithStyledDiv(styleDictionary: [String: String], htmlString: String) -> String {

    guard !styleDictionary.isEmpty else {
      return htmlString
    }
    var addDefaultFontSize = true
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
      case "lineHeight":
        cssKey = "line-height"
      case "textAlign":
        cssKey = "text-align"
      case "fontStyle":
        cssKey = "font-style"
      default:
        continue
      }
      cssProperties.append("\(cssKey): \(cssValue);")
    }

    if addDefaultFontSize {
      cssProperties.append("font-size: 16px;")
    }

    cssProperties.append("margin: 0; padding: 0;")
    cssProperties.append("display: block;")
    cssProperties.append("box-sizing: border-box;")

    let inlineCssStyle = cssProperties.joined(separator: " ")

    guard !inlineCssStyle.isEmpty else {
      return htmlString
    }

    //extra trailing p tags
    let finalHtmlString = "<div style=\"\(inlineCssStyle)\">\(htmlString)</div><p></p>"

    return finalHtmlString
  }

}

struct HTMLTextView: View {
  let html: String
  @State private var attributedString: AttributedString? = nil
  @State private var errorInProcessing: Bool?

  let htmlPlainText: String

  var body: some View {
    Group {
      if let attributedString = attributedString {
        Text(attributedString)
          .padding(.bottom, -24)
      } else if let errorInProcessing = errorInProcessing {
        Text(htmlPlainText)
      } else {
        ProgressView("")
      }
    }
    .task(id: html) {
      processHTML()
    }
  }

  private func processHTML() {
    attributedString = nil  // Clear previous attributed string
    errorInProcessing = nil
    guard let data = html.data(using: .utf8) else {
      return
    }

    do {
      let nsAttributedString = try NSAttributedString(
        data: data,
        options: [
          .documentType: NSAttributedString.DocumentType.html,
          .characterEncoding: String.Encoding.utf8.rawValue,
        ],
        documentAttributes: nil
      )
      // Perform this conversion on a background thread if it's very large
      // or if there are many HTMLTextViews.
      if let swiftUIAttributedString = try? AttributedString(nsAttributedString, including: \.uiKit)
      {
        self.attributedString = swiftUIAttributedString
      } else {
        errorInProcessing = true
      }
    } catch {
      errorInProcessing = true
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
