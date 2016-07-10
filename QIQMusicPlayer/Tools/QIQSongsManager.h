//
//  QIQSongsManager.h
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

/**
 *  QIQSongsManager负责管理整个歌单，监听正在播放的歌曲，设置当前需要播放的歌曲，监测下一首歌曲、上一首歌曲
 */
#import <Foundation/Foundation.h>

@class QIQSong;

@interface QIQSongsManager : NSObject

/**
 *  返回歌单上的歌曲
 */
+ (NSArray *)songs;

/**
 *  返回正在播放的歌曲
 */
+ (QIQSong *)playingSong;

/**
 *  从歌单上选择将要播放的歌曲，并将其设置为正在播放的歌曲
 *
 *  @param playingSong 从歌单上选中的歌曲
 *
 *  @return 正在播放的歌曲
 */
+ (void)selectPlayingSong:(QIQSong *)playingSong;

/**
 *  返回当前正在播放歌曲的前一首歌曲
 */
+ (QIQSong *)previousSong;

/**
 *  返回当前正在播放歌曲的下一首歌曲
 */
+ (QIQSong *)nextSong;

/**
 *  返回随机播放模式下一首/上一首歌
 */
+ (QIQSong *)randomSong;

@end
