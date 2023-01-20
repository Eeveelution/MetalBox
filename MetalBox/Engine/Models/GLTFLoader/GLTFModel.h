//
//  GLTFLoader.h
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 17.01.23.
//

#ifndef GLTFModel_h
#define GLTFModel_h

#include <Foundation/Foundation.h>

#include "GLTFBuffer.h"

/* Type definitions come from here! */
/* https://github.com/spnda/fastgltf/blob/main/src/fastgltf_types.hpp */
/* thanks sean! */

@interface GLTFAccessor : NSObject {
    unsigned long byteOffset;
    unsigned long count;
    GLTFAccessorType type;
}

- setByteOffset:(unsigned long)byteOffset;
- (unsigned long)getByteOffset;

- setCount:(unsigned long)count;
- (unsigned long)getCount;

@end

@interface GLTFModel : NSObject {
    BOOL parsedSuccessfully;
    NSMutableArray<GLTFBuffer*>* buffers;
}

- (id) initWithData: (void*)data dataSize: (int)size;
- (NSMutableArray<GLTFBuffer*>*) retrieveBuffers;

@end


#endif /* GLTFLoader_h */
