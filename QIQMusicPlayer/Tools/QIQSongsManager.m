//
//  QIQSongsManager.m
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import "QIQSongsManager.h"
#import "MJExtension.h"
#import "QIQSong.h"

@interface QIQSongsManager ()


@end

/* 歌单中的所有歌曲 */
static NSArray * _songs = nil;

/* 正在播放的那首歌曲 */
static QIQSong *_playingSong = nil;

@implementation QIQSongsManager

#pragma mark - 公共接口
+ (NSArray *)songs {
    if (!_songs) {
        _songs = [QIQSong mj_objectArrayWithFilename:@"Musics.plist"];
    }
    return _songs;
}

+ (QIQSong *)playingSong {
    return _playingSong;
}

+ (void)selectPlayingSong:(QIQSong *)playingSong {
    if (!playingSong || ![_songs containsObject:playingSong]) return;
    _playingSong = playingSong;
}

+ (QIQSong *)previousSong {
    NSInteger index = 0;
    if (_playingSong) {
        index = [_songs indexOfObject:_playingSong];
        index--;
        if (index < 0) {
            index = _songs.count - 1;
        }
    }
    return _songs[index];
}

+ (QIQSong *)nextSong {
    NSInteger index = 0;
    if (_playingSong) {
        index = [_songs indexOfObject:_playingSong];
        index++;
        if (index > _songs.count-1) {
            index = 0;
        }
    }
    return _songs[index];
}

@end
