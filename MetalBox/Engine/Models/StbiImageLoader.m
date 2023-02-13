//
//  StbiImageLoader.m
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 11.02.23.
//

#import <Foundation/Foundation.h>

#include "StbiImageLoader.h"

#define STB_IMAGE_IMPLEMENTATION

#include "../../../stb/stb_image.h"

@implementation STBIImageLoader

+ (unsigned char*) loadData: (void*) data
                   dataSize: (unsigned int) dataSize
                   widthPtr: (int*) widthPtr
                  heightPtr: (int*) heightPtr
                 channelPtr: (int*) channelPtr
            desiredChannels: (unsigned int) desiredChannels
{
    return stbi_load_from_memory(data, dataSize, widthPtr, heightPtr, channelPtr, desiredChannels);
}

@end
