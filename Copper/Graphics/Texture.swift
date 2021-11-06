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
    var locationOffest: simd_float2
    var renderPipelineState: MTLRenderPipelineState?
    
    var vertexBuffer: MTLBuffer
    var vertices: [TexturedShaderVertex]
    
    public func draw(renderCommandEncoder: MTLRenderCommandEncoder) {
        var transformParams = TransformParams(location: locationOffest)
        
        renderCommandEncoder.setRenderPipelineState(self.renderPipelineState!)
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(&transformParams, length: MemoryLayout<TransformParams>.stride, index: 1)
        renderCommandEncoder.setFragmentTexture(metalTexture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)
    }
    
    
    public init?(_ view: MTKView, _ device: MTLDevice, _ textureName: String, _ bundle: Bundle) {
        self.metalView = view
        self.metalDevice = device
        self.name = textureName
        self.bundle = bundle
        self.locationOffest = [0,0]
        
        do {
            self.renderPipelineState = try CPETexture.buildRenderPipelineWithDevice(device: self.metalDevice, metalKitView: self.metalView)
        } catch {
            return nil;
        }
        
        self.vertices = CPETexture.createVertices(view: self.metalView, initSize: [0.5, 0.5], initLocation: [0.0, 0.0])
        self.vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<TexturedShaderVertex>.stride, options: [])!
    }
    
    public func update() {
        
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
        
        
        return [TexturedShaderVertex(textureCoordinate: [0.0, 0.0], position: initLocation),
                TexturedShaderVertex(textureCoordinate: [0.0, 1.0], position: [initLocation.x, initLocation.y + adaptedHeight]),
                TexturedShaderVertex(textureCoordinate: [1.0, 1.0], position: [initLocation.x + adaptedWidth, initLocation.y + adaptedHeight]),
                TexturedShaderVertex(textureCoordinate: [0.0, 0.0], position: initLocation),
                TexturedShaderVertex(textureCoordinate: [1.0, 1.0], position: [initLocation.x + adaptedWidth, initLocation.y + adaptedHeight]),
                TexturedShaderVertex(textureCoordinate: [1.0, 0.0], position: [initLocation.x + adaptedWidth, initLocation.y])]
    }
}
