import SwiftyJSON
import SwiftUI
import Foundation

public typealias BuilderBlockFactory = (JSON, [String: String]?) -> Any;
public var componentDict: [String:BuilderBlockFactory] = [:]


public func registerComponent(component: BuilderCustomComponent, factory: @escaping BuilderBlockFactory, apiKey: String?) {
    let name = component.name
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
    let sessionId = UserDefaults.standard.string(forKey: "builderSessionId");
    let sessionToken = UserDefaults.standard.string(forKey: "builderSessionToken");

    if (sessionId != nil && sessionToken != nil && apiKey != nil) {
        registerOnEditingSession(component: component, apiKey: apiKey!, sessionId: sessionId!, sessionToken: sessionToken!);
    }

}

func registerOnEditingSession(component: BuilderCustomComponent, apiKey: String, sessionId: String, sessionToken: String) {
    DispatchQueue.global().async {
        let overrideUrl = UserDefaults.standard.string(forKey: "builderRemoteUrl")
        let url = overrideUrl ?? "https://cdn.builder.io/api/v1/remote-sessions/\(sessionId)"

        var components = URLComponents(string: url)
        components?.queryItems = [URLQueryItem(name: "apiKey", value: apiKey), URLQueryItem(name: "sessionToken", value: sessionToken)]
        // Create the request object
        var request = URLRequest(url: components!.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(component)
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON data: \(error)")
            return
        }

        // Create a URLSession task and start it
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
}
