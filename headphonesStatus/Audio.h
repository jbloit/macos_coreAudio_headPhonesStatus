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
+(AudioDeviceID)defaultOutputDeviceID;
+(float)volume;
+(bool)mute;
+(float)effective_volume;
+(Boolean)jackIsIn;
@end


#endif /* Audio_h */
