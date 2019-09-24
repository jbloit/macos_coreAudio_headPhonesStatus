//
//  Audio.m
//  headphonesStatus: check whether headphones are plugged in
//
//  Created by julien@macmini on 23/09/2019.
//  Copyright © 2019 jbloit. All rights reserved.
//
// This is a quick proof oc concept.
// Default device (ie the selected output in system prefs could be differented than built in):
// Check this snippet https://gist.github.com/kyleneideck/67db7999a29046a26a3608edfe82c824 for iterating through devices.
//



#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioServices.h>
#import <Foundation/NSObject.h>
#import "Audio.h"


const AudioObjectPropertyScope kScope                   = kAudioDevicePropertyScopeOutput;
NSString* const __nonnull      kGenericOutputDeviceName = @"Output Device";

@implementation Audio : NSObject{
    AudioObjectPropertyListenerBlock handleHeadphonesStatusChange;
    
}

static Audio *_sharedInstance = nil;



// Singleton reference
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Audio alloc] init];
    });

    [_sharedInstance addOutputDeviceDataSourceListener];
    return _sharedInstance;
}

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

- (void) addOutputDeviceDataSourceListener {

    NSLog(@"Adding listener");
    OSStatus status = noErr;
    AudioDeviceID outputDeviceID = [[self class] defaultOutputDeviceID];
    
    // Read the default output's datasource
    AudioObjectPropertyAddress sourceAddr;
    sourceAddr.mSelector = kAudioDevicePropertyDataSource;
    sourceAddr.mScope = kAudioDevicePropertyScopeOutput;
    sourceAddr.mElement = kAudioObjectPropertyElementMaster;
    
    UInt32 dataSourceId = 0;
    UInt32 dataSourceIdSize = sizeof(UInt32);
    status = AudioObjectGetPropertyData(outputDeviceID, &sourceAddr, 0, NULL, &dataSourceIdSize, &dataSourceId);
    
    
    Audio* __weak weakSelf = self;
    status = AudioObjectAddPropertyListenerBlock(outputDeviceID, &sourceAddr, dispatch_get_main_queue(), ^(UInt32 inNumberAddresses, const AudioObjectPropertyAddress *inAddresses) {
        
        [weakSelf updateHeadphonesState];
    });
    
    
    if (status){
        NSLog(@"Failed to set property listener for device 0x%0x", outputDeviceID);
        return ;
    }
    
}

+(bool)isJackIn;
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
    if (jackIsIn > 0) {

        return YES;
    } else {

        return NO;
    }
}

- (void) updateHeadphonesState {
    //
    NSLog(@"HEADPONES CONNEXION STATE CHANGED");
    
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
            return ;
        }
        if (!AudioObjectHasProperty(outputDeviceID, &propertyAOPA))
        {
            NSLog(@"No  returned jack connection info for device 0x%0x", outputDeviceID);
            return ;
        }
        propertySize = sizeof(UInt32);
        status = AudioObjectGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &jackIsIn);
        
        
        if (status)
        {
            NSLog(@"No  returned jack connection info for device 0x%0x", outputDeviceID);
            return ;
        }
        if (jackIsIn > 0) {
            NSLog(@"JACK IN");

        } else {

            NSLog(@"JACK OUT");
        }
        
        // All instances will be notified
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"JackChanged"
         object:self];
        
    }
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

