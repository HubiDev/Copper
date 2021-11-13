//
//  TouchHandler.swift
//  Copper
//
//  Created by Lukas on 09.11.21.
//

import Foundation
import UIKit
import MetalKit
import simd

open class CPETouchHandler {
    
    var metalView: MTKView
    var gestureRecognizer: UIPanGestureRecognizer? = nil
    var lastPoints: [simd_float2] = []
    var lastPointsWereRead = false
    
    
    public init(_ view: MTKView) {
        metalView = view
        print(view.drawableSize)
        gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CPETouchHandler.handlePan))
        gestureRecognizer?.maximumNumberOfTouches = 1
        
        view.addGestureRecognizer(gestureRecognizer!)
    }
    
    @objc
    private func handlePan(){
        
        if lastPointsWereRead {
            lastPoints.removeAll()
            lastPointsWereRead = false
        }
        
        let locationInView = self.gestureRecognizer!.location(in: self.metalView)
        let frameSize = simd_float2(Float(self.metalView.frame.width), Float(self.metalView.frame.height))
        let location = simd_float2(Float(locationInView.x), Float(locationInView.y))

        let inverseSize = 1.0 / frameSize
        let normalizedLocation = simd_float2(2.0 * location.x * inverseSize.x - 1.0, 2.0 * -location.y * inverseSize.y + 1.0)
        lastPoints.append(normalizedLocation)
    }
    
    public func getLastPoints() -> [simd_float2] {
        lastPointsWereRead = true
        return lastPoints
    }
    
}
