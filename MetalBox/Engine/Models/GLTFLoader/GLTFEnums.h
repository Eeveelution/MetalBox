//
//  GLTFEnums.h
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 20.01.23.
//

#ifndef GLTFEnums_h
#define GLTFEnums_h

#include <Foundation/Foundation.h>

typedef enum {
    DataLocationNone = 0,
    DataLocationVectorWithMime,
    DataLocationBufferViewWithMime,
    DataLocationFilePathWithByteRange,
    DataLocationCustomBufferWithId,
} GLTFDataLocation;

typedef enum {
    MineTypeNone = 0,
    MineTypeJPEG = 1,
    MineTypePNG = 2,
    MineTypeKTX2 = 3,
    MineTypeDDS = 4,
    MineTypeGltfBuffer = 5,
    MineTypeOctetStream = 6,
} GLTFMimeType;

typedef enum {
    AccessorTypeInvalid = 0,
    AccessorTypeScalar  = ( 1 << 8) | 1,
    AccessorTypeVec2    = ( 2 << 8) | 2,
    AccessorTypeVec3    = ( 3 << 8) | 3,
    AccessorTypeVec4    = ( 4 << 8) | 4,
    AccessorTypeMat2    = ( 4 << 8) | 5,
    AccessorTypeMat3    = ( 9 << 8) | 6,
    AccessorTypeMat4    = (16 << 8) | 7,
} GLTFAccessorType;

typedef enum {
    ComponentTypeInvalid         = 0,
    ComponentTypeByte            = ( 8 << 16) | 5120,
    ComponentTypeUnsignedByte    = ( 8 << 16) | 5121,
    ComponentTypeShort           = (16 << 16) | 5122,
    ComponentTypeUnsignedShort   = (16 << 16) | 5123,
    ComponentTypeInt             = (32 << 16) | 5124,
    ComponentTypeUnsignedInt     = (32 << 16) | 5125,
    ComponentTypeFloat           = (32 << 16) | 5126,
    ComponentTypeDouble          = (64 << 16) | 5130,
} GLTFComponentType;

#endif /* GLTFEnums_h */
