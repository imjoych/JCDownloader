//
//  JCDownloadOperationProtocol.h
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/23.
//  Copyright © 2016 Boych<https://github.com/Boych>. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JCDownloadOperation;

/** 下载操作协议 */
@protocol JCDownloadOperationProtocol <NSObject>

/** 开始文件下载请求 */
- (void)startDownload:(JCDownloadOperation *)operation;

/** 暂停文件下载请求 */
- (void)pauseDownload:(JCDownloadOperation *)operation;

/** 结束文件下载请求 */
- (void)finishDownload:(JCDownloadOperation *)operation;

/** 删除下载请求并删除文件 */
- (void)removeDownload:(JCDownloadOperation *)operation;

@end
