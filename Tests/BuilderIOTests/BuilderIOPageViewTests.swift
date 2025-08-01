import BuilderIO
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@MainActor
class BuilderIOPageViewTests: XCTestCase {

  static let record = false

  override func setUpWithError() throws {
    BuilderIOManager.configure(apiKey: "UNITTESTINGAPIKEY", customNavigationScheme: "builderio")

    continueAfterFailure = false
  }

  override func tearDownWithError() throws {
    // Clear all mocks after each test
    print(" 🚨 Tests deregistered")

    BuilderIOMockManager.shared.clearAllMocks()
    try super.tearDownWithError()
  }

  func testTextView() throws {
    BuilderIOMockManager.shared.registerMock(for: "/text", with: "text", statusCode: 200)

    let hostingController = makeHostingController(for: "/text", width: 375, height: 812)

    let expectation = XCTestExpectation(description: "Wait for view to render")

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

      assertSnapshot(matching: hostingController, as: .image, record: BuilderIOPageViewTests.record)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 3)
  }

  func testLayoutsView() throws {
    BuilderIOMockManager.shared.registerMock(for: "/layout", with: "layout", statusCode: 200)

    let hostingController = makeHostingController(for: "/layout", width: 375, height: 812)

    let expectation = XCTestExpectation(description: "Wait for view to render")

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

      assertSnapshot(matching: hostingController, as: .image, record: BuilderIOPageViewTests.record)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 3)
  }

  /// - Returns: A UIHostingController wrapping the SwiftUI Text view.
  func makeHostingController(for url: String, width: CGFloat, height: CGFloat)
    -> UIHostingController<some View>
  {
    let view = BuilderIOPage(
      url: url,
      onClickEventHandler: { event in
        print("Handle Event Action")
      })

    let hostingController = UIHostingController(rootView: view.frame(width: 375, height: 812))
    hostingController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)

    let window = UIWindow(frame: hostingController.view.frame)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    return hostingController
  }
}
