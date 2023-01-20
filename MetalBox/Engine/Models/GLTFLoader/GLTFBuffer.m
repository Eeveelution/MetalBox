//
//  GLTFBuffer.m
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 20.01.23.
//

#import <Foundation/Foundation.h>

#include "GLTFBuffer.h"

@implementation GLTFBuffer

- (void)setByteLength:(unsigned long)byteLength{
    self->byteLength = byteLength;
}

- (void)setDataLocation:(GLTFDataLocation)dataLocation {
    self->dataLocation = dataLocation;
}

- (void)setDataSource:(GLTFDataSource*)dataSource {
    self->dataSource = dataSource;
}

- (void)setName:(NSString*)name {
    self->name = name;
}

- (unsigned long)getByteLength {
    return self->byteLength;
}

- (GLTFDataLocation)getDataLocation {
    return self->dataLocation;
}

- (GLTFDataSource*)getDataSource {
    return self->dataSource;
}

- (NSString*)getName {
    return self->name;
}

@end
