//
//  File.swift
//  
//
//  Created by Lukas on 09.01.21.
//

import Foundation
import Metal
import MetalKit
import simd

@available(iOS 10.0, *)
open class Rectangle: Drawable {
    
    var renderPiplineState: MTLRenderPipelineState!
    let vertexBuffer : MTLBuffer
    
    var location: simd_float2
    var size: simd_float2
    
    var vertices: [ShaderVertex]
    
    public init?(view: MTKView, device: MTLDevice, initLocation: simd_float2, initSize: simd_float2) {
        location = initLocation
        size = initSize

        do {
            renderPiplineState = try Rectangle.buildRenderPipelineWithDevice(device: device, metalKitView: view)
        } catch {
            return nil
        }
        
        vertices = [ShaderVertex(color: [1, 1, 1, 1], position: [-1, -1]),
                    ShaderVertex(color: [0, 1, 0, 1], position: [0, 1]),
                    ShaderVertex(color: [0, 0, 1, 1], position: [1, -1])]
        
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<ShaderVertex>.stride, options: [])!
        
    }
    
    class func buildRenderPipelineWithDevice(device: MTLDevice,
                                             metalKitView: MTKView) throws -> MTLRenderPipelineState? {
        /// Build a render state pipeline object
        
        guard let bundle = Bundle(identifier: "HubiDev.Copper") else {
            return nil
        }
        
        let library = try? device.makeDefaultLibrary(bundle: bundle)
        
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "RenderPipeline"
        pipelineDescriptor.sampleCount = metalKitView.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    public func draw(renderCommandEncoder: MTLRenderCommandEncoder) -> Void {
        
        var transformParams = TransformParams(location: [0, 0])
        
        renderCommandEncoder.setRenderPipelineState(renderPiplineState)
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(&transformParams, length: MemoryLayout<TransformParams>.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
    }

}
