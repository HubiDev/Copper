//
//  File.swift
//  
//
//  Created by Lukas on 09.01.21.
//

import Foundation
import Metal


public protocol CPEDrawable {
    
    func draw(renderCommandEncoder: MTLRenderCommandEncoder)
    func handleOrientationChange()
}
