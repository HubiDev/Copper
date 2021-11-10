//
//  ViewExtensions.swift
//  Copper
//
//  Created by Lukas on 10.11.21.
//

import Foundation
import MetalKit

extension MTKView {
    public func getAspectRatio() -> simd_float2 {
        
        let screenSize = self.drawableSize;
        
        if(screenSize.width >= screenSize.height){
            return [Float(screenSize.height / screenSize.width), 1.0]
            
        } else {
            return [1.0, Float(screenSize.width / screenSize.height)]
        }
    }
}
