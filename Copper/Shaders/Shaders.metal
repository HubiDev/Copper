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

struct TexturedShaderVertex{
    vector_float2 textureCoordinate;
    vector_float2 position;
};

struct TransformParams{
    vector_float2 position;
};


struct VertexOut {
    float4 color;
    float4 pos [[position]];
};

struct TexturedVertexOut {
    float2 textureCoordinate;
    float4 position [[position]];
};

matrix_float2x2 calc_rotation_matrix(float rotation)
{
    return matrix_float2x2{{cos(rotation), -sin(rotation)}, {sin(rotation), cos(rotation)}};
}


vertex VertexOut vertexShader(const device ShaderVertex* vertexArray [[buffer(0)]], const device TransformParams* transform, unsigned int vid [[vertex_id]])
{
    // Get the data for the current vertex.
    ShaderVertex in = vertexArray[vid];
    
    VertexOut out;
    
    auto rotated_position = in.position * calc_rotation_matrix(0.0);
    
    // Pass the vertex color directly to the rasterizer
    out.color = in.color;
    // Pass the already normalized screen-space coordinates to the rasterizer
    out.pos = float4(rotated_position.x + transform->position.x, rotated_position.y + transform->position.y, 0, 1);
    
    return out;
}

fragment float4 fragmentShader(VertexOut interpolated [[stage_in]])
{
    return interpolated.color;
}

vertex TexturedVertexOut textureVertexShader(const device TexturedShaderVertex* vertexArray [[buffer(0)]], const device TransformParams* transform, unsigned int vid [[vertex_id]])
{
    TexturedVertexOut out;
    // Get the data for the current vertex.
    auto in = vertexArray[vid];
    auto rotated_position = in.position * calc_rotation_matrix(3.1415);
    
    out.position = float4(rotated_position.x + transform->position.x, rotated_position.y + transform->position.y, 0, 1);
    out.textureCoordinate = vertexArray[vid].textureCoordinate;
    
    return out;
}

fragment float4 textureFragmentShader(TexturedVertexOut in [[stage_in]], texture2d<half> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    const auto colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
    
    return float4(colorSample);
}
