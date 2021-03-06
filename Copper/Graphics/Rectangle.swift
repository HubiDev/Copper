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
open class CPERectangle: CPEDrawable {
    
    let device: MTLDevice
    
    var renderPiplineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer
    
    let location: simd_float2
    var size: simd_float2
    var locationOffest: simd_float2
    
    var vertices: [ShaderVertex]
    
    public init?(view: MTKView, device: MTLDevice, initLocation: simd_float2, initSize: simd_float2) {
        
        self.device = device
        location = initLocation
        size = initSize
        locationOffest = [0,0]

        do {
            renderPiplineState = try CPERectangle.buildRenderPipelineWithDevice(device: device, metalKitView: view)
        } catch {
            return nil
        }
        
        vertices = CPERectangle.createVertices(view: view, initSize: size, initLocation: initLocation)
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<ShaderVertex>.stride, options: [])!
        
    }
    
    class func createVertices(view: MTKView, initSize: simd_float2, initLocation: simd_float2) -> [ShaderVertex] {
        
        var ratioWidth: Float
        var ratioHeight: Float
        
        let screenSize = view.drawableSize;
        
        if(screenSize.width >= screenSize.height){
            ratioWidth = Float(screenSize.height / screenSize.width)
            ratioHeight = 1.0
            
        } else {
            ratioWidth = 1.0
            ratioHeight = Float(screenSize.width / screenSize.height)
            
        }
        
        let adaptedWidth = initSize.x * ratioWidth
        let adaptedHeight = initSize.y * ratioHeight
        
        
        return [ShaderVertex(color: CPEBlue.getValue(), position: initLocation),
                ShaderVertex(color: CPEBlue.getValue(), position: [initLocation.x, initLocation.y + adaptedHeight]),
                ShaderVertex(color: CPEBlue.getValue(), position: [initLocation.x + adaptedWidth, initLocation.y + adaptedHeight]),
               ShaderVertex(color: CPEBlue.getValue(), position: initLocation),
               ShaderVertex(color: CPEBlue.getValue(), position: [initLocation.x + adaptedWidth, initLocation.y + adaptedHeight]),
               ShaderVertex(color: CPEBlue.getValue(), position: [initLocation.x + adaptedWidth, initLocation.y])]
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
        
        var transformParams = TransformParams(location: locationOffest)
        
        renderCommandEncoder.setRenderPipelineState(renderPiplineState)
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(&transformParams, length: MemoryLayout<TransformParams>.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 6)
        
    }
    
    public func getLocation() -> simd_float2 {
        return (location + locationOffest)
    }
    
    public func updateLocation(newLocation: simd_float2) -> Void {
        
        locationOffest = location - [newLocation.x, newLocation.y]
        locationOffest *= -1
    }
    
    public func setColor(newColor: CPEColor) -> Void {
        
        // TODO optimize
        
        vertices[0].color = newColor.getValue()
        
        for i in self.vertices.indices {
            self.vertices[i].color = newColor.getValue()
        }
        
        self.vertexBuffer = self.device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<ShaderVertex>.stride, options: [])!
    }
    
    public func getSize() -> simd_float2 {
        return size;
    }

}
