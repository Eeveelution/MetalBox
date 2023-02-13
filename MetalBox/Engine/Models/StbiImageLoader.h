//
//  StbiImageLoader.h
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 11.02.23.
//

#ifndef StbiImageLoader_h
#define StbiImageLoader_h


@interface STBIImageLoader : NSObject

+ (unsigned char*) loadData: (void*) data
                   dataSize: (unsigned int) dataSize
                   widthPtr: (int*) widthPtr
                  heightPtr: (int*) heightPtr
                 channelPtr: (int*) channelPtr
            desiredChannels: (unsigned int) desiredChannels;
@end

#endif /* StbiImageLoader_h */
