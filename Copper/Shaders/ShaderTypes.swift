//
//  ShaderTypes.swift
//  Copper
//
//  Created by Lukas on 09.01.21.
//

import Foundation
import simd

/*
 struct Vertex {
     vector_float4 color;
     vector_float2 pos;
 };
 */

struct ShaderVertex {
    let color: vector_float4
    let position: vector_float2
}

struct TransformParams{
    let location: vector_float2
}
