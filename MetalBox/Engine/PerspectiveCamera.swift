//
//  PerspectiveCamera.swift
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 30.01.23.
//

import Foundation
import AppKit
import simd


class PerspectiveCamera {
    var fieldOfView: Float;
    
    var position: SIMD3<Float>
    var pitch: Float;
    var yaw: Float;
    
    var moveLeftRight: Float;
    var moveBackForward: Float;
    
    var viewMatrix: simd_float4x4
    
    let defaultForward: SIMD3<Float> = SIMD3<Float>(0,  0,  1)
    let defaultRight:   SIMD3<Float> = SIMD3<Float>(1,  0,  0)
    let camRight:       SIMD3<Float> = SIMD3<Float>(1,  0,  0)
    let camForward:     SIMD3<Float> = SIMD3<Float>(0,  0,  1)
    let camUp:          SIMD3<Float> = SIMD3<Float>(0,  1,  0)
    let camDown:        SIMD3<Float> = SIMD3<Float>(0, -1,  0)
    
    init(fieldOfView: Float) {
        self.fieldOfView = fieldOfView
        
        self.position = SIMD3<Float>(1, 1, 1);
        self.pitch = 0;
        self.yaw = 0;
        
        self.moveLeftRight = 0
        self.moveBackForward = 0
        
        self.viewMatrix = simd_float4x4()
    }
    
    func moveTo(_ position: SIMD3<Float>) {
        self.position = position
    }
    
    func moveBy(_ offset: SIMD3<Float>) {
        self.position += position;
    }
    
    func update() {
        var camRotationMatrix: simd_float4x4;
        
        
    }
}
