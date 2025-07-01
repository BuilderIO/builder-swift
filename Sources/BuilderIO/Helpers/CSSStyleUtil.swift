import Foundation

class CSSStyleUtil {
  /*
   Takes the responsive styles from Builder blocks response, and
   returns a styles dictionary that lets the small responsive style take
   precedence
   */
  static func getFinalStyle(responsiveStyles: BuilderBlockResponsiveStyles?) -> [String: String] {
    var finalStyle: [String: String] = [:]
    finalStyle = finalStyle.merging(responsiveStyles?.large ?? [:]) { (_, new) in new }
    finalStyle = finalStyle.merging(responsiveStyles?.medium ?? [:]) { (_, new) in new }
    finalStyle = finalStyle.merging(responsiveStyles?.small ?? [:]) { (_, new) in new }

    return finalStyle
  }
}
