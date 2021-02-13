//
//  GameBase.swift
//  Copper
//
//  Created by Lukas on 13.02.21.
//

import Foundation
import MetalKit

open class GameBase {
    
    public let renderer: CPRRenderer
    
    public init?(metalKitView: MTKView) {
        guard let renderer = CPRRenderer(metalKitView: metalKitView) else {
            return nil
        }
        
        self.renderer = renderer
        self.renderer.doBeforeDrawing(action: self.update)
        
        self.renderer.mtkView(metalKitView, drawableSizeWillChange: metalKitView.drawableSize)
        metalKitView.delegate = renderer
    }
    
    public func update() -> Void{
        print("Before drawing")
    }
}
