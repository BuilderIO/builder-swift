import Foundation
import SwiftUI
import SwiftyJSON

struct BuilderColumns: BuilderViewProtocol {
  var componentType: BuilderComponentType = .columns
  var block: BuilderBlockModel

  var columns: [BuilderContentData]
  var space: CGFloat = 0
  var responsiveStyles: [String: String]?

  init(block: BuilderBlockModel) {
    self.block = block

    if let jsonString = block.component?.options?["columns"].rawString(),
      let jsonData = jsonString.data(using: .utf8)
    {
      let decoder = JSONDecoder()
      do {
        self.columns = try decoder.decode([BuilderContentData].self, from: jsonData)
      } catch {
        self.columns = []
      }
    } else {
      self.columns = []
    }

    self.responsiveStyles = getFinalStyle(responsiveStyles: block.responsiveStyles)
    self.space = block.component?.options?["space"].doubleValue ?? 0
  }

  var body: some View {
    let hasBackground = responsiveStyles?["backgroundColor"] != nil
    let backgroundColor = CSSStyleUtil.getColor(value: responsiveStyles?["backgroundColor"])

    VStack(spacing: space) {
      ForEach(columns.indices, id: \.self) { index in
        BuilderModel(blocks: columns[index].blocks)
      }
    }
    .padding(
      CSSStyleUtil.getBoxStyle(boxStyleProperty: "padding", finalStyles: responsiveStyles ?? [:])
    )
    .background(hasBackground ? backgroundColor : nil)
    .padding(
      CSSStyleUtil.getBoxStyle(boxStyleProperty: "margin", finalStyles: responsiveStyles ?? [:]))
  }
}
