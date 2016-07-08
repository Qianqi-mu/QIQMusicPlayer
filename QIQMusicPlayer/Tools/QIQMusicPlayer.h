//
//  QIQMusicPlayer.h
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVAudioPlayer, QIQSong;

/**
 *  管理歌曲的播放和停止播放
 */
@interface QIQMusicPlayer : NSObject

/**
 *  播放歌曲
 *
 *  @param song 播放的歌曲
 *
 *  @return 播放器
 */
+ (AVAudioPlayer *)playSong:(QIQSong *)song;

/**
 *  暂停播放
 */
+ (void)pausePlayingSong:(QIQSong *)song;

/**
 *  停止播放
 */
+ (void)stopPlayingSong:(QIQSong *)song;



@end
