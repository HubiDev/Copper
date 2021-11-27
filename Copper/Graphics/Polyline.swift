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
    
    public private(set) var points: [simd_float2] = [simd_float2]()
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
    
    private func adaptPoint(_ point: simd_float2) -> simd_float2 {
        return point * (1.0 / self.metalView.getAspectRatio())
    }
    
    public func appendPoint(point: simd_float2) {
        
        let adaptedPoint = adaptPoint(point)
        
        if points.isEmpty {
            points.append(adaptedPoint)
        } else {
            if filterPoint(point: adaptedPoint, front: false) {
                points.append(adaptedPoint)
                
                if points.count > 1 {
                    render(at: points.count - 1)
                }
            }
        }
    }
    
    public func insertPoint(_ point: simd_float2, at index: Int) {
        let adaptedPoint = adaptPoint(point)
        
        // TODO: filter
        points.insert(adaptedPoint, at: index)
        render(at: index)
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
            
            if !points.isEmpty {
                self.vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<ShaderVertex>.stride, options: [])!
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
    
    private func renderFront(start: simd_float2, end: simd_float2, needsLineJoint: Bool) {
        let (lowerLeftPoint, upperLeftPoint, upperRightPoint, lowerRightPoint) = calcLineSegment(start, end)

        vertices.insert(ShaderVertex(color: self.color, position: lowerRightPoint), at: 0)
        vertices.insert(ShaderVertex(color: self.color, position: upperRightPoint), at: 0)
        vertices.insert(ShaderVertex(color: self.color, position: upperLeftPoint), at: 0)

        vertices.insert(ShaderVertex(color: self.color, position: lowerRightPoint), at: 0)
        vertices.insert(ShaderVertex(color: self.color, position: upperLeftPoint), at: 0)
        vertices.insert(ShaderVertex(color: self.color, position: lowerLeftPoint), at: 0)
        
        if needsLineJoint {
            let vertexIndex = 5
            let lastLowerPoint = vertices[vertexIndex]
            let lastUpperPoint = vertices[vertexIndex - 1]
            
            vertices.insert(ShaderVertex(color: self.color, position: upperLeftPoint), at: 6)
            vertices.insert(ShaderVertex(color: self.color, position: lowerLeftPoint), at: 6)
            vertices.insert(lastLowerPoint, at: 6)
            
            vertices.insert(ShaderVertex(color: self.color, position: upperLeftPoint), at: 6)
            vertices.insert(ShaderVertex(color: self.color, position: lowerLeftPoint), at: 6)
            vertices.insert(lastUpperPoint, at: 6)
        }

    }
    
    private func renderBack(start: simd_float2, end: simd_float2, needsLineJoint: Bool) {

        let (lowerLeftPoint, upperLeftPoint, upperRightPoint, lowerRightPoint) = calcLineSegment(start, end)
        
        if needsLineJoint {
            let vertexIndex = vertices.count - 1
            let lastLowerPoint = vertices[vertexIndex]
            let lastUpperPoint = vertices[vertexIndex - 1]
            
            vertices.append(lastUpperPoint)
            vertices.append(ShaderVertex(color: self.color, position: lowerLeftPoint))
            vertices.append(ShaderVertex(color: self.color, position: upperLeftPoint))

            vertices.append(lastLowerPoint)
            vertices.append(ShaderVertex(color: self.color, position: lowerLeftPoint))
            vertices.append(ShaderVertex(color: self.color, position: upperLeftPoint))
        }
        
        vertices.append(ShaderVertex(color: self.color, position: lowerLeftPoint))
        vertices.append(ShaderVertex(color: self.color, position: upperLeftPoint))
        vertices.append(ShaderVertex(color: self.color, position: lowerRightPoint))

        vertices.append(ShaderVertex(color: self.color, position: upperLeftPoint))
        vertices.append(ShaderVertex(color: self.color, position: upperRightPoint))
        vertices.append(ShaderVertex(color: self.color, position: lowerRightPoint))
                    
    }
    
    private func renderCenter(start: simd_float2, end: simd_float2) {
        
    }
    
    
    
    private func render(at index: Int) {
        
        if points.count > 1 {
            
            let lineJointNeeded = points.count > 2
            
            if index == points.count - 1 {
                let startPoint = points[index - 1]
                let endPoint = points[index]
                renderBack(start: startPoint, end: endPoint, needsLineJoint: lineJointNeeded)
            } else if index == 0 {
                let startPoint = points.first!
                let endPoint = points[1]
                renderFront(start: startPoint, end: endPoint, needsLineJoint: lineJointNeeded)
            } else {
                // TODO: implement
            }
            
            self.vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<ShaderVertex>.stride, options: [])!
        }
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
