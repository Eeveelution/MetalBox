//
//  VectorHelpers.swift
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 30.01.23.
//

import Foundation
import simd

class VectorHelpers {
    class func normalize(vec3: SIMD3<Float>) -> SIMD3<Float> {
        let ls = vec3.x * vec3.x + vec3.y * vec3.y + vec3.z * vec3.z
        let length = sqrt(ls)
        
        return SIMD3<Float>(vec3.x / length, vec3.y / length, vec3.z / length)
    }
    
    class func cross(vec1: SIMD3<Float>, vec2: SIMD3<Float>) -> SIMD3<Float> {
        return SIMD3<Float>(
            x: vec1.y * vec2.z - vec1.z * vec2.y,
            y: vec1.z * vec2.x - vec1.x * vec2.z,
            z: vec1.x * vec2.y - vec1.y * vec2.x
        )
    }
    
    class func dot(vec1: SIMD3<Float>, vec2: SIMD3<Float>) -> Float {
        return vec1.x * vec2.x +
               vec1.y * vec2.y +
               vec1.z * vec2.z;
    }
}
