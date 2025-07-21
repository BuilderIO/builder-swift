import Foundation
import Mocker
import XCTest  // Import XCTest if this class is part of your test bundle

class BuilderIOMockManager {

  static let shared = BuilderIOMockManager()

  // MARK: - Properties
  private let baseURLString =
    "https://cdn.builder.io/api/v3/content/page?apiKey=e084484c0e0241579f01abba29d9be10"
  let mockedURLSession: URLSession  // Public so your API service can use it

  // MARK: - Initialization
  private init() {  // Private initializer to ensure only one instance is created
    // Configure URLSession to use Mocker's URLProtocol
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    self.mockedURLSession = URLSession(configuration: configuration)
    registerImageMock();
  }

  /// Loads a JSON file from the test bundle and returns it as Data.
  ///
  /// - Parameters:
  ///   - fileName: The name of the JSON file (e.g., "text").
  /// - Returns: Data containing the JSON, or nil if the file is not found or cannot be loaded.
  private func loadJSONData(from fileName: String) -> Data? {
    guard let url = Bundle.module.url(forResource: fileName, withExtension: "json") else {
      XCTFail("Missing JSON file: \(fileName).json in Tests/BuilderIO/Responses")
      return nil
    }
    do {
      let data = try Data(contentsOf: url)
      return data
    } catch {
      XCTFail("Failed to load data from \(fileName).json: \(error)")
      return nil
    }
  }

  private func loadImageData(from imageName: String, withExtension fileExtension: String) -> Data? {
    guard
      let url = Bundle.module.url(
        forResource: imageName, withExtension: fileExtension)
    else {
      XCTFail(
        "❌ Missing image file: \(imageName).\(fileExtension) in 'builderio/images' subdirectory. Check path and Package.swift."
      )
      return nil
    }
    do {
      let data = try Data(contentsOf: url)
      // Optional: Verify it's a valid image (for debugging)
      if UIImage(data: data) == nil {
        XCTFail("❌ Data loaded from \(imageName).\(fileExtension) is not a valid image.")
      }
      print("✅ Successfully loaded image data from: \(url.lastPathComponent)")
      return data
    } catch {
      XCTFail(
        "❌ Failed to load image data from \(imageName).\(fileExtension): \(error.localizedDescription)"
      )
      return nil
    }
  }

  /// Registers a mock for a specific Builder.io API URL with a local JSON response.
  ///
  /// - Parameters:
  ///   - endpoint: The specific endpoint path (e.g., "/text").
  ///   - jsonFileName: The name of the JSON file (without extension) in Tests/BuilderIO/Responses.
  ///   - statusCode: The HTTP status code to return (default is 200).
  func registerMock(for endpoint: String, with jsonFileName: String, statusCode: Int = 200) {
    guard let responseData = loadJSONData(from: jsonFileName) else {
      XCTFail("Failed to read file: \(jsonFileName)")

      return  // loadJSONData will already have failed the test if file is missing
    }

    guard let url = URL(string: "\(baseURLString)&url=\(endpoint)") else {
      XCTFail("Invalid URL constructed for endpoint: \(endpoint)")
      return
    }

    let mock = Mock(
      url: url,
      dataType: .json,
      statusCode: statusCode,
      data: [.get: responseData]
    )

    print("✅ Mock registered successfully for endpoint: \(url) using data")

    mock.register()
  }

  let images: [[String: String]] = [
    [
      "name": "grocery",
      "url":
        "https://nuevokart.com/wp-content/uploads/2022/11/groceries-packages-delivery-covid-19-quarantine-shopping-concept-courier-with-food-package-bring-goods-client-house-contactless-delivery-during-coronavirus-wear-face-mask-gloves-1024x683.jpg",
      "extension": "png",
    ],
    [
      "name": "designer",
      "url":
        "https://cdn.builder.io/api/v1/image/assets%2FagZ9n5CUKRfbL9t6CaJOyVSK4Es2%2F8e096f01b00343dca3952d645f7ae024?width=998&height=1000",
      "extension": "jpg",
    ],
    [
      "name": "designer2",
      "url":
        "https://cdn.builder.io/api/v1/image/assets%2FagZ9n5CUKRfbL9t6CaJOyVSK4Es2%2F70c33c597e9946e9a79ab99ad9a999d3?width=998&height=1000",
      "extension": "jpg",
    ],
    [
      "name": "furniture",
      "url":
        "https://www.freepnglogos.com/uploads/furniture-png/furniture-png-transparent-furniture-images-pluspng-15.png",
      "extension": "png",
    ],
    [
      "name": "laptop",
      "url":
        "https://pngimg.com/uploads/macbook/small/macbook_PNG65.png",
      "extension": "png",
    ]
  ]

  func registerImageMock(statusCode: Int = 200) {

    for image in images {

      guard
        let responseData = loadImageData(from: image["name"]!, withExtension: image["extension"]!)
      else {
        return  // loadImageData will already have failed the test if file is missing
      }

      guard let urlString = image["url"], let url = URL(string: urlString) else {
        XCTFail("Invalid URL string for image mock: \(String(describing: image["url"]))")
        return
      }

      let mock = Mock(
        url: url,
        ignoreQuery: true,
        dataType: .imagePNG,  // Specify IMAGE data type
        statusCode: statusCode,
        data: [.get: responseData]
      )
      mock.register()
    }

  }

  /// Clears all registered mocks. Call this in your `tearDown` method.
  func clearAllMocks() {
    Mocker.removeAll()
  }
}
