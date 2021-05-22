//
//  ControllerHandler.swift
//  Copper
//
//  Created by Lukas on 15.05.21.
//

import Foundation
import GameController

open class CPEControllerHandler {
    
    private var controllerInstance: GCController?
    
    public init() {
        
    }
    
    public func checkConnection() -> Bool {
        
        for controller in GCController.controllers() {
            
            controllerInstance = controller
        }
        return true
    }
}
