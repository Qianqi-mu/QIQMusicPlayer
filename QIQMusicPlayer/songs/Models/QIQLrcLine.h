//
//  QIQLrc.h
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIQLrcLine : NSObject

/* 某一行歌词的内容 */
@property (nonatomic, copy) NSString *words;

/* 这一行歌词对应的时间 */
@property (nonatomic, copy) NSString *time;

@end
