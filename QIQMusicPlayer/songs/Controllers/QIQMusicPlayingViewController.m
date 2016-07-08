//
//  QIQMusicPlayingViewController.m
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import "QIQMusicPlayingViewController.h"
#import "UIImage+Circle.h"
#import "UIImageView+Rotate.h"
#import "QIQSongsManager.h"
#import "QIQMusicPlayer.h"
#import "QIQSong.h"
#import "QIQLrcView.h"

@import AVFoundation;

@interface QIQMusicPlayingViewController ()

/* 毛玻璃效果视图 */
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

/* 当前正在播放的歌曲 */
@property (nonatomic, strong) QIQSong *playingSong;

/* 当前正在运行的播放器 */
@property (nonatomic, strong) AVAudioPlayer *player;

@end


/**
 *  播放界面上的各个控件
 */
@interface QIQMusicPlayingViewController ()<AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UIButton *lrcLabel;
@property (weak, nonatomic) IBOutlet UIImageView *singerImagView;
@property (weak, nonatomic) IBOutlet QIQLrcView *lrcView;

@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *playedTimeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *playingProgress;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *preBtn;

@property (nonatomic, strong) CADisplayLink *lrcTimer;

@end

@implementation QIQMusicPlayingViewController

#pragma mark - 懒加载
- (UIVisualEffectView *)blurEffectView {
    if (!_blurEffectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    _blurEffectView.frame = self.view.frame;
    return _blurEffectView;
}

- (CADisplayLink *)lrcTimer {
    if (!_lrcTimer) {
        _lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    }
    return _lrcTimer;
}

#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - 公共接口
+ (instancetype)sharedPlayingViewController {
    static QIQMusicPlayingViewController *playingVC = nil;
    static dispatch_once_t oneceToken;
    dispatch_once(&oneceToken, ^{
        if (!playingVC) {
            playingVC = [[QIQMusicPlayingViewController alloc]initWithNibName:@"QIQMusicPlayingViewController" bundle:nil];
        }
    });
    return playingVC;
}

/**
 *  打开音乐播放界面
 */
- (void)show {
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    self.view.frame = window.bounds;
    [window addSubview:self.view];
    
    [self.view insertSubview:self.blurEffectView atIndex:1];
    
    CGRect endFrame = self.view.frame;
    CGRect startFrame = endFrame;
    startFrame.origin.y = startFrame.size.height;
    self.view.frame = startFrame;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.view.frame = endFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf startPlayingMusic];
        }
    }];
}

/**
 *  隐藏音乐播放界面
 */
- (void)hide {
    CGRect startFrame = self.view.frame;
    CGRect endFrame = startFrame;
    endFrame.origin.y = endFrame.size.height;
    self.view.frame = startFrame;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.view.frame = endFrame;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf.view removeFromSuperview];
        }
        
    }];
}

#pragma mark - 私有方法
- (void)startPlayingMusic {
    /* 如果选中的歌曲是正在播放的那首，则继续播放 */
    if ([[QIQSongsManager playingSong] isEqual: self.playingSong]) return;
    
    /* 如果不是，那么先停止当前正在播放的歌曲，再播放选中的那首歌 */
    if (self.playingSong) {
        [QIQMusicPlayer stopPlayingSong:self.playingSong];
    }
    /* 更新正在播放的歌曲 */
    self.playingSong = [QIQSongsManager playingSong];
    /* 更新正在播放的歌曲的播放器 */
    self.player = [QIQMusicPlayer playSong:self.playingSong];
    self.player.delegate = self;
    
    /* 更新音乐播放界面 */
    [self setupBackgroundImageAndSingerImage];
    
    /* 重新开启歌曲播放进度计时器 */
    [self startPlayingProgressTimer];
}

/**
 *  根据正在播放的歌曲更新播放界面
 */
