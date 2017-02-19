//
//  JCDownloadOperation.m
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/21.
//  Copyright © 2016 Boych<https://github.com/Boych>. All rights reserved.
//

#import "JCDownloadOperation.h"
#import "JCDownloadQueue.h"
#import "JCDownloadUtilities.h"

@implementation JCDownloadItem

- (NSString *)downloadId
{
    if (_downloadId.length < 1) {
        _downloadId = [JCDownloadUtilities md5WithString:self.downloadUrl];
    }
    return _downloadId;
}

@end

NSNotificationName const JCDownloadProgressNotification = @"kJCDownloadProgressNotification";
NSNotificationName const JCDownloadCompletionNotification = @"kJCDownloadCompletionNotification";
NSString *const JCDownloadIdKey = @"kJCDownloadIdKey";
NSString *const JCDownloadProgressKey = @"kJCDownloadProgressKey";
NSString *const JCDownloadCompletionFilePathKey = @"kJCDownloadCompletionFilePathKey";
NSString *const JCDownloadCompletionErrorKey = @"kJCDownloadCompletionErrorKey";

@interface JCDownloadOperation ()

@property (nonatomic, strong) JCDownloadItem *item;
@property (nonatomic, copy) JCDownloadProgressBlock progressBlock;
@property (nonatomic, copy) JCDownloadCompletionBlock completionBlock;

@end

@implementation JCDownloadOperation

- (void)dealloc
{
    [self clearBlocks];
}

- (instancetype)initWithItem:(JCDownloadItem *)item
{
    if (self = [super init]) {
        _item = item;
    }
    return self;
}

+ (instancetype)operationWithItem:(JCDownloadItem *)item
{
    JCDownloadOperation *operation = [[JCDownloadQueue sharedQueue] downloadOperation:item.downloadId
                                                                              groupId:item.groupId];
    if (operation) {
        return operation;
    }
    return [[self alloc] initWithItem:item];
}

- (void)startDownload
{
    [[JCDownloadQueue sharedQueue] startDownload:self];
}

- (void)startWithProgressBlock:(JCDownloadProgressBlock)progressBlock
               completionBlock:(JCDownloadCompletionBlock)completionBlock
{
    [self resetProgressBlock:progressBlock
             completionBlock:completionBlock];
    [self startDownload];
}

- (void)resetProgressBlock:(JCDownloadProgressBlock)progressBlock
           completionBlock:(JCDownloadCompletionBlock)completionBlock
{
    self.progressBlock = progressBlock;
    self.completionBlock = completionBlock;
}

- (void)pauseDownload
{
    [[JCDownloadQueue sharedQueue] pauseDownload:self];
}

- (void)finishDownload
{
    [[JCDownloadQueue sharedQueue] finishDownload:self];
}

- (void)removeDownload
{
    [self clearBlocks];
    [[JCDownloadQueue sharedQueue] removeDownload:self];
}

#pragma mark -

- (void)clearBlocks
{
    self.completionBlock = nil;
    self.progressBlock = nil;
}

@end
