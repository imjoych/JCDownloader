//
//  ViewController.m
//  JCDownloaderDemo
//
//  Created by ChenJianjun on 16/6/23.
//  Copyright © 2016 Boych<https://github.com/Boych>. All rights reserved.
//

#import "ViewController.h"
#import "JCTImageDownloadCell.h"
#import "JCTImageDownloadItem.h"
#import "JCDownloader.h"

#import "JCLargeFileDownloadViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *removeButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Download List";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 76.f;
    [_tableView registerClass:[JCTImageDownloadCell class] forCellReuseIdentifier:JCTImageDownloadCellIdentifier];
    [self.view addSubview:_tableView];
    
    _toolBar = [[UIToolbar alloc] init];
    [self.view addSubview:_toolBar];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.mas_equalTo(_toolBar.mas_top);
    }];
    [_toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
    
    CGFloat width = CGRectGetWidth(self.view.bounds) / 3.f - 16;
    UIButton *startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 52)];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [startButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [startButton addTarget:self action:@selector(startDownload) forControlEvents:UIControlEventTouchUpInside];
    self.startButton = startButton;
    
    UIButton *stopButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 52)];
    [stopButton setTitle:@"Pause" forState:UIControlStateNormal];
    [stopButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [stopButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [stopButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [stopButton addTarget:self action:@selector(pauseDownload) forControlEvents:UIControlEventTouchUpInside];
    self.stopButton = stopButton;
    
    UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 52)];
    [removeButton setTitle:@"Remove" forState:UIControlStateNormal];
    [removeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [removeButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [removeButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [removeButton addTarget:self action:@selector(removeDownload) forControlEvents:UIControlEventTouchUpInside];
    self.removeButton = removeButton;
    
    UIBarButtonItem *startItem = [[UIBarButtonItem alloc] initWithCustomView:startButton];
    UIBarButtonItem *stopItem = [[UIBarButtonItem alloc] initWithCustomView:stopButton];
    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithCustomView:removeButton];
    self.toolBar.items = @[startItem, stopItem, removeItem];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [button setTitle:@"Big File" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [button addTarget:self action:@selector(enterLargeFileDownloadPage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, rightBarButtonItem];
    
    [JCDownloadAgent sharedAgent].minFileSizeForAutoProducingResumeData = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (NSArray *)urlList
{
    return @[@"http://img2.xiangshu.com/Day_090916/58_254084_beb233c75fb65e1.jpg",
             @"http://www.xiangshu.com/uploads/2/1418513487.jpg",
             @"http://img3.xiangshu.com/Day_150105/533_719940_b7d23d08109055a.jpg",
             @"http://img.xiangshu.com/Day_150904/172_684996_872192037930f26.jpg",
             @"http://img3.xiangshu.com/Day_131115/2_767961_e3e105cc107971e.jpg",
             @"http://pic1.win4000.com/wallpaper/b/542a474d41e73.jpg",
             @"http://img2.xiangshu.com/Day_090614/128_91463_03a9c69ab846b6c.jpg",
             @"http://picuser.city8.com/news/image/2014716/武汉市区地图.jpg",
             @"http://y2.ifengimg.com/bef71b372e157bde/2012/0306/rdn_4f55696894b09.jpg",
             @"http://img3.xiangshu.com/Day_141130/128_423013_3b7821ae221640e.jpg",
             @"http://v1.qzone.cc/pic/201511/10/20/14/5641dfb7a184a596.jpg",
             @"http://img.pconline.com.cn/images/upload/upc/tx/photoblog/1204/14/c2/11245344_11245344_1334366668234.jpg",
             @"http://img2.xiangshu.com/Day_121207/361_369522_12a1bdf0453ee3b.jpg",
             @"http://www.bz55.com/uploads/allimg/150413/140-150413092G6-50.jpg",
             @"http://img.taopic.com/uploads/allimg/110303/26-11030319150372.jpg",
             @"http://tupian.enterdesk.com/2014/lxy/2014/05/24/2/3.jpg"];
}

- (void)startDownload
{
    self.startButton.selected = YES;
    self.stopButton.selected = NO;
    self.removeButton.selected = NO;
    if ([[JCDownloadQueue sharedQueue] downloadListWithGroupId:JCTImageDownloadGroupId].count < 1) {
        NSMutableArray *downloadList = [NSMutableArray array];
        for (NSInteger index = 0; index < [self urlList].count; index++) {
            JCTImageDownloadItem *item = [[JCTImageDownloadItem alloc] init];
            item.groupId = JCTImageDownloadGroupId;
            item.downloadUrl = [self urlList][index];
            item.downloadFilePath = [JCDownloadUtilities filePathWithFileName:[item.downloadUrl lastPathComponent] folderName:@"downloadImages"];
            JCDownloadOperation *operation = [JCDownloadOperation operationWithItem:item];
            [downloadList addObject:operation];
        }
        [[JCDownloadQueue sharedQueue] startDownloadList:downloadList];
    } else {
        [[JCDownloadQueue sharedQueue] startDownloadsWithGroupId:JCTImageDownloadGroupId];
    }
    [self.tableView reloadData];
}

- (void)pauseDownload
{
    self.startButton.selected = NO;
    self.stopButton.selected = YES;
    self.removeButton.selected = NO;
    [[JCDownloadQueue sharedQueue] pauseDownloadsWithGroupId:JCTImageDownloadGroupId];
}

- (void)removeDownload
{
    self.startButton.selected = NO;
    self.stopButton.selected = NO;
    self.removeButton.selected = YES;
    [[JCDownloadQueue sharedQueue] removeDownloadsWithGroupId:JCTImageDownloadGroupId];
    [self.tableView reloadData];
}

- (void)enterLargeFileDownloadPage
{
    JCLargeFileDownloadViewController *vc = [[JCLargeFileDownloadViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[JCDownloadQueue sharedQueue] downloadListWithGroupId:JCTImageDownloadGroupId].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCTImageDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:JCTImageDownloadCellIdentifier];
    JCDownloadOperation *operation = [[JCDownloadQueue sharedQueue] downloadListWithGroupId:JCTImageDownloadGroupId][indexPath.row];
    cell.item = (JCTImageDownloadItem *)operation.item;
    return cell;
}

@end
