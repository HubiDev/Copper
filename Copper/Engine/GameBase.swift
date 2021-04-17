//
//  GameBase.swift
//  Copper
//
//  Created by Lukas on 13.02.21.
//

import Foundation
import MetalKit

open class CPEGameBase {
    
    public let renderer: CPERenderer
    internal var elements: [CPEGameElement]
    public let metalKitView: MTKView
    
    public init?(metalKitView: MTKView) {
        elements = []
        self.metalKitView = metalKitView
        
        guard let renderer = CPERenderer(metalKitView: metalKitView) else {
            return nil
        }
        
        // Init renderer
        self.renderer = renderer
        self.renderer.doBeforeDrawing(action: self.update)
        self.renderer.mtkView(metalKitView, drawableSizeWillChange: metalKitView.drawableSize)
        metalKitView.delegate = renderer

    }
    
    open func addElement(elementToAdd: CPEGameElement) -> Void {
        elements.append(elementToAdd)
        
        let drawable = elementToAdd as? CPEDrawable
        if nil != drawable {
            renderer.addElementToDraw(element: drawable!)
        }
    }
    
    open func update() -> Void {
        
        for currentElement in elements {
            currentElement.update()
        }
    }
    
    open func getElements<T>() -> [T] {
        let filtered = elements.filter{$0 is T}
        return filtered as! [T];
    }
    
    open func getElements() -> [CPEGameElement]{
        return elements
    }
    
    
}
