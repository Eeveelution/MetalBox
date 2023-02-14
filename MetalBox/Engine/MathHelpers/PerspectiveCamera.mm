//
//  GlmBridge.m
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 06.02.23.
//

#import <Foundation/Foundation.h>

#include "PerspectiveCamera.h"

#import "../../../glm/glm/glm.hpp"
#import "../../../glm/glm/gtc/matrix_transform.hpp"

#define self_position ((glm::vec3*)self->position)
#define self_worldUp ((glm::vec3*)self->worldUp)
#define self_front ((glm::vec3*)self->front)
#define self_right ((glm::vec3*)self->right)

@implementation PerspectiveCamera : NSObject

- (PerspectiveCamera*) init {
    self = [super init];
    
    if(self) {
        self->position = malloc(sizeof(glm::vec3));
        self->worldUp = malloc(sizeof(glm::vec3));
        self->front = malloc(sizeof(glm::vec3));
        self->right = malloc(sizeof(glm::vec3));
        
        //How I love Objective-C and C++ interop...
        *self_position = glm::vec3(0.0f, 0.0f, 0.0f);
        *self_worldUp = glm::vec3(0.0f, 1.0f, 0.0f);
        *self_front = glm::vec3(0.0f, 0.0f, -1.0f);
        
        self->pitch = 0.0f;
        self->movementSpeed = 250.0f;
        self->mouseSensitivity = 0.1f;
        self->cameraFov = 75;
        
        [self updateVectors];
    }
    
    return self;
}

- (void) updateVectors {
    glm::vec3 newFront;
    
    newFront.x = cos( glm::radians(self->yaw) ) * cos( glm::radians(self->pitch) );
    newFront.y = sin( glm::radians(self->pitch) );
    newFront.z = sin( glm::radians(self->yaw) ) * cos( glm::radians(self->pitch) );
    
    *self_front   = glm::normalize(newFront);
    *self_right   = glm::normalize( glm::cross( *self_front, *self_worldUp ) );
    *self_worldUp = glm::normalize( glm::cross( *self_right, *self_front ) );
}

- (void) processMouseMovementWithXoffset: (float) xOffset yOffset: (float) yOffset {
    xOffset *= self->mouseSensitivity;
    yOffset *= self->mouseSensitivity;
    
    self->yaw += xOffset;
    self->pitch = yOffset;
    
    if(self->pitch > 89.0f) {
        self->pitch = 89.0f;
    }
    
    if(self->pitch < -89.0f) {
        self->pitch = -89.0f;
    }
    
    [self updateVectors];
}

- (void) processKeyboardMovement: (MovementType) movementType deltaTime: (float) deltaTime {
    float velocity = self->movementSpeed * deltaTime;
    
    glm::vec3 result = *self_position;
    
    if((movementType & MovementType::Forward) == MovementType::Forward) {
        result += *self_front * velocity;
    }
    
    if((movementType & MovementType::Backward) == MovementType::Backward) {
        result -= *self_front * velocity;
    }
    
    if((movementType & MovementType::Left) == MovementType::Left) {
        result -= *self_right * velocity;
    }
    
    if((movementType & MovementType::Right) == MovementType::Right) {
        result += *self_right * velocity;
    }
    
    self_position->x = result.x;
    self_position->y = result.y;
    self_position->z = result.z;
    
    [self updateVectors];
}

- (simd_float4x4) getViewMatrix {
    simd_float4x4 matrix;
    
    glm::mat4 perspective = glm::perspective(glm::radians(self->cameraFov), (1600.0f / 1200.0f), 0.1f, 1000.0f);
    glm::mat4 lookAt = glm::lookAt(*self_position, *self_position + *self_front, *self_worldUp);
    
    lookAt = perspective * lookAt;
    
    memcpy(&matrix, &lookAt, sizeof(simd_float4x4));
    
    return matrix;
}

- (void) setPosition: (simd_float3) position {
    self_position->x = position.x;
    self_position->y = position.y;
    self_position->z = position.z;
    
    [self updateVectors];
}

- (void) setYaw: (float) yaw {
    self->yaw = yaw;
    
    [self updateVectors];
}

- (void) setPitch: (float) pitch {
    self->pitch = pitch;
    
    [self updateVectors];
}

- (simd_float3) getPosition {
    simd_float3 returnPosition;
    
    returnPosition.x = self_position->x;
    returnPosition.y = self_position->y;
    returnPosition.z = self_position->z;
    
    return returnPosition;
}

- (float) getYaw {
    return self->yaw;
}

- (float) getPitch {
    return self->pitch;
}

- (void) dealloc {
    free(self->position);
    free(self->worldUp);
    free(self->front);
}

- (void) printPosition {
    NSLog(@"%f %f %f", self_position->x, self_position->y, self_position->y);
}

@end
