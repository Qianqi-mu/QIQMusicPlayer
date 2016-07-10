//
//  UIScreen+Sizes.h
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/10.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  用于计算当前设备屏幕的尺寸、Retina倍率
 */
@interface UIScreen (Sizes)

+ (float)screenWidth;
+ (float)screenHeight;
+ (BOOL)isRetina;
+ (float)scale;

@end
