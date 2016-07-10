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
#import "UIScreen+Sizes.h"
#import "QIQSongsManager.h"
#import "QIQMusicPlayer.h"
#import "QIQSong.h"
#import "QIQLrcView.h"

@import AVFoundation;
@import MediaPlayer;

typedef NS_ENUM(NSUInteger, QIQMusicLoopMode){
    QIQMusicLoopModeNormal,//列表循环播放
    QIQMusicLoopModeRandom,//随机播放
    QIQMusicLoopModeSingle//单曲循环
};
@interface QIQMusicPlayingViewController ()

/* 毛玻璃效果视图 */
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

/* 当前正在播放的歌曲 */
@property (nonatomic, strong) QIQSong *playingSong;

/* 当前正在运行的播放器 */
@property (nonatomic, strong) AVAudioPlayer *player;

/* 控制歌词自动播放的定时器 */
@property (nonatomic, strong) CADisplayLink *lrcTimer;

/* 当前音乐播放循环模式 */
@property (nonatomic, assign) QIQMusicLoopMode loopMode;

/* 循环播放控制按钮图标集 */
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSDictionary *imagesDictionary;

@end


/**
 *  播放界面上的各个控件
 */
@interface QIQMusicPlayingViewController ()<AVAudioPlayerDelegate>

/* 背景图 */
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
/* 歌曲名和歌手名 */
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
/* 歌手图片 */
@property (weak, nonatomic) IBOutlet UIImageView *singerImagView;
/* 展示歌词的view */
@property (weak, nonatomic) IBOutlet QIQLrcView *lrcView;

/* 歌曲总时长 */
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
/* 歌曲当前播放时间点 */
@property (weak, nonatomic) IBOutlet UILabel *playedTimeLabel;
/* 歌曲播放进度滑块 */
@property (weak, nonatomic) IBOutlet UISlider *playingProgressSlider;

/* 播放/暂停按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
/* 下一首按钮 */
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
/* 上一首按钮 */
@property (weak, nonatomic) IBOutlet UIButton *preBtn;
/* 循环模式切换按钮 */
@property (weak, nonatomic) IBOutlet UIButton *loopBtn;

@end

#define QIQMusicPlayerTopSubImageHeightScale 450/600
#define QIQMusicPlayerBottomSubImageHeightScale 150/600

static NSString *const kTotalImage = @"TotalImage";
static NSString *const kTopSubImage = @"TopSubImage";
static NSString *const kBottomSubImage = @"BottomSubImage";

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

#pragma mark - 初始化
/* 用于手动创建视图对象时调用 */
- (instancetype)init {
    if (self = [super init]) {
        [self sharedInitializer];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self sharedInitializer];
    }
    return self;
}

