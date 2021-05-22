//
//  Polyline.swift
//  Copper
//
//  Created by Lukas on 22.05.21.
//

import Foundation
import simd

open class Polyline
{
    public init(thickness: Float) {
        self.thickness = thickness
    }
    
    public func appendPoint(point: simd_float2) -> Void {
        points.append(point)
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
    }
    
    private func calcLineSegment(_ startPoint: simd_float2, _ endPoint: simd_float2) -> (simd_float2, simd_float2, simd_float2, simd_float2) {
        
        let vectorBetweenPoints = calcVector(startPoint, endPoint)
        var orthoVector = calcOrthoVector(vectorBetweenPoints)
        orthoVector = calcUnitVector(orthoVector)
        
        var lowerLeftPoint: simd_float2 = []
        var upperLeftPoint: simd_float2 = []
        var upperRightPoint: simd_float2 = []
        var lowerRightPoint: simd_float2 = []

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
    
    var points: [simd_float2] = [simd_float2]()
    var vertices: [ShaderVertex] = [ShaderVertex]()
    var thickness: Float
    var color: simd_float4 = [0.5, 0.5, 0.5, 1.0]
        
}
