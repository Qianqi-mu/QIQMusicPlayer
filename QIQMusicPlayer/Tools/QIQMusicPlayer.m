//
//  QIQMusicPlayer.m
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import "QIQMusicPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "QIQSong.h"

/* 用来缓存播放器 */
static NSMutableDictionary *_musicPlayers;

@implementation QIQMusicPlayer

+ (void)initialize {
    _musicPlayers = [NSMutableDictionary dictionary];
}

+ (AVAudioPlayer *)playSong:(QIQSong *)song {
    if (!song) return nil;
    NSString *fileName = song.name;
    AVAudioPlayer *player = _musicPlayers[fileName];
    if (!player) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"mp3"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        if (![player prepareToPlay]) return nil;
        _musicPlayers[fileName] = player;
    }
    if (![player isPlaying]) {
        [player play];
    }
    return player;
}

+ (void)pausePlayingSong:(QIQSong *)song {
    if (!song) return;
    NSString *fileName = song.name;
    AVAudioPlayer *player = _musicPlayers[fileName];
    if (player && [player isPlaying]) {
        [player pause];
    }
}

+ (void)stopPlayingSong:(QIQSong *)song {
    if (!song) return;
    NSString *fileName = song.name;
    AVAudioPlayer *player = _musicPlayers[fileName];
    if (player) {
        [player stop];
        [_musicPlayers removeObjectForKey:fileName];
    }
}

@end
