//
//  UIImageView+Rotate.m
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import "UIImageView+Rotate.h"

static NSString *const kRotationAnimationKey = @"UIImageViewRotation";

@implementation UIImageView (Rotate)

-(void)rotateWithTimeInterval:(NSTimeInterval)duration {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI*2);
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = 214783647;
    rotationAnimation.removedOnCompletion =NO;
    rotationAnimation.fillMode = kCAFillModeBackwards;
    [self.layer addAnimation:rotationAnimation forKey:kRotationAnimationKey];
}

-(void)stopRotation {
    [self.layer removeAnimationForKey:kRotationAnimationKey];
}

@end
