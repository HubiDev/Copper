//
//  Polyline.swift
//  Copper
//
//  Created by Lukas on 22.05.21.
//

import Foundation
import MetalKit
import simd

open class CPEPolyline : CPEDrawable
{
    let metalDevice: MTLDevice
    let metalView: MTKView
    
    var points: [simd_float2] = [simd_float2]()
    var vertices: [ShaderVertex] = [ShaderVertex]()
    var vertexBuffer: MTLBuffer? = nil
    
    var thickness: Float = 0.01
    var color: simd_float4 = [0.5, 0.5, 0.5, 1.0]
    
    var renderPipelineState: MTLRenderPipelineState? = nil
    
    public init?(_ view: MTKView, _ thickness: Float) {
        self.metalView = view
        self.metalDevice = view.device!
        self.thickness = thickness
        
        do {
            self.renderPipelineState = try CPEPolyline.buildRenderPipelineWithDevice(device: self.metalDevice, metalKitView: self.metalView)
        } catch {
            return nil;
        }
    }
    
    public func draw(renderCommandEncoder: MTLRenderCommandEncoder) {
        
        if !self.vertices.isEmpty {
            var transformParams = TransformParams(location: [0.0,0.0], aspectRatio: self.metalView.getAspectRatio(), rotation: 0.0)
            
            renderCommandEncoder.setRenderPipelineState(renderPipelineState!)
            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBytes(&transformParams, length: MemoryLayout<TransformParams>.stride, index: 1)
            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: self.vertices.count)
        }
    }
    
    class func buildRenderPipelineWithDevice(device: MTLDevice,
                                             metalKitView: MTKView) throws -> MTLRenderPipelineState? {

        // TODO common code: reduce duplications
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
    
    public func handleOrientationChange() {
        
    }
    
    public func appendPoint(point: simd_float2) -> Void {
        
        let adaptedPoint = point * simd_float2(1.0, 1.0/0.5622189)
        
        if points.isEmpty {
            points.append(adaptedPoint)
        } else {
            if filterPoint(point: adaptedPoint, front: false) {
                points.append(adaptedPoint)
                
                if points.count > 1 {
                    render()
                }
            }
        }
    }
    
    
    
    public func removeFirst() -> simd_float2? {
        
        var removed: simd_float2? = nil
        
        if !points.isEmpty {
            removed = points.first
            points.removeFirst()
            
            if vertices.count > 12 {
                vertices.removeSubrange(0...11)
            } else {
                vertices.removeAll()
            }
        }
        
        return removed
    }
    
    
    private func filterPoint(point: simd_float2, front: Bool) -> Bool {
        let pointToCompare = front ? points.first : points.last
        
        if pointToCompare != point {
            // todo: check wether minimal distance is covered
            return true
        }
        
        return false
    }
    
    private func render() {
        
        if points.count > 1 {
            let startPoint = points[points.count - 2]
            let endPoint = points.last! // TODO
            let (lowerLeftPoint, upperLeftPoint, upperRightPoint, lowerRightPoint) = calcLineSegment(startPoint, endPoint)
            
            if(points.count > 2)
            {
                let lastLowerPoint = vertices[vertices.count - 1]
                let lastUpperPoint = vertices[vertices.count - 2]

                // line joint
                vertices.append(lastUpperPoint)
                vertices.append(ShaderVertex(color: self.color, position: lowerLeftPoint))
                vertices.append(ShaderVertex(color: self.color, position: upperLeftPoint))

                vertices.append(lastLowerPoint)
                vertices.append(ShaderVertex(color: self.color, position: lowerLeftPoint))
                vertices.append(ShaderVertex(color: self.color, position: upperLeftPoint))
            }

            // duplicated
            vertices.append(ShaderVertex(color: self.color, position: lowerLeftPoint))
            vertices.append(ShaderVertex(color: self.color, position: upperLeftPoint))
            vertices.append(ShaderVertex(color: self.color, position: lowerRightPoint))

            vertices.append(ShaderVertex(color: self.color, position: upperLeftPoint))
            vertices.append(ShaderVertex(color: self.color, position: upperRightPoint))
            vertices.append(ShaderVertex(color: self.color, position: lowerRightPoint))
        }
        
        self.vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<ShaderVertex>.stride, options: [])!
    }
    
    private func calcLineSegment(_ startPoint: simd_float2, _ endPoint: simd_float2) -> (simd_float2, simd_float2, simd_float2, simd_float2) {
        
        let vectorBetweenPoints = calcVector(startPoint, endPoint)
        var orthoVector = calcOrthoVector(vectorBetweenPoints)
        orthoVector = calcUnitVector(orthoVector)
        
        var lowerLeftPoint: simd_float2 = [0.0, 0.0]
        var upperLeftPoint: simd_float2 = [0.0, 0.0]
        var upperRightPoint: simd_float2 = [0.0, 0.0]
        var lowerRightPoint: simd_float2 = [0.0, 0.0]

        lowerLeftPoint.x = startPoint.x + ((-1.0) * thickness * orthoVector.x);
        lowerLeftPoint.y = startPoint.y + ((-1.0) * thickness * orthoVector.y);
        upperLeftPoint.x = startPoint.x + (thickness * orthoVector.x);
        upperLeftPoint.y = startPoint.y + (thickness * orthoVector.y);
        lowerRightPoint.x = endPoint.x + ((-1.0) * thickness * orthoVector.x);
        lowerRightPoint.y = endPoint.y + ((-1.0) * thickness * orthoVector.y);
        upperRightPoint.x = endPoint.x + (thickness * orthoVector.x);
        upperRightPoint.y = endPoint.y + (thickness * orthoVector.y);

        return (lowerLeftPoint, upperLeftPoint, upperRightPoint, lowerRightPoint)
    }
    

        
}
