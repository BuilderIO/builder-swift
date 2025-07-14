import SwiftUICore

class CSSAlignments {

  static func textAlignment(responsiveStyles: [String: String]) -> TextAlignment {
    if let textAlign = responsiveStyles["textAlign"] {
      switch textAlign {
      case "center":
        return .center
      case "left", "start":  // "start" is also a common value in some contexts
        return .leading
      case "right", "end":  // "end" is also a common value
        return .trailing
      case "justify":
        break  // Fall through to next checks
      default:
        break  // Unknown textAlign value, fall through
      }
    }

    return .leading
  }

  static func horizontalAlignment(
    marginsLeft: String?, marginsRight: String?, justify: String?, alignItems: String?,
    alignSelf: String?,
    responsiveStyles: [String: String]
  ) -> HorizontalAlignment {

    if (marginsLeft == "auto" && marginsRight == "auto") || justify == "center"
      || alignItems == "center" || alignSelf == "center"
    {
      return .center
    } else if marginsRight == "auto" || justify == "flex-start" || alignItems == "flex-start" {
      return .leading
    } else if marginsLeft == "auto" || justify == "flex-end" || alignItems == "flex-end" {
      return .trailing
    }

    return textAlignment(responsiveStyles: responsiveStyles).toHorizontalAlignment
  }

  static func verticalAlignment(justify: String?, alignItems: String?, alignSelf: String?)
    -> VerticalAlignment
  {

    if justify == "center" || alignItems == "center" || alignSelf == "center" {
      return .center
    } else if justify == "flex-start" || alignItems == "flex-start" {
      return .top
    } else if justify == "flex-end" || alignItems == "flex-end" {
      return .bottom
    }
    return .center
  }

}

extension TextAlignment {
  var toHorizontalAlignment: HorizontalAlignment {
    switch self {
    case .leading:
      return .leading
    case .center:
      return .center
    case .trailing:
      return .trailing
    default:
      return .leading  // Or .center, choose what makes sense for your layout
    }
  }

  var toAlignment: Alignment {
    switch self {
    case .leading:
      return .leading
    case .center:
      return .center
    case .trailing:
      return .trailing
    default:
      return .leading  // Or .center, choose what makes sense for your layout
    }
  }

}
