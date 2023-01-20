//
//  GLTFDataSource.m
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 20.01.23.
//

#import <Foundation/Foundation.h>

#include "GLTFDataSource.h"

@implementation GLTFDataSource

- (void)setBufferViewIndex:(unsigned long)bufferViewIndex {
    self->bufferViewIndex = bufferViewIndex;
}

- (void)setFileByteOffset:(unsigned long)fileByteOffset {
    self->fileByteOffset = fileByteOffset;
}

- (void)setPath:(NSString*)path {
    self->path = path;
}

- (void)setBytes:(unsigned char*)bytes {
    self->bytes = bytes;
}

- (void)setMimeType:(GLTFMimeType)mimeType {
    self->mimeType = mimeType;
}

- (void)setBufferId:(unsigned long long)bufferId {
    self->bufferId = bufferId;
}

- (unsigned long)getBufferViewIndex {
    return self->bufferViewIndex;
}

- (unsigned long)getFileByteOffset {
    return self->fileByteOffset;
}

- (NSString*)getPath {
    return self->path;
}

- (unsigned char*)getBytes {
    return self->bytes;
}

- (GLTFMimeType)getMimeType {
    return self->mimeType;
}

- (unsigned long long)getBufferId {
    return self->bufferId;
}

@end
