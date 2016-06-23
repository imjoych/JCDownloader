//
//  JCTImageDownloadItem.h
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/21.
//  Copyright © 2016 Boych<https://github.com/Boych>. All rights reserved.
//

#import "JCDownloadOperation.h"

extern NSString *const JCTImageDownloadGroupId;

@interface JCTImageDownloadItem : JCDownloadItem

@property (nonatomic, strong) UIImage *imageCache;

@end
