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
    var tapGestureRecognizer: UITapGestureRecognizer? = nil
    var lastPoints: [simd_float2] = []
    
    public init(_ view: MTKView) {
        metalView = view
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CPETouchHandler.viewTapped))
        tapGestureRecognizer?.numberOfTapsRequired = 1
        
        view.addGestureRecognizer(tapGestureRecognizer!)
    }
    
    @objc
    func viewTapped(){
        print("View was tapped")
        var location = tapGestureRecognizer?.location(in: self.metalView)
        print(location)
    }
}
