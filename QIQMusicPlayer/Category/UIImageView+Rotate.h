
//
//  UIImageView+Rotate.h
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Rotate)

-(void)rotateWithTimeInterval:(NSTimeInterval)duration;

-(void)stopRotation;

@end
