enum CSSConstants {
  enum Display: String {
    case block, inline, flex, grid, none, inlineBlock
  }

  enum TextAlign: String {
    case left, right, center, justify, start, end
  }

  enum Align: String {
    case auto = "auto"
    case flexStart = "flex-start"
    case flexEnd = "flex-end"
    case center = "center"
    case baseline = "baseline"
    case stretch = "stretch"
    case spaceBetween = "space-between"
    case spaceAround = "space-around"
    case spaceEvenly = "space-evenly"
  }

  enum FlexDirection: String {
    case row
    case column
  }

  enum ResponsiveLayoutProperty: String {
    case position
    case display
    case lineHeight
    case width
    case height
    case maxWidth
    case maxHeight
    case minWidth
    case minHeight
    case flexDirection
    case marginTop
    case marginRight
    case marginBottom
    case marginLeft
    case paddingTop
    case paddingRight
    case paddingBottom
    case paddingLeft
  }

}
