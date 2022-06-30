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

public func calcScalarProduct(_ first: simd_float2, _ second: simd_float2) -> Float {
    return first.x * second.x + first.y * second.y
}

public func calcAngle(_ first: simd_float2, _ second: simd_float2) -> Float {
    let scalar = calcScalarProduct(first, second)
    let lengthFirst = calcVectorLength(first)
    let lengthSecond = calcVectorLength(second)
    return acos(scalar / (lengthFirst * lengthSecond))
}

public func normalizeAngle(_ angle: Float) -> Float {
    return angle.truncatingRemainder(dividingBy: 2 * .pi)
}

public func angleDistance(_ first: Float, _ second: Float) -> Float {
    let firstNormalized = normalizeAngle(first)
    let secondNormalized = normalizeAngle(second)
    
    return abs(firstNormalized - secondNormalized)
}

public func minAngleDistance(_ first: Float, _ second: Float) -> Float {
    
    let distance = angleDistance(first, second)
    
    if distance > .pi {
        return 2 * .pi - distance
    }
    
    return distance
}
