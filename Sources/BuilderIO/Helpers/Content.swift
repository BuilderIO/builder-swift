import Foundation

public struct Content {
    public static func getContent(model: String, apiKey: String, url: String, locale: String? = nil, preview: String? = nil, callback: @escaping ((BuilderContent?)->())) {
        let encodedUrl = String(describing: url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        var str = "https://cdn.builder.io/api/v3/content/\(model)"
        
        let overrideLocale = UserDefaults.standard.string(forKey: "builderLocale")
        let overridePreviewContent = UserDefaults.standard.string(forKey: "builderContentId")
        
        let useLocale = overrideLocale ?? locale
        let usePreview = overridePreviewContent ?? preview
        
        if let localPreview = usePreview, !localPreview.isEmpty {
            str += "/\(localPreview)"
        }
        str += "?apiKey=\(apiKey)&url=\(encodedUrl)"
        
        if let locale = useLocale, !locale.isEmpty {
            str += "&locale=\(locale)"
        }
        
        if let localPreview = usePreview, !localPreview.isEmpty {
            str += "&preview=true"
            str += "&cachebust=true"
            str += "&cachebuster=\(Float.random(in: 1..<10))"
        }
        
        let url = URL(string: str)!
        
        let session = !(usePreview ?? "").isEmpty ? URLSession(configuration: .ephemeral) : URLSession.shared
        
        let task = session.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                callback(nil)
                return
            }
            let decoder = JSONDecoder()
            let jsonString = String(data: data, encoding: .utf8)!
            do {
                if let localPreview = usePreview, !localPreview.isEmpty {
                    let content = try decoder.decode(BuilderContent.self, from: Data(jsonString.utf8))
                    callback(content)
                } else {
                    let content = try decoder.decode(BuilderContentList.self, from: Data(jsonString.utf8))
                    if content.results.count>0 {
                        callback(content.results[0])
                    }
                }
            } catch {
                print(error)
                callback(nil)
            }
        }
        
        task.resume()
    }
}
