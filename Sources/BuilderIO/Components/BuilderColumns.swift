import Foundation
import SwiftUI
import SwiftyJSON

struct BuilderColumns: BuilderViewProtocol {
  static let componentType: BuilderComponentType = .columns
  var block: BuilderBlockModel

  var columns: [BuilderContentData]
  var space: CGFloat = 0
  var responsiveStyles: [String: String]?
  var stackColumns: Bool = true
  var reverseColumnsWhenStacked: Bool = false

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

    self.space = block.component?.options?["space"].doubleValue ?? 0
    self.stackColumns = !(block.component?.options?["stackColumnsAt"] == "never" ?? false)
    self.reverseColumnsWhenStacked =
      block.component?.options?["reverseColumnsWhenStacked"].boolValue ?? false

  }

  var body: some View {
    if columns.isEmpty {
      EmptyView()
    } else {
      if stackColumns {
        let columnsForLayout = reverseColumnsWhenStacked ? columns.reversed() : columns
        VStack(spacing: space) {
          ForEach(columnsForLayout) { column in
            BuilderBlock(blocks: column.blocks, builderLayoutDirection: .vertical)
          }.border(.yellow)
        }
      } else {
        ScrollView(.horizontal) {
          HorizontalColumnLayout(columns: columns, space: space)
        }
        .scrollDisabled(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

      }
    }
  }
}

struct HorizontalColumnLayout: View {
  let columns: [BuilderContentData]
  var space: CGFloat = 0

  var body: some View {
    HStack(spacing: space) {
      // Add some spacing between columns
      ForEach(columns) { column in
        VStack {
          if column.blocks.isEmpty {
            EmptyView()
          } else {
            BuilderBlock(blocks: column.blocks)
          }
        }

        .containerRelativeFrame(.horizontal) { length, axis in
          if let columWidth = column.width, columWidth > 0 {

            let columdimension = (length * (columWidth / 100.0)) - (space / 2)
            return columdimension
          } else {
            return (length / CGFloat(columns.count)) - (space / 2)
          }
        }
      }
    }
  }
}
