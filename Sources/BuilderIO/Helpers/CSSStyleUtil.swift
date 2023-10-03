
import Foundation
import SwiftUI

enum HorizontalAlignment {
    case FullWidth
    case Center
    case LeftAlign
    case RightAlign
}

@available(iOS 13.0, *)
struct FrameDimensions {
    var minWidth: CGFloat? = nil;
    var idealWidth: CGFloat? = nil;
    var maxWidth: CGFloat? = nil;
    var alignment: Alignment;
}

class CSSStyleUtil {
    /*
     Takes the responsive styles from Builder blocks response, and
     returns a styles dictionary that lets the small responsive style take
     precedence
     */
    static func getFinalStyle(responsiveStyles: BuilderBlockResponsiveStyles?) -> [String: String] {
        var finalStyle: [String:String] = [:]
        finalStyle = finalStyle.merging(responsiveStyles?.large ?? [:]) { (_, new) in new }
        finalStyle = finalStyle.merging(responsiveStyles?.medium ?? [:]) { (_, new) in new }
        finalStyle = finalStyle.merging(responsiveStyles?.small ?? [:]) { (_, new) in new }
        
        return finalStyle;
    }
    
    @available(iOS 13.0, *)
    static func getColor(value: String?) -> Color {
        if value != nil {
            if value == "red" {
                return Color.red
            } else if value == "blue" {
                return Color.blue
            } else if value == "white" {
                return Color.white
            } else if value == "gray" {
                return Color.gray
            } else if value == "black" {
                return Color.black
            }
            
            let allMatches = matchingStrings(string: value!, regex: "rgba\\((\\d+),\\s*(\\d+),\\s*(\\d+),\\s*(\\d+)\\)");
            if allMatches.count>0 {
                let matches = allMatches[0]
                
                if (matches.count > 3) {
                    return Color(red: Double(matches[1])! / 255, green: Double(matches[2])! / 255, blue: Double(matches[3])! / 255, opacity: Double(matches[4])!)
                }
            } else {
                if value?.hasPrefix("var") == true {
                    return hexStringToUIColor(hex: extractHexValueFromVarString(from: value ?? "#fff") ?? "#fff")
                }
                if value?.hasPrefix("#") == true {
                    return hexStringToUIColor(hex: value ?? "#fff")
                }
            }
        } else {
            return Color.white
        }
        return Color.white
    }
    
    static func extractHexValueFromVarString(from input: String) -> String? {
        let pattern = "#([0-9A-Fa-f]{6})" // Regular expression pattern to match hex color code
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(input.startIndex..<input.endIndex, in: input)
        
        if let match = regex.firstMatch(in: input, options: [], range: range) {
            let hexRange = Range(match.range(at: 1), in: input)
            if let hexValue = hexRange.map({ String(input[$0]) }) {
                return hexValue
            }
        }
        
        return nil
    }
    
    @available(iOS 13.0, *)
    static func hexStringToUIColor (hex:String) -> Color {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count == 3) {
            let r = cString[cString.index(cString.startIndex, offsetBy: 2)]
            let g = cString[cString.index(cString.startIndex, offsetBy: 1)]
            let b = cString[cString.index(cString.startIndex, offsetBy: 0)]
            cString = String(repeating: r, count: 2) + String(repeating: g, count: 2) +
                String(repeating: b, count: 2)
        }

        if ((cString.count) != 6) {
            return Color.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return Color(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0
        )
        
    }
    
