//
//  Geometry.swift
//  Copper
//
//  Created by Lukas on 10.01.21.
//

import Foundation
import simd
import MetalKit

public func screenToNormalizedCoordinates(screenCoordinate: simd_float2, screenSize: simd_float2) -> simd_float2 {
    
    let ratio = 2.0 / screenSize
    var normalized = screenCoordinate * ratio
    
    normalized *= [1.0, -1.0]
    normalized += [-1.0, 1.0]
    
    return normalized
}

public func getScreenAspectRatio(_ view: MTKView) -> Float {
    
    return Float(view.drawableSize.height / view.drawableSize.width)
    
}

public func calcVector(_ startPoint: simd_float2, _ endPoint: simd_float2) -> simd_float2 {
    return endPoint - startPoint
}

public func calcOrthoVector(_ vector: simd_float2) -> simd_float2 {
    return [vector.y * -1.0, vector.x]
}

public func calcVectorLength(_ vector: simd_float2) -> Float {
    return (pow(vector.x, 2.0) + pow(vector.y, 2.0)).squareRoot();
}

public func calcUnitVector(_ vector: simd_float2) -> simd_float2 {
    let length = calcVectorLength(vector)
    return [vector.x / length, vector.y / length]
}
