//
//  Texture.swift
//  Copper
//
//  Created by Lukas on 17.10.21.
//

import Foundation
import MetalKit

open class CPETexture: CPEDrawable {
        
    let metalView: MTKView
    let metalDevice: MTLDevice
    let bundle: Bundle
    let name: String
    var metalTexture: MTLTexture?
    
    public var location: simd_float2 = [0.0, 0.0]
    /// Rotation in rad
    public var rotation: Float = 0.0
    
    var renderPipelineState: MTLRenderPipelineState?
    
    var vertexBuffer: MTLBuffer
    var vertices: [TexturedShaderVertex]
    
    public init?(_ view: MTKView, _ textureName: String, _ bundle: Bundle) {
        self.metalView = view
        self.metalDevice = view.device!
        self.name = textureName
        self.bundle = bundle
        
        do {
            self.renderPipelineState = try CPETexture.buildRenderPipelineWithDevice(device: self.metalDevice, metalKitView: self.metalView)
        } catch {
            return nil;
        }
        
        self.vertices = CPETexture.createVertices(view: self.metalView, initSize: [0.5, 0.5], initLocation: [0.0, 0.0])
        self.vertexBuffer = self.metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<TexturedShaderVertex>.stride, options: [])!
    }
    
    public func draw(renderCommandEncoder: MTLRenderCommandEncoder) {
        var transformParams = TransformParams(location: self.location, aspectRatio: self.metalView.getAspectRatio(), rotation: self.rotation)
        
        renderCommandEncoder.setRenderPipelineState(self.renderPipelineState!)
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(&transformParams, length: MemoryLayout<TransformParams>.stride, index: 1)
        renderCommandEncoder.setFragmentTexture(metalTexture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)
    }
    
    public func handleOrientationChange() {
        self.vertices = CPETexture.createVertices(view: self.metalView, initSize: [0.5, 0.5], initLocation: [0.0, 0.0])
        self.vertexBuffer = self.metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<TexturedShaderVertex>.stride, options: [])!
    }
    
    public func loadContent() {
        let textureLoader = MTKTextureLoader(device: self.metalDevice)
        do
        {
            self.metalTexture = try textureLoader.newTexture(name: self.name, scaleFactor: 1.0, bundle: self.bundle, options: nil)
        } catch {
            print("Failed to load texture: \(error)")
        }
        
    }
    
    class func buildRenderPipelineWithDevice(device: MTLDevice,
                                             metalKitView: MTKView) throws -> MTLRenderPipelineState? {
        
        guard let bundle = Bundle(identifier: "HubiDev.Copper") else {
            return nil
        }
        
        let library = try? device.makeDefaultLibrary(bundle: bundle)
        
        let vertexFunction = library?.makeFunction(name: "textureVertexShader")
        let fragmentFunction = library?.makeFunction(name: "textureFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "RenderPipeline"
        pipelineDescriptor.sampleCount = metalKitView.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    class func createVertices(view: MTKView, initSize: simd_float2, initLocation: simd_float2) -> [ TexturedShaderVertex] {
        
        // Move texture so that is centered above the desired location
        let centeredLocation = initLocation - (initSize / 2.0);
        
        return [TexturedShaderVertex(textureCoordinate: [0.0, 0.0], position: centeredLocation),
                TexturedShaderVertex(textureCoordinate: [0.0, 1.0], position: [centeredLocation.x, centeredLocation.y + initSize.y]),
                TexturedShaderVertex(textureCoordinate: [1.0, 1.0], position: [centeredLocation.x + initSize.x, centeredLocation.y + initSize.y]),
                TexturedShaderVertex(textureCoordinate: [0.0, 0.0], position: centeredLocation),
                TexturedShaderVertex(textureCoordinate: [1.0, 1.0], position: [centeredLocation.x + initSize.x, centeredLocation.y + initSize.y]),
                TexturedShaderVertex(textureCoordinate: [1.0, 0.0], position: [centeredLocation.x + initSize.x, centeredLocation.y])]
    }
}
