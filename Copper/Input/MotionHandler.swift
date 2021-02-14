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
    case neutral
    case right
}

public enum MotionY{
    case forward
    case neutral
    case backward
}

public enum MotionZ {
    case clockwise
    case neutral
    case anticlockwise
}

open class CPEMotionHandler {
    
    private let motionManager: CMMotionManager
    private var lastXRotation: MotionX
    private var lastYRotation: MotionY
    private var lastZRotation: MotionZ
    
    private var lastXAttitude: MotionX
    private var lastYAttitude: MotionY
    private var lastZAttitude: MotionZ
    
    private let attitudeSensitivity: Double = 0.1
    
    
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
        
        lastXRotation = MotionX.neutral
        lastYRotation = MotionY.neutral
        lastZRotation = MotionZ.neutral
        lastXAttitude = MotionX.neutral
        lastYAttitude = MotionY.neutral
        lastZAttitude = MotionZ.neutral
        
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
        }
    }
    
    private func handleRotationUpdate(data: CMRotationRate) -> Void {
        
        // TODO neutral enum
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
        
        if (data.pitch < -attitudeSensitivity) {
            lastXAttitude = MotionX.left
        } else if (data.pitch > attitudeSensitivity) {
            lastXAttitude = MotionX.right
        } else {
            lastXAttitude = MotionX.neutral
        }
        
        if(data.roll < -attitudeSensitivity) {
            lastYAttitude = MotionY.backward
        } else if (data.roll > attitudeSensitivity) {
            lastYAttitude = MotionY.forward
        } else {
            lastYAttitude = MotionY.neutral
        }
        
        if(data.yaw < -attitudeSensitivity) {
            lastZAttitude = MotionZ.clockwise
        } else if(data.yaw > attitudeSensitivity) {
            lastZAttitude = MotionZ.anticlockwise
        } else {
            lastZAttitude = MotionZ.neutral
        }
    }
    
}
