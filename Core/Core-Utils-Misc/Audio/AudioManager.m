//
//  AudioManager.m
//  Shuriken
//
//  Created by Orange on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PPDebug.h"

#import "MusicItem.h"
#import "CMOpenALSoundManager.h"


AudioManager* backgroundMusicManager;
AudioManager* soundManager;

static AudioManager* globalGetAudioManager()
{
    if (backgroundMusicManager == nil) {
        backgroundMusicManager = [[AudioManager alloc] init];
        [backgroundMusicManager loadSoundSettings];
    }
    return backgroundMusicManager;
}

@implementation AudioManager
@synthesize backgroundMusicPlayer = _backgroundMusicPlayer;
@synthesize sounds = _sounds;
@synthesize isSoundOn = _isSoundOn;
@synthesize isMusicOn = _isMusicOn;
@synthesize isBGMPrepared = _isBGMPrepared;
@synthesize volume = _volume;
@synthesize isVibrateOn = _isVibrateOn;

- (void)setBackGroundMusicWithName:(NSString*)aMusicName
{
    NSString* name;
    NSString* type;
    NSString *soundFilePath;
    NSArray* nameArray = [aMusicName componentsSeparatedByString:@"."];
    if ([nameArray count] == 2) {
        name = [nameArray objectAtIndex:0];
        type = [nameArray objectAtIndex:1];
        soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    } else {
        soundFilePath = [[NSBundle mainBundle] pathForResource:aMusicName ofType:@"m4a"];
    }
    if (_isBGMPrepared && [self.backgroundMusicPlayer isPlaying]) {
        [self.backgroundMusicPlayer stop];
    }
    if (soundFilePath) {
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        NSError* error = nil;
        if (![soundFileURL isEqual:self.backgroundMusicPlayer.url]) {
            AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
            self.backgroundMusicPlayer = player;
            [player release];
            if (!error){
                PPDebug(@"<AudioManager>Init audio player successfully, sound file %@", soundFilePath);
                self.backgroundMusicPlayer.numberOfLoops = -1; //infinite
                self.isBGMPrepared = YES;
                //下面的代码要解释一下：这里在设定背景音乐之后无论音乐开关都会播放，不过如果开关是关掉的话是以音量为0播放。至于原因：因为如果不这样做，那么第一次点击音乐开关的时候要等N久才能打开，用户会感觉相当困扰
                if (!_isMusicOn)
                    self.volume = 0.0;
                [self.backgroundMusicPlayer play];
            }
            else {
                PPDebug(@"<AudioManager>Fail to init audio player with sound file%@, error = %@", soundFilePath, [error description]);
                self.isBGMPrepared = NO;
                self.backgroundMusicPlayer = nil;
            }
        }
    }
    
}

- (BOOL)setBackGroundMusicWithURL:(NSURL*)url
{
    if (_isBGMPrepared && [self.backgroundMusicPlayer isPlaying]) {
        [self.backgroundMusicPlayer stop];
    }
    if (url == nil) {
        return NO;
    }
    NSError* error = nil;
    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.backgroundMusicPlayer = player;
    [player release];
    
    if (!error){
        PPDebug(@"<AudioManager>Init audio player successfully, sound file %@", url);
        self.backgroundMusicPlayer.numberOfLoops = -1; //infinite
        self.isBGMPrepared = YES;
        //下面的代码要解释一下：这里在设定背景音乐之后无论音乐开关都会播放，不过如果开关是关掉的话是以音量为0播放。至于原因：因为如果不这样做，那么第一次点击音乐开关的时候要等N久才能打开，用户会感觉相当困扰
        if (!_isMusicOn)
            self.volume = 0.0;
        [self.backgroundMusicPlayer play];
        return YES;
    }
    else {
        PPDebug(@"<AudioManager>Fail to init audio player with sound file%@, error = %@", url, [error description]);
        self.isBGMPrepared = NO;
        self.backgroundMusicPlayer = nil;
        return NO;
    }
    return NO;
}


- (void)initSounds:(NSArray*)soundNames
{
//    SystemSoundID soundId;
//    for (NSString* soundName in soundNames) {
//        NSString* name;
//        NSString* type;
//        NSString *soundFilePath;
//        NSArray* nameArray = [soundName componentsSeparatedByString:@"."];
//        if ([nameArray count] == 2) {
//            name = [nameArray objectAtIndex:0];
//            type = [nameArray objectAtIndex:1];
//            soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
//        } else {
//            soundFilePath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"WAV"];
//        }
//        if (soundFilePath) {
//            NSURL* soundURL = [NSURL fileURLWithPath:soundFilePath];
//            
//            //Register sound file located at that URL as a system sound
//            OSStatus err = AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &soundId);
//            [self.sounds addObject:[NSNumber numberWithInt:soundId]];
//            [_soundDic setObject:[NSNumber numberWithInt:soundId] forKey:soundName];
//            if (err != kAudioServicesNoError) {
//                PPDebug(@"<AudioManager>Could not load %@, error code: %ld", soundURL, err);
//            } else {
//                PPDebug(@"<AudioManager> load sound %@ success", soundName);
//            }
//        } else {
//            PPDebug(@"<AudioManager> sound %@ do not exist", soundName);
//        }
//    }
    [_soundManager setSoundFileNames:[NSMutableArray arrayWithArray:soundNames]];
}

