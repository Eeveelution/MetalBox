//
//  GLTFLoader.m
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 17.01.23.
//

#import <Foundation/Foundation.h>

#include "GLTFModel.h"

#include "../../fastgltf/src/fastgltf_parser.hpp"
#include "../../fastgltf/src/fastgltf_types.hpp"

#include <iostream>

@implementation GLTFModel

- (id) initWithData: (void*)data dataSize: (int)size; {
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
    
    
    
    return self;
}

@end
