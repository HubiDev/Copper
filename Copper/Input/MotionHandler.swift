//
//  Gyroscope.swift
//  Copper
//
//  Created by Lukas on 14.01.21.
//

import Foundation
import CoreMotion

public enum MotionX {
    case left
    case right
}

public enum MotionY{
    case forward
    case backward
}

public enum MotionZ {
    case clockwise
    case anticlockwise
}

open class MotionHandler {
    
    private let motionManager: CMMotionManager
    private var lastXRotation: MotionX
    private var lastYRotation: MotionY
    private var lastZRotation: MotionZ
    
    private var lastXAttitude: MotionX
    private var lastYAttitude: MotionY
    private var lastZAttitude: MotionZ
    
    
    public var rotationX: MotionX {
        get {
            return lastXRotation
        }
    }
    
    public var rotationY: MotionY {
        get {
            return lastYRotation
        }
    }
    
    public var rotationZ: MotionZ {
        get {
            return lastZRotation
        }
    }
    
    public var attitudeX: MotionX {
        get {
            return lastXAttitude
        }
    }
    
    public var attitudeY: MotionY {
        get {
            return lastYAttitude
        }
    }
    
    public var attitudeZ: MotionZ {
        get {
            return lastZAttitude
        }
    }
    
    
    public init() {
        
        lastXRotation = MotionX.left
        lastYRotation = MotionY.backward
        lastZRotation = MotionZ.anticlockwise
        lastXAttitude = MotionX.left
        lastYAttitude = MotionY.backward
        lastZAttitude = MotionZ.anticlockwise
        
        motionManager = CMMotionManager();
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = TimeInterval(1.0 / 60.0)
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: self.motionUpdate)
        }
        
    }
    
    private func motionUpdate(data: CMDeviceMotion?, error: Error?) -> Void {
        
        if (data != nil) {
            handleRotationUpdate(data: data!.rotationRate)
            handleAttitudeUpdate(data: data!.attitude)
            
            print(lastXAttitude)
            print(lastYAttitude)
            print(lastZAttitude)
        }
    }
    
    private func handleRotationUpdate(data: CMRotationRate) -> Void {
        if (data.x < 0){
            lastXRotation = MotionX.left
        } else {
            lastXRotation = MotionX.right
        }
        
        if (data.y < 0){
            lastYRotation = MotionY.backward
        } else {
            lastYRotation = MotionY.forward
        }
        
        if (data.z < 0){
            lastZRotation = MotionZ.clockwise
        } else {
            lastZRotation = MotionZ.anticlockwise
        }
    }
    
    private func handleAttitudeUpdate(data: CMAttitude) -> Void {
        if(data.pitch < 0) {
            lastXAttitude = MotionX.left
        } else {
            lastXAttitude = MotionX.right
        }
        
        if(data.roll < 0) {
            lastYAttitude = MotionY.backward
        } else {
            lastYAttitude = MotionY.forward
        }
        
        if(data.yaw < 0) {
            lastZAttitude = MotionZ.clockwise
        } else {
            lastZAttitude = MotionZ.anticlockwise
        }
    }
    
}