/* 用于Storyboard或Xib创建视图对象时调用 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInitializer];
    }
    return self;
}

- (void)sharedInitializer {
    self.images =@[[UIImage imageNamed:@"loop"],
                   [UIImage imageNamed:@"random"],
                   [UIImage imageNamed:@"single_loop"]];
    self.loopMode = QIQMusicLoopModeNormal;
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    self.view.frame = window.bounds;
    [window addSubview:self.view];
    
    [self.view insertSubview:self.blurEffectView atIndex:1];
    
}

#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [self.playingProgressSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
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
    self.view.hidden = NO;
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
    
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    CGSize totalImageSize = window.bounds.size;
    CGSize topSubImageSize = CGSizeMake(totalImageSize.width, totalImageSize.height*QIQMusicPlayerTopSubImageHeightScale);
    CGRect topSubImageRect = CGRectMake(0, 0, topSubImageSize.width, topSubImageSize.height);
    
    CGSize bottomSubImageSize = CGSizeMake(totalImageSize.width, totalImageSize.height*QIQMusicPlayerBottomSubImageHeightScale);
    CGRect bottomSubImageRect = CGRectMake(0, CGRectGetMaxY(topSubImageRect), bottomSubImageSize.width, bottomSubImageSize.height);
    
    NSDictionary *imageDictionary = [self cutCurrentScreenImage];
    UIImage *topSubImage = (UIImage *)imageDictionary[kTopSubImage];
    UIImage *bottomSubImage = (UIImage *)imageDictionary[kBottomSubImage];
    
    __block UIImageView *topSubImageView = [[UIImageView alloc] initWithImage:topSubImage];
    topSubImageView.frame = topSubImageRect;
    [window addSubview:topSubImageView];
    
    __block UIImageView *bottomSubImageView = [[UIImageView alloc] initWithImage:bottomSubImage];
    bottomSubImageView.frame = bottomSubImageRect;
    [window addSubview:bottomSubImageView];
    
    CGRect topImageStartFrame = topSubImageView.frame;
    CGRect topImageEndFrame = topImageStartFrame;
    topImageEndFrame.origin.y = -topImageEndFrame.size.height;
    topImageEndFrame.origin.x = topImageEndFrame.size.width;
    topSubImageView.frame = topImageStartFrame;
    
    CGRect bottomImageStartFrame = bottomSubImageView.frame;
    CGRect bottomImageEndFrame = bottomImageStartFrame;
    bottomImageEndFrame.origin.y += bottomImageEndFrame.size.height;
    bottomSubImageView.frame = bottomImageStartFrame;
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.view.hidden = YES;
        topSubImageView.frame = topImageEndFrame;
        bottomSubImageView.frame = bottomImageEndFrame;
        topSubImageView.layer.transform = CATransform3DScale(topSubImageView.layer.transform, 0.01, 0.01, 1);
        topSubImageView.layer.opacity = 0.0;

    } completion:^(BOOL finished) {
        if (finished) {
            [topSubImageView removeFromSuperview];
            [bottomSubImageView removeFromSuperview];
        }
        
    }];
    
}

- (NSDictionary *)cutCurrentScreenImage {
    NSMutableDictionary *imageDictionary = [NSMutableDictionary dictionary];
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    float scale = [UIScreen scale];
    CGSize totalImageSize = window.bounds.size;
    CGSize topSubImageSize = CGSizeMake(totalImageSize.width, totalImageSize.height*QIQMusicPlayerTopSubImageHeightScale);
    CGRect topSubImageRect = CGRectMake(0, 0, topSubImageSize.width*scale, topSubImageSize.height*scale);
    
    
    CGSize bottomSubImageSize = CGSizeMake(totalImageSize.width, totalImageSize.height*QIQMusicPlayerBottomSubImageHeightScale);
    CGRect bottomSubImageRect = CGRectMake(0, CGRectGetMaxY(topSubImageRect), scale*bottomSubImageSize.width, scale*bottomSubImageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(totalImageSize, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [window.layer renderInContext:context];
    UIImage *totaleImage = UIGraphicsGetImageFromCurrentImageContext();
    imageDictionary[kTotalImage] = totaleImage;
    
    CGImageRef topSubImageRef = CGImageCreateWithImageInRect(totaleImage.CGImage, topSubImageRect);
    UIImage *topSubImage = [UIImage imageWithCGImage:topSubImageRef];
    imageDictionary[kTopSubImage] = topSubImage;
    
    CGImageRef bottomSubImageRef = CGImageCreateWithImageInRect(totaleImage.CGImage, bottomSubImageRect);
    UIImage *bottomSubImage = [UIImage imageWithCGImage:bottomSubImageRef];
    imageDictionary[kBottomSubImage] = bottomSubImage;
    
    UIGraphicsEndImageContext();
    
    return [imageDictionary copy];
}


#pragma mark - 私有方法
- (void)startPlayingMusic {
    /* 如果选中的歌曲是正在播放的那首，则继续播放 */
    if ([[QIQSongsManager playingSong] isEqual: self.playingSong] && self.loopMode != QIQMusicLoopModeSingle) return;
    
    /* 如果不是，那么先停止当前正在播放的歌曲，再播放选中的那首歌 */
    if (self.playingSong) {
        [QIQMusicPlayer stopPlayingSong:self.playingSong];
    }
    /* 更新正在播放的歌曲 */
    self.playingSong = [QIQSongsManager playingSong];
    /* 更新正在播放的歌曲的播放器 */
    self.player = [QIQMusicPlayer playSong:self.playingSong];
    self.player.delegate = self;
    self.player.volume = 1.0;

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
    [self.singerImagView rotateWithTimeInterval:20];
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
    self.playingProgressSlider.value = currentTime*1.0/duration;
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
 *  切换歌曲循环模式
 */
- (IBAction)changeLoopMode:(UIButton *)sender {
    NSUInteger index = self.loopMode;
    index  += 1;
    index %= self.images.count;
    [sender setImage:self.images[index] forState:UIControlStateNormal];
    self.loopMode = index;
}

/**
 *  播放上一首歌曲
 */
- (IBAction)playPreSong:(UIButton *)sender {
    switch (self.loopMode) {
        case QIQMusicLoopModeNormal:
        case QIQMusicLoopModeSingle:
            [self playNewSong:[QIQSongsManager previousSong]];
            break;
        case QIQMusicLoopModeRandom:
            [self playNewSong:[QIQSongsManager randomSong]];
            break;
        default:
            break;
    }
    
}

/**
 *  播放下一首歌曲
 */
- (IBAction)playNextSong:(UIButton *)sender {
    switch (self.loopMode) {
        case QIQMusicLoopModeNormal:
        case QIQMusicLoopModeSingle:
            [self playNewSong:[QIQSongsManager nextSong]];
            break;
        case QIQMusicLoopModeRandom:
            [self playNewSong:[QIQSongsManager randomSong]];
            break;
        default:
            break;
    }
    
}

/**
 *  播放或暂停
 */
- (IBAction)play:(UIButton *)sender {
    if ([self.player isPlaying]) {
        [QIQMusicPlayer pausePlayingSong:self.playingSong];
    }else {
        
        [QIQMusicPlayer playSong:self.playingSong];
    }
    sender.selected = [self.player isPlaying];
}

/**
 *  控制歌曲快进/快退
 */
- (IBAction)changePlayingProgress:(UISlider *)sender {
    self.player.currentTime = sender.value * self.player.duration;
    
}


#pragma mark - AVAudioPlayerDelegate
/**
 *  当前歌曲播放完毕后，自动播放下一首歌曲
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        switch (self.loopMode) {
            case QIQMusicLoopModeNormal:
                [self playNewSong:[QIQSongsManager nextSong]];
                break;
            case QIQMusicLoopModeSingle:
                [self playNewSong:self.playingSong];
                break;
            case QIQMusicLoopModeRandom:
                [self playNewSong:[QIQSongsManager randomSong]];
                break;
            default:
                break;
        }
    }
}



@end