    static func matchingStrings(string: String, regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = string as NSString
        let results  = regex.matches(in: string, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
                : ""
            }
        }
    }
    
    static func getFloatValue(cssString: String?, defaultValue: CGFloat = CGFloat(0)) -> CGFloat {
        if (cssString == nil) {
            return defaultValue
        }
        if let regex = try? NSRegularExpression(pattern: "px$") { // TODO: handle decimals
            let newString = regex.stringByReplacingMatches(in: cssString ?? "", options: .withTransparentBounds, range: NSMakeRange(0, (cssString ?? "").count ), withTemplate: "")
            
            if let number = NumberFormatter().number(from: newString) {
                let float = CGFloat(truncating: number)
                return float
            }
            
        }
        
        return defaultValue
    }
    
    @available(iOS 13.0, *)
    static func getBoxStyle(boxStyleProperty: String, finalStyles: [String: String]) -> EdgeInsets {
        if finalStyles[boxStyleProperty] != nil {
            
            // Check if single value, or 2 values or 4 values.
            // For now, assume single value and move on
            let value = getFloatValue(cssString: finalStyles[boxStyleProperty])
            return EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
        } else {
            let directions = ["Top", "Left", "Bottom", "Right"];
            for direction in directions {
                if finalStyles[boxStyleProperty + direction] != nil {
                    return EdgeInsets(top: getFloatValue(cssString: finalStyles[boxStyleProperty + "Top"]),
                                      leading: getFloatValue(cssString: finalStyles[boxStyleProperty + "Left"]),
                                      bottom: getFloatValue(cssString: finalStyles[boxStyleProperty + "Bottom"]),
                                      trailing: getFloatValue(cssString: finalStyles[boxStyleProperty + "Right"]))
                }
            }
        }
        return EdgeInsets()
        
    }
    
    static func getTextWithoutHtml(_ text: String) -> String {
        if let regex = try? NSRegularExpression(pattern: "<.*?>") { // TODO: handle decimals
            let newString = regex.stringByReplacingMatches(in: text, options: .withTransparentBounds, range: NSMakeRange(0, text.count ), withTemplate: "")
            
            return newString
        }
        
        return ""
    }
    
    static func getHorizontalAlignmentFromMargin(styles: [String: String]) -> HorizontalAlignment {
        let marginLeft = styles["marginLeft"]
        let marginRight = styles["marginRight"]
        
        let isMarginLeftAbsentOrZero = marginLeft == nil || getFloatValue(cssString: marginLeft) == CGFloat(0);
        let isMarginRightAbsentOrZero = marginRight == nil || getFloatValue(cssString: marginRight) == CGFloat(0);
        let isMarginLeftAuto = marginLeft?.lowercased() == "auto";
        let isMarginRightAuto = marginRight?.lowercased() == "auto";
        
        if (isMarginLeftAuto && isMarginRightAuto) {
            return HorizontalAlignment.Center;
        } else if (isMarginLeftAuto) {
            return HorizontalAlignment.RightAlign;
        } else if (isMarginRightAuto) {
            return HorizontalAlignment.LeftAlign;
        } else if (isMarginLeftAbsentOrZero && isMarginRightAbsentOrZero) {
            return HorizontalAlignment.FullWidth;
        } 
        // Default full width?
        return HorizontalAlignment.FullWidth;
    }
    
    static func getHorizontalAlignmentFromAlignSelf(styles: [String: String]) -> HorizontalAlignment {
        let alignSelf = styles["alignSelf"];
        if (alignSelf == "center") {
            return HorizontalAlignment.FullWidth;
        } else if (alignSelf == "auto" || alignSelf == "stretch") {
            return HorizontalAlignment.FullWidth;
        }
        return HorizontalAlignment.FullWidth;
    }
    
    static func getHorizontalAlignment(styles: [String: String]) -> HorizontalAlignment {
        if styles["alignSelf"] != nil {
            return getHorizontalAlignmentFromAlignSelf(styles: styles)
        } else {
            return getHorizontalAlignmentFromMargin(styles: styles)
        }
    }
    
    @available(iOS 13.0, *)
    static func getFrameFromHorizontalAlignment(styles: [String: String]) -> FrameDimensions {
        var horizontalAlignment : HorizontalAlignment;
        if (styles["alignSelf"] != nil) {
            horizontalAlignment = getHorizontalAlignmentFromAlignSelf(styles: styles)
        } else {
            horizontalAlignment = getHorizontalAlignmentFromMargin(styles: styles)
        }
        
        if (horizontalAlignment == HorizontalAlignment.FullWidth) {
            return FrameDimensions(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
            
        } else if (horizontalAlignment == HorizontalAlignment.Center) {
            return FrameDimensions(alignment: .center)
        } else if (horizontalAlignment == HorizontalAlignment.LeftAlign) {
            return FrameDimensions(alignment: .leading)
        } else {
            // Right align
            return FrameDimensions(alignment: .trailing)
        }
    }
    
    @available(iOS 13.0, *)
    static func getFontWeightFromNumber(value: CGFloat) -> Font.Weight {
        switch (value) {
        case _ where value <= 100:
            return Font.Weight.thin;
        case _ where value <= 200:
            return Font.Weight.ultraLight;
        case _ where value <= 300:
            return Font.Weight.light;
        case _ where value <= 400:
            return Font.Weight.regular;
        case _ where value <= 500:
            return Font.Weight.medium;
        case _ where value <= 600:
            return Font.Weight.semibold;
        case _ where value <= 700:
            return Font.Weight.bold;
        case _ where value <= 800:
            return Font.Weight.heavy;
        default:
            return Font.Weight.black;
        }
    }
    
}
