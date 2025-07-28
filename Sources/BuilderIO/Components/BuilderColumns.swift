import Foundation
import SwiftUI

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

    self.columns = []

    if let columnsAnyCodableArray = block.component?.options?
      .dictionaryValue?["columns"]?
      .arrayValue
    {

      let decoder = JSONDecoder()
      var decodedColumns: [BuilderContentData] = []

      // Iterate through each AnyCodable element in the array
      for anyCodableElement in columnsAnyCodableArray {
        do {
          // Convert the AnyCodable element back into Data
          // (This is necessary because JSONDecoder works with Data)
          let elementData = try JSONEncoder().encode(anyCodableElement)

          // Decode that Data into a BuilderContentData instance
          var column = try decoder.decode(BuilderContentData.self, from: elementData)
          decodedColumns.append(column)
        } catch {
          // Handle error for a specific element if it can't be decoded
          print("Error decoding individual BuilderContentData from AnyCodable element: \(error)")
          // You might choose to append a default empty BuilderContentData,
          // or simply skip this element, as we are doing here.
        }
      }

      if let stateBoundObjectModel = block.stateBoundObjectModel {
        for columnIndex in decodedColumns.indices {
          for blockIndex in decodedColumns[columnIndex].blocks.indices {
            decodedColumns[columnIndex].blocks[blockIndex]
              .propagateStateBoundObjectModel(
                stateBoundObjectModel, stateRepeatCollectionKey: block.stateRepeatCollectionKey)
          }
        }
      }

      self.columns = decodedColumns

    } else {
      print("Could not find or access 'columns' array in component options.")
    }

    self.space = block.component?.options?.dictionaryValue?["space"]?.doubleValue ?? 0
    self.stackColumns =
      !((block.component?.options?.dictionaryValue?["stackColumnsAt"]?.stringValue == "never")
      ?? false)
    self.reverseColumnsWhenStacked =
      block.component?.options?.dictionaryValue?["reverseColumnsWhenStacked"]?.boolValue ?? false

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
          }
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
