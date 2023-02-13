//
//  AssimpBridge.h
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 22.01.23.
//

#include <assimp/cimport.h>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <assimp/types.h>
#include <assimp/config.h>
#include <assimp/vector2.h>

#include <Foundation/Foundation.h>

NSString* aiStringToString(struct aiString* str) {
    return [[NSString alloc] initWithBytes: str->data length: str->length encoding: NSUTF8StringEncoding];
}

#include "Engine/MathHelpers/PerspectiveCamera.h"
#include "Engine/Models/StbiImageLoader.h"

