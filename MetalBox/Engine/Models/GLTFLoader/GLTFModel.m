//
//  GLTFLoader.m
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 17.01.23.
//

#import <Foundation/Foundation.h>

#include "../../../fastgltf/src/fastgltf_parser.hpp"
#include "../../../fastgltf/src/fastgltf_types.hpp"

#include "GLTFModel.h"
#include "GLTFDataSource.h"

#include <iostream>

@implementation GLTFModel

- (id) initWithData: (void*)data dataSize: (int)size; {
    self = [super init];
    
    fastgltf::GltfDataBuffer buffer;
    fastgltf::Parser parser;
    
    buffer.fromByteView((uint8_t*) data, size, fastgltf::getGltfBufferPadding());
    
    std::unique_ptr<fastgltf::glTF> gltf = parser.loadGLTF(&buffer, std::filesystem::current_path());
    
    if(parser.getError() != fastgltf::Error::None) {
        std::cout << "Failed to load GLTF Asset!" << std::endl;
        self->parsedSuccessfully = false;
    }
    
    if(gltf->parse() != fastgltf::Error::None) {
        std::cout << "Failed to load GLTF Asset!" << std::endl;
        self->parsedSuccessfully = true;
    }
    
    std::unique_ptr<fastgltf::Asset> asset = gltf->getParsedAsset();
    
    self->buffers = [NSMutableArray alloc];
    
    for(int i = 0; i != asset->buffers.size(); i++) {
        fastgltf::Buffer currentBuffer = asset->buffers[i];
        
        GLTFBuffer* cBuffer = [[GLTFBuffer alloc] init];
        
        [cBuffer setName: @(currentBuffer.name.data()) ];
        [cBuffer setByteLength: currentBuffer.byteLength ];
        [cBuffer setDataLocation: (GLTFDataLocation)currentBuffer.location ];
        
        GLTFDataSource* cSource = [[GLTFDataSource alloc] init];
        
        [cSource setFileByteOffset: currentBuffer.data.fileByteOffset ];
        [cSource setPath: @(currentBuffer.data.path.string().data()) ];
        [cSource setBytes: currentBuffer.data.bytes.data()] ;
        [cSource setBufferId: currentBuffer.data.bufferId ];
        [cSource setMimeType: (GLTFMimeType)currentBuffer.data.mimeType ];
        [cSource setBufferViewIndex: currentBuffer.data.bufferViewIndex ];

        [cBuffer setDataSource: cSource];
        
        [self->buffers addObject: cBuffer];
    }
    
    return self;
}

- (NSMutableArray<GLTFBuffer*>*) retrieveBuffers {
    return self->buffers;
}

@end
