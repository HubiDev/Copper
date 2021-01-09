//
//  Shaders.metal
//  PlaneAdventure
//
//  Created by Lukas on 07.01.21.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct ShaderVertex{
    vector_float4 color;
    vector_float2 position;
};

struct TransformParams{
    vector_float2 position;
};


struct VertexOut {
    float4 color;
    float4 pos [[position]];
};

vertex VertexOut vertexShader(const device ShaderVertex* vertexArray [[buffer(0)]], const device TransformParams* transform, unsigned int vid [[vertex_id]])
{
    // Get the data for the current vertex.
    ShaderVertex in = vertexArray[vid];
    
    VertexOut out;
    
    // Pass the vertex color directly to the rasterizer
    out.color = in.color;
    // Pass the already normalized screen-space coordinates to the rasterizer
    out.pos = float4(in.position.x + transform->position.x, in.position.y + transform->position.y, 0, 1);
    
    
    return out;
}

fragment float4 fragmentShader(VertexOut interpolated [[stage_in]])
{
    return interpolated.color;
}
