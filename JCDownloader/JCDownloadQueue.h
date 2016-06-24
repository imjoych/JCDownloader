//
//  JCDownloadQueue.h
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/23.
//  Copyright © 2016 Boych<https://github.com/Boych>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCDownloadOperationProtocol.h"

@class JCDownloadOperation;

/** File download queue class. */
@interface JCDownloadQueue : NSObject <JCDownloadOperationProtocol>

@property (nonatomic, assign) NSInteger maxConcurrentDownloadCount; ///< max concurrent download count, default is 10.
@property (nonatomic, assign, readonly) NSInteger currentDownloadCount; ///< current download count.

/** Singleton instance of JCDownloadQueue. */
+ (instancetype)sharedQueue;

#pragma mark - Downloads operation with groupId

/** Start download operation with a group of JCDownloadOperation. */
- (void)startDownloadList:(NSArray<JCDownloadOperation *> *)downloadList;

/** Start downloads for groupId (download all when groupId is nil). */
- (void)startDownloadsWithGroupId:(NSString *)groupId;

/** Pause downloads for groupId (pause all when groupId is nil). */
- (void)pauseDownloadsWithGroupId:(NSString *)groupId;

/** Remove downloads for groupId (remove all when groupId is nil). */
- (void)removeDownloadsWithGroupId:(NSString *)groupId;

/** Returns a group of downloads for groupId (return all when groupId is nil). */
- (NSArray<JCDownloadOperation *> *)downloadListWithGroupId:(NSString *)groupId;

/** Returns download operation with downloadId and groupId, returns nil if not start at all. */
- (JCDownloadOperation *)downloadOperation:(NSString *)downloadId
                                   groupId:(NSString *)groupId;

@end
