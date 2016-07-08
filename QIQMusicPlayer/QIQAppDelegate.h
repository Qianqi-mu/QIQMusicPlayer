//
//  AppDelegate.h
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QIQMusicPlayingViewController.h"

@interface QIQAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) QIQMusicPlayingViewController *playingVC;

@end

