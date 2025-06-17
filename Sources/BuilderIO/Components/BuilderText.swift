import SwiftUI
import SwiftyJSON

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
      html: wrapHtmlWithStyledDiv(styleDictionary: responsiveStyles ?? [:], htmlString: text ?? ""))
  }

  func wrapHtmlWithStyledDiv(styleDictionary: [String: String], htmlString: String) -> String {

    guard !styleDictionary.isEmpty else {
      return htmlString
    }

    // 1. Convert the dictionary to a CSS style string
    var cssProperties: [String] = []
    for (key, value) in styleDictionary {
      // Convert Swift-style/camelCase keys to CSS-style (kebab-case) keys
      let cssKey: String
      switch key {
      case "fontFamily":
        cssKey = "font-family"
      case "fontSize":
        cssKey = "font-size"
      case "fontWeight":
        cssKey = "font-weight"
      case "color":
        cssKey = "color"
      case "lineHeight":
        cssKey = "line-height"
      default:
        continue
      }
      cssProperties.append("\(cssKey): \(value);")
    }

    let inlineCssStyle = cssProperties.joined(separator: " ")

    guard !inlineCssStyle.isEmpty else {
      return htmlString
    }

    let finalHtmlString = "<div style=\"\(inlineCssStyle)\">\(htmlString)</div>"

    return finalHtmlString
  }

}

struct HTMLTextView: View {
  let html: String

  var body: some View {
    Group {
      contentView
    }
  }

  @ViewBuilder
  private var contentView: some View {
    if let data = html.data(using: .utf8),
      let nsAttributedString = try? NSAttributedString(
        data: data,
        options: [
          .documentType: NSAttributedString.DocumentType.html,
          .characterEncoding: String.Encoding.utf8.rawValue,
        ],
        documentAttributes: nil
      ),
      let swiftUIAttributedString = try? AttributedString(nsAttributedString, including: \.uiKit)
    {

      Text(swiftUIAttributedString)

    } else {
      Text("Failed to render HTML")
        .foregroundColor(.red)
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
                "text": "<h1><strong>Right<em> </em></strong><em>Align</em><strong><em> </em></strong><strong style=\\\"color: rgb(144, 19, 254);\\\"><em><u>Text</u></em></strong></h1>"
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