- (void)registerSound:(NSString*)soundName
{
    if ([soundName hasSuffix:@"m4a"]) {
        SystemSoundID soundId;
        NSString* name;
        NSString* type;
        NSString *soundFilePath;
        NSArray* nameArray = [soundName componentsSeparatedByString:@"."];
        if ([nameArray count] == 2) {
            name = [nameArray objectAtIndex:0];
            type = [nameArray objectAtIndex:1];
            soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
        } else {
            soundFilePath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"WAV"];
        }
        if (soundFilePath) {
            NSURL* soundURL = [NSURL fileURLWithPath:soundFilePath];
            
            //Register sound file located at that URL as a system sound
            OSStatus err = AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &soundId);
            [self.sounds addObject:[NSNumber numberWithInt:soundId]];
            [_soundDic setObject:[NSNumber numberWithInt:soundId] forKey:soundName];
            if (err != kAudioServicesNoError) {
                PPDebug(@"<AudioManager>Could not load %@, error code: %ld", soundURL, err);
            } else {
                PPDebug(@"<AudioManager> load sound %@ success", soundName);
            }
        } else {
            PPDebug(@"<AudioManager> sound %@ do not exist", soundName);
        }
    } else {
        int soundId = _soundManager.soundFileNames.count;
        [_soundManager.soundFileNames addObject:soundName];
        [_soundDic setObject:[NSNumber numberWithInt:soundId] forKey:soundName];
    }
    
}

- (void)registerSoundWithURL:(NSURL*)url
{
    SystemSoundID soundId;
    if (url) {
        NSURL* soundURL = url;
        
        //Register sound file located at that URL as a system sound
        OSStatus err = AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &soundId);
        [self.sounds addObject:[NSNumber numberWithInt:soundId]];
        [_soundDic setObject:[NSNumber numberWithInt:soundId] forKey:soundURL];
        if (err != kAudioServicesNoError) {
            PPDebug(@"<AudioManager>Could not load %@, error code: %ld", [soundURL description], err);
        } else {
            PPDebug(@"<AudioManager> load sound %@ success", [soundURL description]);
        }
    } else {
        PPDebug(@"<AudioManager> sound %@ do not exist", [url description]);
    }
}

- (BOOL)hasSound:(NSString*)soundName
{
    return ([_soundDic objectForKey:soundName] != nil);
}

- (BOOL)hasSoundWithURL:(NSURL*)url
{
    return ([_soundDic objectForKey:url] != nil);    
}

- (id)init
{
    self = [super init];
    if (self) {
        _sounds = [[NSMutableArray alloc] init];
        _soundDic = [[NSMutableDictionary alloc] init];
        _soundManager = [[CMOpenALSoundManager alloc] init];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_backgroundMusicPlayer);
    PPRelease(_sounds);
    PPRelease(_soundDic);
    [super dealloc];
}

+ (AudioManager*)defaultManager
{
    return globalGetAudioManager();
}

- (void)playSoundById:(NSInteger)aSoundIndex
{
    if (self.isSoundOn) {
//        if (aSoundIndex < 0 || aSoundIndex >= [self.sounds count]){
//            PPDebug(@"<playSoundById> but sound index (%d) out of range", aSoundIndex);
//            return;
//        }
//
//        NSNumber* num = [self.sounds objectAtIndex:aSoundIndex];
//        SystemSoundID soundId = num.intValue;
//        AudioServicesPlaySystemSound(soundId);
//        PPDebug(@"<AudioManager>play sound-%d, systemId=%d", aSoundIndex, num.intValue);
        [_soundManager playSoundWithID:aSoundIndex];
        
        
    }
}

- (void)playSoundByName:(NSString*)soundName
{
    if (![self hasSound:soundName] && soundName!= nil) {
        [self registerSound:soundName];
    }
    if (self.isSoundOn) {
        if ([soundName hasSuffix:@"m4a"]) {
            NSNumber* soundIdNumber = [_soundDic objectForKey:soundName];
            if (soundIdNumber) {
                SystemSoundID soundId = soundIdNumber.intValue;
                AudioServicesPlaySystemSound(soundId);
                PPDebug(@"<AudioManager>play sound-%@, systemId=%d", soundName, soundIdNumber.intValue);
            } else {
                PPDebug(@"<playSoundByName> sound %@ not found", soundName);
            }
        } else {
            [_soundManager playSoundWithSoundFile:soundName];
        }
    }
}

