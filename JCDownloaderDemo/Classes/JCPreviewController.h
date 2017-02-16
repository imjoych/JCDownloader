//
//  JCPreviewController.h
//  JCDownloader
//
//  Created by ChenJianjun on 2017/2/15.
//  Copyright © 2017年 Boych<https://github.com/Boych> All rights reserved.
//

#import <QuickLook/QuickLook.h>


@interface JCPreviewItem : NSObject<QLPreviewItem>

- (instancetype)initWithURL:(NSURL *)url title:(NSString *)title;

@end

@interface JCPreviewController : QLPreviewController

@property (nonatomic, strong) JCPreviewItem *previewItem;

@end
