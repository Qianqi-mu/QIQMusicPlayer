//
//  QIQLrcView.m
//  QIQMusicPlayer
//
//  Created by qqian on 16/7/7.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import "QIQLrcView.h"
#import "QIQLrcLine.h"

@interface QIQLrcView ()<UITableViewDataSource>

/* 用来显示歌词 */
@property (nonatomic, strong) UITableView *tableView;

/* 保存歌词的数组，每一行歌词可以看作是数组中的一个元素 */
@property (nonatomic, strong) NSMutableArray *lrcs;

@property (nonatomic, assign) NSInteger currentIndex;


@end

@implementation QIQLrcView

/**
 *  解析歌词文件，并将歌词显示在tableView上
 */
- (void)setLrcName:(NSString *)lrcName {
    _lrcName = lrcName;
    [self.lrcs removeAllObjects];
    
    /* 将歌词文件转换成NSString */
    NSURL *url = [[NSBundle mainBundle] URLForResource:lrcName withExtension:nil];
    NSString *lrcString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
   
    /* 取出所有行歌词（包括歌词开始时间和歌词内容） */
    NSArray *lrcs = [lrcString componentsSeparatedByString:@"\n"];
    for (NSString *line in lrcs) {
        QIQLrcLine *lrcLine = [QIQLrcLine new];
        
        /* 每一行的歌词都是以该行歌词的开始时间开始的，比如：“[00:19.41]钟声一直在停留” */
        if (![line hasPrefix:@"["]) continue;
        if ([line hasPrefix:@"[ti:"] || [line hasPrefix:@"[ar:"] || [line hasPrefix:@"[al:"] || [line hasPrefix:@"[t_time:nss"]) {
            /* 以[ti:、[ar:、[al:、[t_time:nss开始的歌词不显示在歌词视图上  */
            continue;
        }else {
            
            /* 将歌词开始时间与歌词内容分开 */
            NSArray *contents = [line componentsSeparatedByString:@"]"];
            /* 截取歌词开始时间，需要将"["去掉 */
            lrcLine.time = [contents.firstObject substringFromIndex:1];
            /* 获取歌词内容 */
            lrcLine.words = contents.lastObject;
        }
        [self.lrcs addObject:lrcLine];
    }
    [self.tableView reloadData];
}

/**
 *  实现歌词随播放进度滚动
 */
- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    
    /* 将歌曲播放的当前时间转成NSString */
    int min = currentTime / 60;
    int sec = (int)currentTime % 60;
    int msec = (currentTime - (int)currentTime)*100;//毫秒
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02d:%02d.@02%d", min, sec, msec];
    
    /* 遍历解析好每一行的歌词，找到当前播放时间对应的那一行歌词 */
    for (int i=0; i<self.lrcs.count-1; i++) {
        /* 分别取出第i行歌词的开始时间和第i+1行歌词的开始时间 */
        QIQLrcLine *lrcLine = self.lrcs[i];
        QIQLrcLine *nextLrcLine = self.lrcs[i+1];
        NSString *lineTime = lrcLine.time;
        NSString *nextLineTime = nextLrcLine.time;
        
        /* 获取第i行对应的cell */
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        /* lineTime < currentTimeStr < nextLineTime 表示currentTimeStr对应的歌词是第i行 */
        if (([lineTime compare:currentTimeStr] == NSOrderedAscending) && ([currentTimeStr compare:nextLineTime] == NSOrderedAscending)) {
            if (self.currentIndex == i) {//如果第i行正好是正在播放的那一行，则将第i行歌词置为高亮
                cell.textLabel.textColor = [UIColor redColor];
            }else {//如果第i行不是正在播放的那一行，则将curreIndex更新，并将tableView滚动到第i行
                self.currentIndex = i;
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }else{//不是正在播放的歌词置为普通
            cell.textLabel.textColor = [UIColor lightTextColor];
        }
        
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
    self.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - 初始化
/* 用于手动创建视图对象时调用 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

/* 用于Storyboard或Xib创建视图对象时调用 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializer];
    }
    return self;
}

static NSString *const ID = @"LrcCell";
- (void)initializer {
    self.lrcs = [NSMutableArray array];
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 30;
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.frame.size.height*0.5, 0, self.tableView.frame.size.height*0.5, 0);
    self.tableView.showsHorizontalScrollIndicator = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
    [self addSubview:self.tableView];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lrcs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    QIQLrcLine *lrcLine = (QIQLrcLine *)self.lrcs[indexPath.row];
    cell.textLabel.text = lrcLine.words;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor lightTextColor];
    return cell;
}

@end
