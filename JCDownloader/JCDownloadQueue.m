//
//  JCDownloadQueue.m
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/23.
//  Copyright © 2016 Boych<https://github.com/Boych>. All rights reserved.
//

#import "JCDownloadQueue.h"
#import "JCDownloadOperation.h"
#import "JCDownloadAgent.h"

@interface JCDownloadQueue ()

@property (nonatomic, assign) NSInteger currentDownloadCount;
@property (nonatomic, strong) NSMutableArray *operationList;

@end

@implementation JCDownloadQueue

- (instancetype)init
{
    if (self = [super init]) {
        _maxConcurrentDownloadCount = 10;
        _operationList = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)sharedQueue
{
    static JCDownloadQueue *sharedQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = [[JCDownloadQueue alloc] init];
    });
    return sharedQueue;
}

- (void)startDownload:(JCDownloadOperation *)operation
{
    if (!operation) {
        return;
    }
    
    if (![self downloadOperation:operation.item.downloadId
                         groupId:operation.item.groupId]) {
        @synchronized(self.operationList) {
            [self.operationList addObject:operation];
        }
    }
    
    if (self.currentDownloadCount >= self.maxConcurrentDownloadCount) {
        operation.item.status = JCDownloadStatusWait;
        return;
    }
    if (operation.item.status == JCDownloadStatusDownloading) {
        [self startNextDownload];
        return;
    }
    
    operation.item.status = JCDownloadStatusDownloading;
    [[JCDownloadAgent sharedAgent] startDownload:operation];
}

- (void)pauseDownload:(JCDownloadOperation *)operation
{
    if (!operation) {
        return;
    }
    if (operation.item.status == JCDownloadStatusWait
        || operation.item.status == JCDownloadStatusDownloading) {
        operation.item.status = JCDownloadStatusPause;
        [[JCDownloadAgent sharedAgent] pauseDownload:operation];
    }
}

- (void)finishDownload:(JCDownloadOperation *)operation
{
    if (!operation) {
        return;
    }
    if (operation.item.status == JCDownloadStatusWait
        || operation.item.status == JCDownloadStatusDownloading) {
        operation.item.status = JCDownloadStatusFinished;
    }
    [[JCDownloadAgent sharedAgent] finishDownload:operation];
    if (operation.item.status == JCDownloadStatusUnknownError) {
        @synchronized(self.operationList) {
            [self.operationList removeObject:operation];
        }
    }
    if (self.currentDownloadCount < self.maxConcurrentDownloadCount) {
        [self startNextDownload];
    }
}

- (void)removeDownload:(JCDownloadOperation *)operation
{
    if (!operation) {
        return;
    }
    [[JCDownloadAgent sharedAgent] removeDownload:operation];
    @synchronized(self.operationList) {
        [self.operationList removeObject:operation];
    }
}

#pragma mark - Downloads operation with groupId

- (void)startDownloadList:(NSArray<JCDownloadOperation *> *)downloadList
{
    [downloadList enumerateObjectsUsingBlock:^(JCDownloadOperation *operation, NSUInteger idx, BOOL * _Nonnull stop) {
        [operation startDownload];
    }];
}

- (void)startDownloadsWithGroupId:(NSString *)groupId
{
    for (JCDownloadOperation *operation in self.operationList) {
        if (groupId.length > 0 && ![operation.item.groupId isEqualToString:groupId]) {
            continue;
        }
        if (operation.item.status == JCDownloadStatusPause
            || operation.item.status == JCDownloadStatusUnknownError) {
            operation.item.status = JCDownloadStatusWait;
        }
        [self startDownload:operation];
    }
}

- (void)pauseDownloadsWithGroupId:(NSString *)groupId
{
    for (JCDownloadOperation *operation in self.operationList) {
        if (groupId.length > 0 && ![operation.item.groupId isEqualToString:groupId]) {
            continue;
        }
        [operation pauseDownload];
    }
}

- (void)removeDownloadsWithGroupId:(NSString *)groupId
{
    NSMutableArray *removeArray = [NSMutableArray array];
    for (JCDownloadOperation *operation in self.operationList) {
        if (groupId.length > 0 && ![operation.item.groupId isEqualToString:groupId]) {
            continue;
        }
        [removeArray addObject:operation];
    }
    [removeArray enumerateObjectsUsingBlock:^(JCDownloadOperation *operation, NSUInteger idx, BOOL * _Nonnull stop) {
        [operation removeDownload];
    }];
    [removeArray removeAllObjects];
}

- (NSArray<JCDownloadOperation *> *)downloadListWithGroupId:(NSString *)groupId
{
    if (groupId.length < 1) {
        return self.operationList;
    }
    
    NSMutableArray *operationList = [NSMutableArray array];
    for (JCDownloadOperation *operation in self.operationList) {
        if ([operation.item.groupId isEqualToString:groupId]) {
            [operationList addObject:operation];
        }
    }
    return operationList;
}

- (JCDownloadOperation *)downloadOperation:(NSString *)downloadId
                                   groupId:(NSString *)groupId
{
    if (downloadId.length < 1) {
        return nil;
    }
    __block JCDownloadOperation *operation = nil;
    [self.operationList enumerateObjectsUsingBlock:^(JCDownloadOperation *op, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL sameGroupId = (groupId.length < 1) || (groupId.length > 0 && [groupId isEqualToString:op.item.groupId]);
        if (sameGroupId && [downloadId isEqualToString:op.item.downloadId]) {
            operation = op;
            *stop = YES;
        }
    }];
    return operation;
}

#pragma mark - Private

- (NSInteger)currentDownloadCount
{
    NSInteger count = 0;
    for (JCDownloadOperation *operation in self.operationList) {
        if (operation.item.status == JCDownloadStatusDownloading) {
            count += 1;
        }
    }
    _currentDownloadCount = count;
    return count;
}

- (void)startNextDownload
{
    for (JCDownloadOperation *operation in self.operationList) {
        if (operation.item.status == JCDownloadStatusWait) {
            [self startDownload:operation];
            break;
        }
    }
}

@end
