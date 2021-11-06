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
    
    public func draw(renderCommandEncoder: MTLRenderCommandEncoder) {
        var transformParams = TransformParams(location: locationOffest)
        
        renderCommandEncoder.setRenderPipelineState(self.renderPipelineState!)
        //renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        //renderCommandEncoder.setVertexBytes(&transformParams, length: MemoryLayout<TransformParams>.stride, index: 1)
        //renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 6)
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
        /// Build a render state pipeline object
        
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
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}
