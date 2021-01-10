//
//  GeometryTests.swift
//  CopperTests
//
//  Created by Lukas on 10.01.21.
//

import Foundation
import XCTest
import simd
@testable import Copper

class GeometryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScreenToNormalizedCoordinates() throws {

        let testScreenSize: simd_float2 = [400, 600]
        
        let result1 = screenToNormalizedCoordinates(screenCoordinate: [200, 300], screenSize: testScreenSize)
        XCTAssertEqual(result1, [0,0])
        
        let result2 = screenToNormalizedCoordinates(screenCoordinate: [0, 0], screenSize: testScreenSize)
        XCTAssertEqual(result2, [-1,1])
        
        let result3 = screenToNormalizedCoordinates(screenCoordinate: [400, 0], screenSize: testScreenSize)
        XCTAssertEqual(result3, [1,1])
        
        let result4 = screenToNormalizedCoordinates(screenCoordinate: [400, 600], screenSize: testScreenSize)
        XCTAssertEqual(result4, [1,-1])
        
        let result5 = screenToNormalizedCoordinates(screenCoordinate: [0, 600], screenSize: testScreenSize)
        XCTAssertEqual(result5, [-1,-1])
        
    }

}

