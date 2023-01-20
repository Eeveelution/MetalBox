//
//  GLTFDataSource.h
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 20.01.23.
//

#ifndef GLTFDataSource_h
#define GLTFDataSource_h

#include <Foundation/Foundation.h>
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
- (void)setFileByteOffset:(unsigned long)fileByteOffset;
- (void)setPath:(NSString*)path;
- (void)setBytes:(unsigned char*)bytes;
- (void)setMimeType:(GLTFMimeType)mimeType;
- (void)setBufferId:(unsigned long long)bufferId;

- (unsigned long)getBufferViewIndex;
- (unsigned long)getFileByteOffset;
- (NSString*)getPath;
- (unsigned char*)getBytes;
- (GLTFMimeType)getMimeType;
- (unsigned long long)getBufferId;

@end

#endif /* GLTFDataSource_h */
