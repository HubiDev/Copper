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

open class CPERectangle: CPEDrawable {

    let metalDevice: MTLDevice
    let metalView: MTKView
    
    var renderPipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer
    
    let location: simd_float2
    var size: simd_float2
    var locationOffest: simd_float2
    
    var vertices: [ShaderVertex]
    
    public init?(view: MTKView, device: MTLDevice, initLocation: simd_float2, initSize: simd_float2) {
        
        self.metalDevice = device
        self.metalView = view
        location = initLocation
        size = initSize
        locationOffest = [0,0]

        do {
            renderPipelineState = try CPERectangle.buildRenderPipelineWithDevice(device: device, metalKitView: view)
        } catch {
            return nil
        }
        
        vertices = CPERectangle.createVertices(view: view, initSize: size, initLocation: initLocation)
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<ShaderVertex>.stride, options: [])!
        
    }
    
    class func createVertices(view: MTKView, initSize: simd_float2, initLocation: simd_float2) -> [ShaderVertex] {
        
        // Move rectangle so that is centered above the desired location
        let centeredLocation = initLocation - (initSize / 2.0);
        
        return [ShaderVertex(color: CPEBlue.getValue(), position: centeredLocation),
                ShaderVertex(color: CPEBlue.getValue(), position: [centeredLocation.x, centeredLocation.y + initSize.y]),
                ShaderVertex(color: CPEBlue.getValue(), position: [centeredLocation.x + initSize.x, centeredLocation.y + initSize.y]),
               ShaderVertex(color: CPEBlue.getValue(), position: centeredLocation),
                ShaderVertex(color: CPEBlue.getValue(), position: [centeredLocation.x + initSize.x, centeredLocation.y + initSize.y]),
                ShaderVertex(color: CPEBlue.getValue(), position: [centeredLocation.x + initSize.x, centeredLocation.y])]
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
        
        var transformParams = TransformParams(location: locationOffest, aspectRatio: self.metalView.getAspectRatio(), rotation: 0.0)
        
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(&transformParams, length: MemoryLayout<TransformParams>.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 6)
        
    }
    
    public func handleOrientationChange() {
        vertices = CPERectangle.createVertices(view: metalView, initSize: size, initLocation: location)
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<ShaderVertex>.stride, options: [])!
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
        
        self.vertexBuffer = self.metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<ShaderVertex>.stride, options: [])!
    }
    
    public func getSize() -> simd_float2 {
        return size;
    }

}