- (void)setupBackgroundImageAndSingerImage {
    /* 获取正在播放的歌曲 */
    QIQSong *song = [QIQSongsManager playingSong];
    NSString *backImage = @"player_albumblur_default";
    NSString *singerImage = @"iTunesArtwork.png";
    if (song) {
        backImage = singerImage = song.singerIcon;
    }
    /* 将播放控制面板上的“播放/暂停”按钮置为“暂停” */
    self.playBtn.selected = YES;
    
    /* 更新歌曲名和歌手 */
    self.songLabel.text = self.playingSong.name;
    self.singerLabel.text = self.playingSong.singer;
    
    /* 更新歌词 */
    self.lrcView.lrcName = self.playingSong.lrcname;
    
    /* 更新背景图 */
    self.backgroundImageView.image = [UIImage imageNamed:backImage];
    
    /* 更新歌手图片，并旋转 */
    self.singerImagView.image = [UIImage circleImageWithImage:[UIImage redrawImageWithImageName:singerImage scaleToSize:CGSizeMake(self.singerImagView.bounds.size.width, self.singerImagView.bounds.size.height)] borderWidth:3 borderColor:[UIColor darkGrayColor]];
    [self.singerImagView rotateWithTimeInterval:6];
}

/**
 *  播放时间进度条
 */
- (void)startPlayingProgressTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

/**
 *  根据歌曲当前播放时间更新进度条
 */
- (void)updateProgress:(NSTimer *)timer {
    /* 获取正在播放的歌曲的总时长与当前播放的时间点 */
    NSTimeInterval duration = self.player.duration;
    NSTimeInterval currentTime = self.player.currentTime;
    self.playingProgress.progress = currentTime*1.0/duration;
    self.totalTimeLabel.text =  [self stringByTimeInterval:duration];
    self.playedTimeLabel.text = [self stringByTimeInterval:currentTime];
}

/**
 *  将时间转字符串
 */
- (NSString *)stringByTimeInterval:(NSTimeInterval)time {
    int min = time / 60;
    int sec = (int)time % 60;
    return [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

/**
 *  开启控制歌词滚动的定时器
 */
- (void)startLrcTimer {
    if (!self.playingSong || self.lrcView.hidden) {
        return;
    }
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

/**
 *  关闭歌词定时器
 */
- (void)endLrcTimer {
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}

/**
 *  更新当前正在播放的歌词
 */
- (void)updateLrc {
    self.lrcView.currentTime = self.player.currentTime;
}

/**
 *  播放一首新的歌曲
 */
- (void)playNewSong:(QIQSong *)song {
    [QIQSongsManager selectPlayingSong:song];
    [self setupBackgroundImageAndSingerImage];
    [self startPlayingMusic];
}

#pragma mark - 按钮点击事件
/**
 *  切换到歌单
 */
- (IBAction)backToMenu:(UIButton *)sender {
    [self hide];
}

/**
 *  展示或隐藏歌词
 */
- (IBAction)showLrcView:(UIButton *)sender {
    if (self.lrcView.hidden) {
        self.singerImagView.hidden = YES;
        [self.singerImagView stopRotation];
        self.lrcView.hidden = NO;
        [self startLrcTimer];
    }else {
        self.lrcView.hidden = YES;
        [self endLrcTimer];
        self.singerImagView.hidden = NO;
        [self.singerImagView rotateWithTimeInterval:6];
    }
}

/**
 *  播放上一首歌曲
 */
- (IBAction)playPreSong:(UIButton *)sender {
    [self playNewSong:[QIQSongsManager previousSong]];
}

/**
 *  播放下一首歌曲
 */
- (IBAction)playNextSong:(UIButton *)sender {
    [self playNewSong:[QIQSongsManager nextSong]];
}

/**
 *  播放或暂停
 */
- (IBAction)play:(UIButton *)sender {
    if ([self.player isPlaying]) {
        [sender setImage:[UIImage imageNamed:@"player_btn_play_highlight"] forState:UIControlStateHighlighted];
        [QIQMusicPlayer pausePlayingSong:self.playingSong];
    }else {
        [sender setImage:[UIImage imageNamed:@"player_btn_pause_highlight"] forState:UIControlStateHighlighted];
        [QIQMusicPlayer playSong:self.playingSong];
    }
    sender.selected = [self.player isPlaying];
}

#pragma mark - AVAudioPlayerDelegate
/**
 *  当前歌曲播放完毕后，自动播放下一首歌曲
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self playNewSong:[QIQSongsManager nextSong]];
}

@end
