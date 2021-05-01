//
//  Color.swift
//  Copper
//
//  Created by Lukas on 01.05.21.
//

import Foundation
import simd

open class CPEColor {
    
    private var value: vector_float4
    
    init(_ r: Float, _ g: Float, _ b: Float, _ a: Float) {
        value = [r,g,b,a]
    }
    
    func getValue() -> vector_float4 {
        return value
    }
    
    func setValue(_ r: Float, _ g: Float, _ b: Float) -> Void{
        value = [r,g,b,value[3]]
    }
    
    func setValue(_ r: Float, _ g: Float, _ b: Float, _ a: Float) -> Void{
        value = [r,g,b,a]
    }
    
}

public let CPEBlue: CPEColor = CPEColor(0.0,0.0,1.0,1.0)
public let CPERed: CPEColor = CPEColor(1.0,0.0,0.0,1.0)
public let CPEGreen: CPEColor = CPEColor(0.0,1.0,0.0,1.0)
