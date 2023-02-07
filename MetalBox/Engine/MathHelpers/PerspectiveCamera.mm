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

@implementation PerspectiveCamera : NSObject

- (PerspectiveCamera*) init {
    self = [super init];
    
    if(self) {
        self->position = malloc(sizeof(glm::vec3));
        self->worldUp = malloc(sizeof(glm::vec3));
        self->front = malloc(sizeof(glm::vec3));
        self->right = malloc(sizeof(glm::vec3));
        
        //How I love Objective-C and C++ interop...
        *((glm::vec3*)self->position) = glm::vec3(0.0f, 0.0f, 0.0f);
        *((glm::vec3*)self->worldUp) = glm::vec3(0.0f, 1.0f, 0.0f);
        *((glm::vec3*)self->front) = glm::vec3(0.0f, 0.0f, -1.0f);
        
        self->pitch = 0.0f;
        self->movementSpeed = 2.5f;
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
    
    *((glm::vec3*)self->front)   = glm::normalize(newFront);
    *((glm::vec3*)self->right)   = glm::normalize( glm::cross( *((glm::vec3*)self->front), *((glm::vec3*)self->worldUp) ) );
    *((glm::vec3*)self->worldUp) = glm::normalize( glm::cross( *((glm::vec3*)self->right), *((glm::vec3*)self->front) ) );
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
    
    if((movementType & MovementType::Forward) == MovementType::Forward) {
        *((glm::vec3*)self->position) += *((glm::vec3*)self->front) * velocity;
    }
    
    if((movementType & MovementType::Backward) == MovementType::Backward) {
        *((glm::vec3*)self->position) -= *((glm::vec3*)self->front) * velocity;
    }
    
    if((movementType & MovementType::Left) == MovementType::Left) {
        *((glm::vec3*)self->position) -= *((glm::vec3*)self->right) * velocity;
    }
    
    if((movementType & MovementType::Right) == MovementType::Right) {
        *((glm::vec3*)self->position) += *((glm::vec3*)self->right) * velocity;
    }
    
    [self updateVectors];
}

- (simd_float4x4) getViewMatrix {
    simd_float4x4 matrix;
    
    glm::mat4 perspective = glm::perspective(glm::radians(self->cameraFov), (1600.0f / 1200.0f), 0.1f, 1000.0f);
    glm::mat4 lookAt = glm::lookAt(*((glm::vec3*)self->position), *((glm::vec3*)self->position) + *((glm::vec3*)self->front), *((glm::vec3*)self->worldUp));
    
    lookAt = perspective * lookAt;
    
    memcpy(&matrix, &lookAt, sizeof(simd_float4x4));
    
    return matrix;
}

- (void) setPosition: (simd_float3) position {
    memcpy(self->position, &position, sizeof(simd_float3));
    
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
    
    memcpy(self->position, &returnPosition, sizeof(simd_float3));
    
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

@end
