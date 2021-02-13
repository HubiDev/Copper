//
//  Renderer.swift
//  Copper
//
//  Created by Lukas on 13.02.21.
//

import Foundation
import MetalKit

open class CPRRenderer: NSObject, MTKViewDelegate {
    
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    
    private let elementsToDraw: [CPRDrawable]
    
    private var beforeDrawAction: () -> Void
    
    init?(metalKitView: MTKView) {
        self.device = metalKitView.device!
        guard let queue = self.device.makeCommandQueue() else { return nil }
        self.commandQueue = queue
        elementsToDraw = []
        
        beforeDrawAction = {}
        
        super.init()
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public func doBeforeDrawing(action: @escaping () -> Void)
    {
        beforeDrawAction = action
    }
    
    public func draw(in view: MTKView) {
        
        beforeDrawAction()
        
        if let commandBuffer = commandQueue.makeCommandBuffer() {
                        
            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            let renderPassDescriptor = view.currentRenderPassDescriptor
            
            if let renderPassDescriptor = renderPassDescriptor, let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                renderEncoder.label = "Primary Render Encoder"
                
                for currentDrawable in elementsToDraw {
                    currentDrawable.draw(renderCommandEncoder: renderEncoder)
                }
                
                renderEncoder.endEncoding()
                
                if let drawable = view.currentDrawable {
                    commandBuffer.present(drawable)
                }
            }
            
            commandBuffer.commit()
        }
    }
}
