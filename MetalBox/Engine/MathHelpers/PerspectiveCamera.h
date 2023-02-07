//
//  GlmBridge.h
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 06.02.23.
//

#ifndef GlmBridge_h
#define GlmBridge_h

#import <simd/matrix.h>
#import <simd/matrix_types.h>

typedef enum {
    Forward = 1,
    Backward = 2,
    Left = 4,
    Right = 8,
} MovementType;

@interface PerspectiveCamera : NSObject {
    void* position;
    void* front;
    void* up;
    void* right;
    void* worldUp;
    
    float yaw, pitch;
    float mouseSensitivity;
    float movementSpeed;
    float cameraFov;
};

- (PerspectiveCamera*) init;

- (void) processMouseMovementWithXoffset: (float) xOffset yOffset: (float) yOffset;
- (void) processKeyboardMovement: (MovementType) movementType deltaTime: (float) deltaTime;

- (void) setPosition: (simd_float3) position;
- (void) setYaw: (float) yaw;
- (void) setPitch: (float) pitch;

- (simd_float3) getPosition;
- (float) getYaw;
- (float) getPitch;

- (void) updateVectors;
- (simd_float4x4) getViewMatrix;

- (void) dealloc;

@end

#endif /* GlmBridge_h */
