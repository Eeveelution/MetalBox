//
//  GLTFDataSource.m
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 20.01.23.
//

#import <Foundation/Foundation.h>

#include "GLTFEnums.h"

@interface GLTFDataSource : NSObject {
    unsigned long bufferViewIndex;
    unsigned long fileByteOffset;
    NSString* path;
    unsigned char* bytes;
    GLTFMimeType mimeType;
    unsigned long long bufferId;
}

- (void)setBufferViewIndex:(unsigned long)bufferViewIndex;

@end
