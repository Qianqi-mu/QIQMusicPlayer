//
//  QIQMusicListTableViewController.m
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import "QIQSongListTableViewController.h"
#import "QIQsong.h"
#import "QIQSongCell.h"
#import "QIQSongsManager.h"

#import "QIQAppDelegate.h"

//设置颜色
#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)(rgbValue & 0x0000FF))/255.0 alpha:alphaValue]

@interface QIQSongListTableViewController ()

@property (nonatomic ,strong) NSArray *songs;

@end

@implementation QIQSongListTableViewController

- (NSArray *)songs {
    if (!_songs) {
        _songs = [QIQSongsManager songs];
    }
    return _songs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIQSongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.song = self.songs[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    QIQSongCell *cell = (QIQSongCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    QIQSongCell *cell = (QIQSongCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = UIColorFromRGBA(0x4ED7CC, 1);
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QIQSong *song = self.songs[indexPath.row];
    [QIQSongsManager selectPlayingSong:song];
    QIQAppDelegate *app = (QIQAppDelegate *)[UIApplication sharedApplication].delegate;
    [app.playingVC show];
}


- (void)dealloc {
    NSLog(@"歌单被销毁了");
}

@end
