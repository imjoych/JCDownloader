//
//  JCDownloadOperationProtocol.h
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/23.
//  Copyright © 2016 Joych<https://github.com/imjoych>. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JCDownloadOperation;

/** Download operation protocol. */
@protocol JCDownloadOperationProtocol <NSObject>

/** Start download operation. */
- (void)startDownload:(JCDownloadOperation *)operation;

/** Pause download operation. */
- (void)pauseDownload:(JCDownloadOperation *)operation;

/** Finish download operation. */
- (void)finishDownload:(JCDownloadOperation *)operation;

/** Finish download operation and remove download files. */
- (void)removeDownload:(JCDownloadOperation *)operation;

@end
