
import Foundation
import SwiftUI

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
            }
        } else {
            return Color.white
        }
        return Color.white
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
    
    static func getFloatValue(cssString: String?) -> CGFloat {
        if (cssString == nil) {
            return CGFloat(0)
        }
        if let regex = try? NSRegularExpression(pattern: "px$") { // TODO: handle decimals
            let newString = regex.stringByReplacingMatches(in: cssString ?? "", options: .withTransparentBounds, range: NSMakeRange(0, (cssString ?? "").count ), withTemplate: "")
            
            if let number = NumberFormatter().number(from: newString) {
                let float = CGFloat(truncating: number)
                return float
            }
            
        }
        
        return CGFloat(0)
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
