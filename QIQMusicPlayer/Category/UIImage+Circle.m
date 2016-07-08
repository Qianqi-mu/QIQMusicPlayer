//
//  UIImage+Circle.m
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import "UIImage+Circle.h"

@implementation UIImage (Circle)

+ (UIImage *)circleImageWithImageName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    return [self circleImageWithImage:[UIImage imageNamed:name] borderWidth:borderWidth borderColor:borderColor];
}

+ (UIImage *)circleImageWithImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    UIImage *sourceImage = image;
    CGFloat imageWidth = sourceImage.size.width + 2*borderWidth;
    CGFloat imageHeight = sourceImage.size.height + 2*borderWidth;
    
    //1.开启上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageWidth, imageHeight), NO, 0);
    UIGraphicsGetCurrentContext();
    
    //2.在指定区域画圆
    CGPoint centerPoint = CGPointMake(imageWidth*0.5, imageHeight*0.5);
    CGFloat radius = imageWidth < imageHeight ? (imageWidth*0.5 - borderWidth) : (imageHeight*0.5 - borderWidth);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    bezierPath.lineWidth = borderWidth;
    [borderColor setStroke];
    [bezierPath stroke];
    //裁剪掉多余部分
    [bezierPath addClip];
    
    //3.在裁剪好的圆中重新绘制图片
    [sourceImage drawInRect:CGRectMake(borderWidth, borderWidth, sourceImage.size.width, sourceImage.size.height)];
    
    //4.从内存中获取重绘好新图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}


+ (UIImage *)redrawImageWithImageName:(NSString *)name scaleToSize:(CGSize)size {
    UIImage *sourceImage = [UIImage imageNamed:name];
    UIGraphicsBeginImageContext(size);
    [sourceImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
