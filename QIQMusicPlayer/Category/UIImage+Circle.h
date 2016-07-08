
//
//  UIImage+Circle.h
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  修改图片样式（包括切圆、修改图片尺寸）
 */
@interface UIImage (Circle)

/**
 *  根据指定图片的文件名获取一张圆形的图片，并添加边框
 *
 *  @param name        图片文件名
 *  @param borderWidth 边框的宽度
 *  @param borderColor 边框的颜色
 *
 *  @return 切好的圆形图片
 */
+ (UIImage *)circleImageWithImageName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

+ (UIImage *)circleImageWithImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

/**
 *  将一张图片重新绘制成指定大小的图片
 *
 *  @param name 原图片的文件名
 *  @param size 指定的大小
 *
 *  @return 重绘好后的图片
 */
+ (UIImage *)redrawImageWithImageName:(NSString *)name scaleToSize:(CGSize)size;

@end
