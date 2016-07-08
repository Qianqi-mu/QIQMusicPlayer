//
//  QIQMusicCell.m
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import "QIQSongCell.h"
#import "QIQSong.h"
#import "UIImage+Circle.h"

@implementation QIQSongCell

- (void)setSong:(QIQSong *)song {
    _song = song;
    self.textLabel.text = song.name;
    self.detailTextLabel.text = song.singer;
    UIImage *image =  [UIImage redrawImageWithImageName:song.singerIcon scaleToSize:CGSizeMake(self.bounds.size.height - 10, self.bounds.size.height - 10)];
    self.imageView.image = [UIImage circleImageWithImage:image borderWidth:0.5 borderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
}

@end
