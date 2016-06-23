//
//  JCDownloadAgent.h
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/21.
//  Copyright © 2016 Boych<https://github.com/Boych>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCDownloadOperationProtocol.h"

@class JCDownloadItem;

/** 文件下载网络请求类 */
@interface JCDownloadAgent : NSObject<JCDownloadOperationProtocol>

/** 设置自动暂停并生成resumeData的最小文件大小，默认为2M */
@property (nonatomic, assign) int64_t minFileSizeForProducingResumeData;

+ (instancetype)sharedAgent;

/** 判断文件是否下载 */
- (BOOL)isFileDownloaded:(JCDownloadItem *)downloadItem;

/** 删除下载文件
 * @param downloadItem 下载项，对应下载任务未停止时禁止调用该方法，防止删除临时文件时与系统写入/删除操作冲突
 */
- (void)removeDownloadFile:(JCDownloadItem *)downloadItem;

@end
