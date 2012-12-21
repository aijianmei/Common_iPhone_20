//
//  AudioManager.h
//  Shuriken
//  这里需要AVFoundation.framework, AudioToolbox.framework
//  Created by Orange on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVAudioPlayer;
@class CMOpenALSoundManager;

@interface AudioManager : NSObject {
    AVAudioPlayer* _backgroundMusicPlayer;
    NSMutableArray* _sounds;
    NSMutableDictionary* _soundDic;
    CMOpenALSoundManager* _soundManager;
}
@property (retain, nonatomic) AVAudioPlayer* backgroundMusicPlayer;
@property (retain, nonatomic) NSMutableArray* sounds;
@property (assign, nonatomic) BOOL isSoundOn;
@property (assign, nonatomic) BOOL isMusicOn;
@property (assign, nonatomic) BOOL isBGMPrepared;
@property (assign, nonatomic) BOOL isVibrateOn;
@property (assign, nonatomic) float volume;
+ (AudioManager*)defaultManager;
- (void)saveSoundSettings;
- (void)loadSoundSettings;

//播放短音效的方法。使用前必须使用Initsound的方法把需要的短音效注册好。soundNams音效名的array,建议用wav。
- (void)initSounds:(NSArray*)soundNames;
- (void)playSoundById:(NSInteger)aSoundIndex;

- (void)playSoundByName:(NSString*)soundName;
- (void)playSoundByURL:(NSURL*)url;
- (void)vibrate;

- (void)setBackGroundMusicWithName:(NSString*)aMusicName;
- (BOOL)setBackGroundMusicWithURL:(NSURL*)url;
- (void)backgroundMusicStart;
- (void)backgroundMusicPause;
- (void)backgroundMusicContinue;
- (void)backgroundMusicStop;

- (void)registerSound:(NSString*)soundName;
- (void)registerSoundWithURL:(NSURL*)url;
- (BOOL)hasSound:(NSString*)soundName;
- (BOOL)hasSoundWithURL:(NSURL*)url;


@end
