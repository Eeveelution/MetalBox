//
//  GLTFLoader.h
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 17.01.23.
//

#ifndef GLTFLoader_h
#define GLTFLoader_h

#include <Foundation/Foundation.h>

/* Type definitions come from here! */
/* https://github.com/spnda/fastgltf/blob/main/src/fastgltf_types.hpp */
/* thanks sean! */

typedef enum {
    DataLocationNone = 0,
    DataLocationVectorWithMime,
    DataLocationBufferViewWithMime,
    DataLocationFilePathWithByteRange,
    DataLocationCustomBufferWithId,
} DataLocation;

typedef enum {
    MineTypeNone = 0,
    MineTypeJPEG = 1,
    MineTypePNG = 2,
    MineTypeKTX2 = 3,
    MineTypeDDS = 4,
    MineTypeGltfBuffer = 5,
    MineTypeOctetStream = 6,
} MimeType;

typedef enum {
    AccessorTypeInvalid = 0,
    AccessorTypeScalar  = ( 1 << 8) | 1,
    AccessorTypeVec2    = ( 2 << 8) | 2,
    AccessorTypeVec3    = ( 3 << 8) | 3,
    AccessorTypeVec4    = ( 4 << 8) | 4,
    AccessorTypeMat2    = ( 4 << 8) | 5,
    AccessorTypeMat3    = ( 9 << 8) | 6,
    AccessorTypeMat4    = (16 << 8) | 7,
} AccessorType;

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
} ComponentType;

@interface GLTFDataSource : NSObject {
    unsigned long bufferViewIndex;
    unsigned long fileByteOffset;
    NSString* path;
    unsigned char* bytes;
    MimeType mimeType;
    unsigned long long bufferId;
}

@end

@interface GLTFBuffer : NSObject {
    int byteLength;
    DataLocation dataLocation;
    GLTFDataSource* dataSource;
    NSString* name;
}
@end

@interface GLTFAccessor : NSObject {
    unsigned long byteOffset;
    unsigned long count;
    AccessorType type;
}

@end

@interface GLTFModel : NSObject {
    BOOL parsedSuccessfully;
    NSMutableArray<GLTFBuffer*>* buffers;
}

- (id) initWithData: (void*)data dataSize: (int)size;
- (NSMutableArray<GLTFBuffer*>*) retrieveBuffers;

@end

#endif /* GLTFLoader_h */
