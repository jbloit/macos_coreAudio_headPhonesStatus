//
//  Audio.m
//  headphonesStatus
//
//  Created by julien@macmini on 23/09/2019.
//  Copyright © 2019 jbloit. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioServices.h>
#import <Foundation/NSObject.h>
#import "Audio.h"

@implementation Audio : NSObject

+(AudioDeviceID)defaultOutputDeviceID;
{
    AudioDeviceID   outputDeviceID = kAudioObjectUnknown;
    // get output device device
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwarePropertyDefaultOutputDevice;
    if (!AudioObjectHasProperty(kAudioObjectSystemObject, &propertyAOPA))
    {
        NSLog(@"Cannot find default output device!");
        return outputDeviceID;
    }
    propertySize = sizeof(AudioDeviceID);
    status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAOPA, 0, NULL, &propertySize, &outputDeviceID);
    if(status)
    {
        NSLog(@"Cannot find default output device!");
    }
    
    
  

    
    return outputDeviceID;
}

+(Boolean)jackIsIn;
{
    
    UInt32         jackIsIn;
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioDevicePropertyJackIsConnected;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    AudioDeviceID outputDeviceID = [[self class] defaultOutputDeviceID];
    if (outputDeviceID == kAudioObjectUnknown)
    {
        NSLog(@"Unknown device");
        return NO;
    }
    if (!AudioObjectHasProperty(outputDeviceID, &propertyAOPA))
    {
        NSLog(@"No  returned jack connection info for device 0x%0x", outputDeviceID);
        return NO;
    }
    propertySize = sizeof(UInt32);
    status = AudioObjectGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &jackIsIn);
    
    
    if (status)
    {
        NSLog(@"No  returned jack connection info for device 0x%0x", outputDeviceID);
        return NO;
    }
    if (jackIsIn > 0) return YES;
    return NO;
    
    
}


+(float)volume
{
    Float32         outputVolume;
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    AudioDeviceID outputDeviceID = [[self class] defaultOutputDeviceID];
    if (outputDeviceID == kAudioObjectUnknown)
    {
        NSLog(@"Unknown device");
        return 0.0;
    }
    if (!AudioObjectHasProperty(outputDeviceID, &propertyAOPA))
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    propertySize = sizeof(Float32);
    status = AudioObjectGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &outputVolume);
    
    
    if (status)
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    if (outputVolume < 0.0 || outputVolume > 1.0) return 0.0;
    return outputVolume;
}

+(bool)mute
{
    UInt32 mute;
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioDevicePropertyMute;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    AudioDeviceID outputDeviceID = [[self class] defaultOutputDeviceID];
    if (outputDeviceID == kAudioObjectUnknown)
    {
        NSLog(@"Unknown device");
        return 0.0;
    }
    if (!AudioObjectHasProperty(outputDeviceID, &propertyAOPA))
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    propertySize = sizeof(UInt32);
    status = AudioObjectGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &mute);
    if (status)
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    return mute;
}
+(float)effective_volume
{
    return [[self class] volume] * (![[self class] mute]);
}

@end

