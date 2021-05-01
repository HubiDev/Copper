//
//  ShaderTypes.swift
//  Copper
//
//  Created by Lukas on 09.01.21.
//

import Foundation
import simd

struct ShaderVertex {
    var color: vector_float4
    var position: vector_float2
}

struct TransformParams{
    var location: vector_float2
}
