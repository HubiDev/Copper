//
//  Texture.swift
//  Copper
//
//  Created by Lukas on 17.10.21.
//

import Foundation
import MetalKit

open class CPETexture: CPEGameElement {
    
    public init(_ device: MTLDevice, _ textureName: String, _ bundle: Bundle) {
        self.metalDevice = device
        self.name = textureName
        self.bundle = bundle
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
    
    let metalDevice: MTLDevice
    let bundle: Bundle
    let name: String
    var metalTexture: MTLTexture?
    
    
    
}
