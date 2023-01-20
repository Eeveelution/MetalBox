//
//  GLTFBuffer.h
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 20.01.23.
//

#ifndef GLTFBuffer_h
#define GLTFBuffer_h

#include "GLTFEnums.h"
#include "GLTFDataSource.h"

@interface GLTFBuffer : NSObject {
    unsigned long byteLength;
    GLTFDataLocation dataLocation;
    GLTFDataSource* dataSource;
    NSString* name;
}

- (void)setByteLength:(unsigned long)byteLength;
- (void)setDataLocation:(GLTFDataLocation)dataLocation;
- (void)setDataSource:(GLTFDataSource*)dataSource;
- (void)setName:(NSString*)name;

- (unsigned long)getByteLength;
- (GLTFDataLocation)getDataLocation;
- (GLTFDataSource*)getDataSource;
- (NSString*)getName;

@end

#endif /* GLTFBuffer_h */
