//
//  QIQLrcView.h
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  展示歌词的视图控件
 */
@interface QIQLrcView : UIView

@property (nonatomic, copy) NSString *lrcName;

@property (nonatomic, assign) NSTimeInterval currentTime;

@end
