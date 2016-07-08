//
//  QIQSong.h
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIQSong : NSObject

/* 歌曲名 */
@property (nonatomic, copy) NSString *name;

/* 歌曲文件名 */
@property (nonatomic, copy) NSString *filename;

/* 歌词文件名 */
@property (nonatomic, copy) NSString *lrcname;

/* 歌手 */
@property (nonatomic, copy) NSString *singer;

/* 歌手头像 */
@property (nonatomic, copy) NSString *singerIcon;

/* 歌曲背景图标 */
@property (nonatomic, copy) NSString *icon;

@end
