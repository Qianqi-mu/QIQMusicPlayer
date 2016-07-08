//
//  QIQMusicPlayingViewController.h
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QIQMusicPlayingViewController : UIViewController

/**
 *  创建音乐播放界面单例
 */
+ (QIQMusicPlayingViewController *)sharedPlayingViewController;

/**
 *  显示播放界面
 */
- (void)show;

/**
 *  隐藏播放界面
 */
- (void)hide;

@end
