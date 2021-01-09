import XCTest
@testable import Copper

final class CopperTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Copper().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
