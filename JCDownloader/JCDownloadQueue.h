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

/** 文件下载队列类 */
@interface JCDownloadQueue : NSObject<JCDownloadOperationProtocol>

@property (nonatomic, assign) NSInteger maxConcurrentDownloadCount; //最大并发下载数量，默认为10。
@property (nonatomic, assign, readonly) NSInteger currentDownloadCount; //正在下载数量

+ (instancetype)sharedQueue;

#pragma mark - 分组数据下载操作

/** 开始一组下载请求 */
- (void)startDownloadList:(NSArray *)downloadList;

/** 开始对应分组（groupId为空时开始全部）文件下载请求 */
- (void)startDownloadsWithGroupId:(NSString *)groupId;

/** 暂停对应分组（groupId为空时暂停全部）文件下载请求 */
- (void)pauseDownloadsWithGroupId:(NSString *)groupId;

/** 删除对应分组（groupId为空时删除全部）下载请求并删除文件 */
- (void)removeDownloadsWithGroupId:(NSString *)groupId;

/** 返回对应分组（groupId为空时返回全部）文件下载请求列表 */
- (NSArray *)downloadListWithGroupId:(NSString *)groupId;

/** 返回已加入队列的下载请求 */
- (JCDownloadOperation *)downloadOperation:(NSString *)downloadId
                                   groupId:(NSString *)groupId;

@end
