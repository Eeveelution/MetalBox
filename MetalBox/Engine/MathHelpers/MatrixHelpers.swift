//
//  MatrixHelpers.swift
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 30.01.23.
//

import Foundation
import simd

class MatrixHelpers {
    class func createYawPitchRoll(yaw: Float, pitch: Float, roll: Float) -> simd_float4x4 {
        var sr, cr, sp, cp, sy, cy: Float
        
        let halfRoll:  Float = roll * 0.5
        let halfPitch: Float = pitch * 0.5
        let halfYaw:   Float = yaw * 0.5
        
        sr = sin(halfRoll)
        cr = cos(halfRoll)
        
        sp = sin(halfPitch)
        cp = cos(halfPitch)
        
        sy = sin(halfYaw)
        cy = cos(halfYaw)
        
        let x: Float =  cy * sp * cr + sy * cp * sr
        let y: Float =  sy * cp * cr - cy * sp * sr
        let z: Float =  cy * cp * sr - sy * sp * cr
        let w: Float =  cy * cp * cr + sy * sp * sr
        
        let xx = x * x
        let yy = y * y
        let zz = z * z
        
        let xy = x * y
        let wz = w * z
        let xz = x * z
        let wy = w * y
        let yz = y * z
        let wx = w * x
        
        let matrix: simd_float4x4 = simd_float4x4(
            SIMD4<Float>(arrayLiteral: 1.0 - 2.0 * (yy + zz), 2.0 * (xy + wz),       2.0 * (xz - wy),       0.0),
            SIMD4<Float>(arrayLiteral: 2.0 * (xy - wz),       1.0 - 2.0 * (zz + xx), 2.0 * (yz + wx),       0.0),
            SIMD4<Float>(arrayLiteral: 2.0 * (xz + wy),       2.0 * (yz - wx),       1.0 - 2.0 * (yy + xx), 0.0),
            SIMD4<Float>(arrayLiteral: 0.0,                   0.0,                   0.0,                   1.0)
        )
        
        return matrix
    }
    
    class func createRotationY(radians: Float) -> simd_float4x4 {
        let c = cos(radians)
        let s = sin(radians)
        
        return simd_float4x4(
            SIMD4<Float>(arrayLiteral: c,  0, -s,  0),
            SIMD4<Float>(arrayLiteral: 0,  1,  0,  0),
            SIMD4<Float>(arrayLiteral: s,  0,  c,  0),
            SIMD4<Float>(arrayLiteral: 0,  0,  0,  0)
        )
    }
    
    class func createLookAt(cameraPosition: SIMD4<Float>, cameraTarget: SIMD4<Float>, cameraUp: SIMD4<Float>) -> simd_float4x4 {
        let camPosVec3 = SIMD3<Float>(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z);
        let camTargetVec3 = SIMD3<Float>(x: cameraTarget.x, y: cameraTarget.y, z: cameraTarget.z);
        let camUpVec3 = SIMD3<Float>(x: cameraUp.x, y: cameraUp.y, z: cameraUp.z);
        
        let zAxis = VectorHelpers.normalize(vec3: camPosVec3 - camTargetVec3)
        let xAxis = VectorHelpers.normalize(vec3: VectorHelpers.cross(vec1: camUpVec3, vec2: zAxis))
        let yAxis = VectorHelpers.cross(vec1: zAxis, vec2: xAxis)
        
        return simd_float4x4(
            SIMD4<Float>(arrayLiteral: xAxis.x, yAxis.x, zAxis.x, 0.0),
            SIMD4<Float>(arrayLiteral: xAxis.y, yAxis.y, zAxis.y, 0.0),
            SIMD4<Float>(arrayLiteral: xAxis.z, yAxis.z, zAxis.z, 0.0),
            SIMD4<Float>(arrayLiteral: -VectorHelpers.dot(vec1: xAxis, vec2: camPosVec3),
                                       -VectorHelpers.dot(vec1: yAxis, vec2: camPosVec3),
                                       -VectorHelpers.dot(vec1: zAxis, vec2: camPosVec3), 1.0)
        )
    }
}
