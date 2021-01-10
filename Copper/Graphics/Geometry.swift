//
//  Geometry.swift
//  Copper
//
//  Created by Lukas on 10.01.21.
//

import Foundation
import simd

public func screenToNormalizedCoordinates(screenCoordinate: simd_float2, screenSize: simd_float2) -> simd_float2 {
    
    let ratio = 2.0 / screenSize
    var normalized = screenCoordinate * ratio
    
    normalized *= [1.0, -1.0]
    normalized += [-1.0, 1.0]
    
    return normalized
}