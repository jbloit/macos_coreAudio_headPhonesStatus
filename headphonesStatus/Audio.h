//
//  Audio.h
//  headphonesStatus
//
//  Created by julien@macmini on 23/09/2019.
//  Copyright © 2019 jbloit. All rights reserved.
//

#ifndef Audio_h
#define Audio_h

#import <Foundation/NSObject.h>
#import <AudioToolbox/AudioServices.h>

@interface Audio : NSObject
{

}

+ (instancetype) shared;
+(AudioDeviceID)defaultOutputDeviceID;
+(float)volume;
+(bool)mute;
+(float)effective_volume;
+(bool)isJackIn;
@end


#endif /* Audio_h */
