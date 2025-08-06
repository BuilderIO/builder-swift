import Foundation
import Network
import Observation  // Import the Observation framework

/// A view model for fetching and managing Builder.io content.
///
/// Uses the new iOS 17 @Observable macro for simplified state management.
@Observable
@MainActor
public final class BuilderIOViewModel {
  public var builderContent: BuilderContent?
  public var isLoading: Bool = false
  public var errorMessage: String?
  public var stateModel: StateModel = StateModel()

  public var isNetworkAvailable: Bool = false
  private let networkMonitor = NWPathMonitor()
  private let networkQueue = DispatchQueue(label: "NetworkMonitorQueue")

  /// Initializes the BuilderIOViewModel.
  public init() {
    startNetworkMonitoring()
  }

  private func startNetworkMonitoring() {
    networkMonitor.pathUpdateHandler = { [weak self] path in
      Task { @MainActor in  // Ensure UI updates are on the main actor
        self?.isNetworkAvailable = path.status == .satisfied
        if !self!.isNetworkAvailable {
          print("Network is not available.")
          // Optionally set an error message or notify the user
        } else {
          print("Network is available.")
        }
      }
    }
    networkMonitor.start(queue: networkQueue)
  }

  /// Stops network monitoring when the ViewModel is deinitialized.
  deinit {
    networkMonitor.cancel()
  }

  /// Fetches the Builder.io page content for a given URL.
  /// Manages loading, content, and error states.
  public func fetchBuilderContent(model: String = "page", url: String = "", locale: String) async {
    // Set loading state immediately
    isLoading = true
    errorMessage = nil  // Clear any previous error
    builderContent = nil  // Clear previous content while loading new

    guard isNetworkAvailable else {
      errorMessage = "Network is not available. Please check your connection."
      isLoading = false
      return
    }

    do {
      // Await the content fetching
      let result = await BuilderIOManager.shared.fetchBuilderContent(
        model: model, url: url, locale: locale)
      switch result {
      case .success(let fetchedContent):
        if let httpRequests = fetchedContent.data.httpRequests {
          self.stateModel.apiResponses = try await fetchParallelAPIData(
            urls: httpRequests, locale: locale)
        }

        if self.stateModel.apiResponses.isEmpty {
          var newContentBlocks = fetchedContent.data.blocks ?? []
          for i in 0..<newContentBlocks.count {
            newContentBlocks[i].setLocaleRecursively(locale)
          }

          self.builderContent = fetchedContent

          self.builderContent?.data.blocks = newContentBlocks
        } else {
          // Further logic for content binding/loops can go here if needed.
          var contentBlocks = fetchedContent.data.blocks ?? []
          //First expand model to cover repeatable data.
          var newContentBlocks: [BuilderBlockModel] = []

          for contentBlock in contentBlocks {
            if let repeatModel = contentBlock.repeat,
              let collectionName = repeatModel["collection"] as? String
            {
              if let collectionModel = self.stateModel.getCollectionFromStateData(
                keyString: collectionName),
                collectionModel.count > 0
              {
                for i in 0..<collectionModel.count {
                  var newContentModel = contentBlock
                  newContentModel.propagateStateBoundObjectModel(
                    self.stateModel,
                    stateRepeatCollectionKey: StateRepeatCollectionKey(
                      index: i, collection: collectionName))

                  newContentModel.id = UUID().uuidString
                  newContentBlocks.append(newContentModel)
                }
              } else {
                newContentBlocks.append(contentBlock)
              }

            } else {
              var newContentModel = contentBlock
              newContentModel.propagateStateBoundObjectModel(self.stateModel)
              newContentBlocks.append(newContentModel)
            }

          }

          self.builderContent = fetchedContent

          for i in 0..<newContentBlocks.count {
            newContentBlocks[i].setLocaleRecursively(locale)
          }

          self.builderContent?.data.blocks = newContentBlocks
        }

      case .failure(_):
        self.errorMessage = "Failed to load content. Please check the URL or API key."
      }
    } catch {
      // Handle any errors during the async operation
      self.errorMessage = "Error fetching Builder.io content: \(error.localizedDescription)"
    }

    // Always set loading to false when the operation completes (success or failure)
    isLoading = false
  }

  func replaceLocalePlaceholder(in string: String, with locale: String) -> String {
    let placeholder = "&locale={{state.locale}}"
    if string.contains(placeholder) {
      return string.replacingOccurrences(of: placeholder, with: "&locale=\(locale)")
    } else {
      return string
    }
  }

  /// Sends a tracking pixel to Builder.io.
  public func sendTrackingPixel() {
    BuilderIOManager.shared.sendTrackingPixel()
  }

  public func fetchParallelAPIData(urls: [String: String], locale: String) async -> [String:
    AnyCodable]
  {
    isLoading = true
    errorMessage = nil  // Clear any previous error

    // 1. Check network availability
    guard isNetworkAvailable else {
      errorMessage = "Network is not available. Cannot fetch parallel API data."
      isLoading = false
      return [:]
    }

    var mergedResults: [String: AnyCodable] = [:]

    // Use withTaskGroup for concurrent execution and collection of results
    // The Task will now return (originalKey, apiResult)
    await withTaskGroup(of: (String, AnyCodable?).self) { [weak self] group in
      for (key, urlString) in urls {  // Iterate over key-value pairs
        group.addTask {
          do {
            if let self = self {
              let apiResult = try await BuilderContentAPI.getDataFromBoundAPI(
                url: self.replaceLocalePlaceholder(in: urlString, with: locale))
              // Return the original key along with the API result
              return (key, apiResult)
            } else {
              return (key, nil)
            }
          } catch {
            print(
              "Error fetching data from \(urlString) for key \(key): \(error.localizedDescription)")
            // Return the original key even if the call failed
            return (key, nil)
          }
        }
      }

      // Collect results as they complete
      for await (originalKey, apiResult) in group {  // Await the (key, result) tuple
        if let resultDict = apiResult {

          mergedResults[originalKey] = resultDict

        }
      }
    }

    isLoading = false
    return mergedResults  // Return the merged dictionary
  }

}
