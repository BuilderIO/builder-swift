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

    Text(CSSStyleUtil.getTextWithoutHtml(text ?? "")).responsiveStylesBuilderView(
      responsiveStyles: self.responsiveStyles ?? [:], isText: true)

  }

}

struct BuilderText_Previews: PreviewProvider {
  static let builderJSONString = """
    {
      "@type": "@builder.io/sdk:Element",
      "@version": 2,
      "id": "builder-ad756879bc6c4ee3ac7977d5af0b6811",
      "meta": {
        "previousId": "builder-e8da4929479a4abf9cd8e3959a1e6699"
      },
      "component": {
        "name": "Text",
        "options": {
          "text": "<h1>Left Align Text</h1>"
        }
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
          "marginRight": "auto",
          "paddingLeft": "20px",
          "paddingRight": "20px"
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
