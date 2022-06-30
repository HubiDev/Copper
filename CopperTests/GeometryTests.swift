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
    
    func testCalcAngleDistanceOrder() throws {
        
        let larger = 2.0 * Float.pi
        let smaller = Float.pi
        
        let expectedResult = Float.pi
        let accuracy: Float = 0.001
        
        let result1 = angleDistance(larger, smaller)
        XCTAssertEqual(result1, expectedResult, accuracy: accuracy)

        let result2 = angleDistance(smaller, larger)
        XCTAssertEqual(result2, expectedResult, accuracy: accuracy)
    }

    func testCalcMinAngleDistance() throws {
        
        let accuracy: Float = 0.001
        let expectedResult: Float = 1.0
        let result = minAngleDistance(2.0 * Float.pi, expectedResult)
        
        XCTAssertEqual(result, expectedResult, accuracy: accuracy)
    }
    
}

