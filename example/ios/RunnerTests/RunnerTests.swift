import Flutter
import UIKit
import XCTest


@testable import flutter_contact_index

class RunnerTests: XCTestCase {
  func testPluginClassIsAvailable() {
    let pluginType: AnyClass = FlutterContactIndexPlugin.self
    XCTAssertNotNil(pluginType)
  }
}
