//
//  GLTFLoader.h
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 17.01.23.
//

#ifndef GLTFLoader_h
#define GLTFLoader_h

#include <Foundation/Foundation.h>

@interface GLTFModel : NSObject {
    BOOL parsedSuccessfully;
}

- (id) initWithData: (void*)data dataSize: (int)size;

@end

#endif /* GLTFLoader_h */
