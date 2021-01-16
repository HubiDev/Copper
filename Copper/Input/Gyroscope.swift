//
//  Gyroscope.swift
//  Copper
//
//  Created by Lukas on 14.01.21.
//

import Foundation
import CoreMotion

enum GyroDirectionX {
    case left
    case right
}

enum GyroDirectionY{
    case forward
    case backward
}

enum GyroDirectionZ {
    case clockwise
    case anticlockwise
}

open class Gyroscope {
    
    private let motionManager: CMMotionManager
    private var lastXDirection: GyroDirectionX
    private var lastYDirection: GyroDirectionY
    private var lastZDirection: GyroDirectionZ
    
    
    public init() {
        
        lastXDirection = GyroDirectionX.left
        lastYDirection = GyroDirectionY.backward
        lastZDirection = GyroDirectionZ.anticlockwise
        motionManager = CMMotionManager();
        
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = TimeInterval(1.0)
            motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: self.gyroUpdate)
        }
    }
    
    private func gyroUpdate(data: CMGyroData?, error: Error?) -> Void {
        
        if (data != nil) {
            
            if (data!.rotationRate.x < 0){
                lastXDirection = GyroDirectionX.left
            } else {
                lastXDirection = GyroDirectionX.right
            }
            
            if (data!.rotationRate.y < 0){
                lastYDirection = GyroDirectionY.backward
            } else {
                lastYDirection = GyroDirectionY.forward
            }
            
            if (data!.rotationRate.z < 0){
                lastZDirection = GyroDirectionZ.clockwise
            } else {
                lastZDirection = GyroDirectionZ.anticlockwise
            }
            
            
            print(lastXDirection)
            print(lastYDirection)
            print(lastZDirection)
        }
    }
    
}
