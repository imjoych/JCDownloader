//
//  UIViewController+JCPreview.m
//  xhyq
//
//  Created by ChenJianjun on 2017/2/15.
//  Copyright © 2017年 xhyq. All rights reserved.
//

#import "UIViewController+JCPreview.h"
#import "JCPreviewController.h"

@implementation UIViewController (JCPreview)

- (void)jc_openPDFWithURL:(NSURL *)url
                    title:(NSString *)title
               completion:(void (^)(BOOL))completion
{
    JCPreviewItem *item = [[JCPreviewItem alloc] initWithURL:url title:title];
    if (![JCPreviewController canPreviewItem:item]) {
        if (completion) {
            completion(NO);
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:url.relativePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:url.relativePath error:nil];
        }
        return;
    }
    JCPreviewController *vc = [JCPreviewController new];
    vc.previewItem = item;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:^{
        if (completion) {
            completion(YES);
        }
    }];
}

@end