- (void)playSoundByURL:(NSURL*)url
{
    if (![self hasSoundWithURL:url]) {
        [self registerSoundWithURL:url];
    }
    if (self.isSoundOn) {
        if ([[[url absoluteString] pathExtension] isEqualToString:@"m4a"]) {
            NSNumber* soundIdNumber = [_soundDic objectForKey:url];
            if (soundIdNumber) {
                SystemSoundID soundId = soundIdNumber.intValue;
                AudioServicesPlaySystemSound(soundId);
                PPDebug(@"<playSoundByURL> sound=%@, systemId=%d", [url description], soundIdNumber.intValue);
            } else {
                PPDebug(@"<playSoundByURL> sound %@ not found", [url description]);
            }
        } else {
            [_soundManager playSoundWithSoundFileUrl:url];
        }
    }
}

- (void)backgroundMusicStart
{
    //[self setBackGroundMusicWithName:@"sword.mp3"];
    if (self.isBGMPrepared && _isMusicOn) {
        [self.backgroundMusicPlayer play];
    } else {
        PPDebug(@"<AudioManager> Background music has not prepared");
    }
    
}

- (void)backgroundMusicPause
{
    //[self.backgroundMusicPlayer pause];
    if (self.isBGMPrepared) {
        [self.backgroundMusicPlayer pause];
    } else {
        PPDebug(@"<AudioManager> Background music has not prepared");
    }
}

- (void)backgroundMusicContinue
{
    //[self.backgroundMusicPlayer play];
    if (self.isBGMPrepared && _isMusicOn) {
        [self.backgroundMusicPlayer play];
    } else {
        PPDebug(@"<AudioManager> Background music has not prepared");
    }
}

- (void)backgroundMusicStop
{
    //[self.backgroundMusicPlayer stop];
    if (self.isBGMPrepared) {
        [self.backgroundMusicPlayer stop];
    } else {
        PPDebug(@"<AudioManager> Background music has not prepared");
    }
}

- (void)vibrate
{
    if (_isVibrateOn) {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }
}
#define SOUND_SWITCHER @"sound_switcher"
#define MUSIC_SWITCHER @"music_switcher"
#define MUSIC_VOLUME    @"music_volume"
- (void)saveSoundSettings
{
    NSNumber* soundSwitcher = [NSNumber numberWithBool:self.isSoundOn];
    NSNumber* musicSwitcher = [NSNumber numberWithBool:self.isMusicOn];
    NSNumber* volume = [NSNumber numberWithFloat:self.volume];
    [[NSUserDefaults standardUserDefaults] setObject:soundSwitcher forKey:SOUND_SWITCHER];
    [[NSUserDefaults standardUserDefaults] setObject:musicSwitcher forKey:MUSIC_SWITCHER];
    [[NSUserDefaults standardUserDefaults] setObject:volume forKey:MUSIC_VOLUME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadSoundSettings
{
    NSNumber* soundSwitcher = [[NSUserDefaults standardUserDefaults] objectForKey:SOUND_SWITCHER];
    NSNumber* musicSwitcher = [[NSUserDefaults standardUserDefaults] objectForKey:MUSIC_SWITCHER];
    NSNumber* volume = [[NSUserDefaults standardUserDefaults] objectForKey:MUSIC_VOLUME];
    if (soundSwitcher) {
        self.isSoundOn = soundSwitcher.boolValue;
    } else {
        self.isSoundOn = YES;
    }
    if (musicSwitcher) {
        _isMusicOn = musicSwitcher.boolValue;
    } else {
        self.isMusicOn = YES;
    }
    if (volume) {
        self.volume = volume.floatValue;
    } else {
        self.volume = 1;
    }
}

- (void)setIsMusicOn:(BOOL)isMusicOn 
{
    _isMusicOn = isMusicOn;
    if (isMusicOn) {
        if (self.volume <= 0) {
            self.volume = 0.5;
        }
        [self backgroundMusicStart];
    } else {
        [self backgroundMusicPause];
    }
    [self saveSoundSettings];
}

- (void)setVolume:(float)volume
{
    _volume = volume;
    if (volume >= 0 && volume <= 1 && self.isBGMPrepared) {
        self.backgroundMusicPlayer.volume = volume;
    } else {
        PPDebug(@"<AudioManager> backgroundMusicPlayer not prepared or volume %.2f out of range! ", volume);
    }
}

//- (float)volume
//{
//    if (self.backgroundMusicPlayer != nil && self.isBGMPrepared) {
//         return self.backgroundMusicPlayer.volume;
//    } else {
//        PPDebug(@"<AudioManager> Background music has not prepared");
//    }
//    return 0;
//   
//}

@end
