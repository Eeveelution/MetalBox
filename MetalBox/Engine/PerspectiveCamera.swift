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
    var renderer: Renderer
    var fieldOfView: Float;
    
    var position: SIMD4<Float>
    var pitch: Float;
    var yaw: Float;
    
    var moveLeftRight: Float;
    var moveBackForward: Float;
    
    var viewMatrix: simd_float4x4
    
    init(fieldOfView: Float, renderer: Renderer) {
        self.renderer = renderer
        self.fieldOfView = fieldOfView
        
        self.position = SIMD4<Float>(1, 1, 1, 1);
        self.pitch = 0;
        self.yaw = 0;
        
        self.moveLeftRight = 0
        self.moveBackForward = 0
        
        self.viewMatrix = simd_float4x4()
    }
    
    func moveTo(_ position: SIMD4<Float>) {
        self.position = position
    }
    
    func moveBy(_ offset: SIMD4<Float>) {
        self.position += position;
    }
    
    //func getProjectionMatrix() -> simd_float4x4 {
    //    //let matrix = MatrixHelpers.createPerspectiveFov(fov: self.fieldOfView * (3.1415 / 180.0), aspectRatio: Float(self.renderer.currentWindowSize.width / self.renderer.currentWindowSize.height), nearPlaneDistance: 0.1, farPlaneDistance: 1000)
    //    return matrix
    //}
    
    func update() {
        //let defaultForward: SIMD4<Float> = SIMD4<Float>(0,  0,  1,  0)
        //let defaultRight:   SIMD4<Float> = SIMD4<Float>(1,  0,  0,  0)
        //var camRight:       SIMD4<Float> = SIMD4<Float>(1,  0,  0,  0)
        //var camForward:     SIMD4<Float> = SIMD4<Float>(0,  0,  1,  0)
        //var camUp:          SIMD4<Float> = SIMD4<Float>(0,  1,  0,  0)
        //let camDown:        SIMD4<Float> = SIMD4<Float>(0, -1,  0,  0)
        //
        //var camTarget: SIMD3<Float> = SIMD3<Float>();
        ////let camRotationMatrix: simd_float4x4 = MatrixHelpers.createYawPitchRoll(yaw: self.yaw, pitch: self.pitch, roll: 0);
        //
        //let transformedTarget = defaultForward * camRotationMatrix
        //
        //camTarget.x = transformedTarget.x
        //camTarget.y = transformedTarget.y
        //camTarget.z = transformedTarget.z
        //
        ////camTarget = VectorHelpers.normalize(vec3: camTarget)
        //
        //let tempYTempMatrix = MatrixHelpers.createRotationY(radians: self.yaw)
        //
        //camRight = defaultRight * tempYTempMatrix
        //camUp = camUp * tempYTempMatrix
        //camForward = camForward * tempYTempMatrix
        //
        //self.position += self.moveLeftRight * camRight
        //self.position += self.moveBackForward * camForward
        //self.position += self.moveBackForward * camDown * self.pitch
        //
        //self.moveLeftRight = 0
        //self.moveBackForward = 0
        //
        //let addedCamTarget = self.position + SIMD4<Float>(camTarget, 1.0)
        //
        //camTarget.x = addedCamTarget.x
        //camTarget.y = addedCamTarget.y
        //camTarget.z = addedCamTarget.z
        //
        //self.viewMatrix = MatrixHelpers.createLookAt(cameraPosition: self.position, cameraTarget: SIMD4<Float>(camTarget, 1.0), cameraUp: camUp)
        //self.viewMatrix = MatrixHelpers.createLookAt(cameraPosition: self.position, cameraTarget: defaultForward, cameraUp: camUp)
    }
}
