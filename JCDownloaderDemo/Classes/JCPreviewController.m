//
//  JCPreviewController.m
//  xhyq
//
//  Created by ChenJianjun on 2017/2/15.
//  Copyright © 2017年 xhyq. All rights reserved.
//

#import "JCPreviewController.h"

@implementation JCPreviewItem
@synthesize previewItemURL = _previewItemURL;
@synthesize previewItemTitle = _previewItemTitle;

- (instancetype)initWithURL:(NSURL *)url title:(NSString *)title
{
    if (self = [super init]) {
        _previewItemURL = url;
        _previewItemTitle = title;
    }
    return self;
}

@end

@interface JCPreviewController ()<QLPreviewControllerDataSource>

@end

@implementation JCPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(leftBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBackButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.previewItem;
}

@end
