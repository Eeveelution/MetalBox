//
//  GlmBridge.m
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 06.02.23.
//

#import <Foundation/Foundation.h>
#import <simd/matrix.h>
#import <simd/matrix_types.h>

#include "PerspectiveCamera.h"

#include "../../../glm/glm/glm.hpp"

@implementation PerspectiveCamera : NSObject

- (PerspectiveCamera*) init {
    self = [super init];
    
    if(self) {
        
    }
    
    return self;
}

@end
