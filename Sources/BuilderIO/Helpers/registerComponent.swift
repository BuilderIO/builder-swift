import SwiftyJSON
import SwiftUI

typealias BuilderBlockFactory = (JSON, [String: String]?) -> Any;
var componentDict: [String:BuilderBlockFactory] = [:]

func registerComponent(name: String, factory: @escaping BuilderBlockFactory) {
    func useFactory(options: JSON, styles: [String: String]?) -> Any {
        do {
            let value = try factory(options, styles)
            return value
        } catch {
            print("Could not instantiate \(name): \(error)")
            if #available(iOS 15.0, *) {
                return Text("Builder block \(name) could not load")
            } else {
                // Fallback on earlier versions
            }
        }
    }
    componentDict[name] = useFactory
}
