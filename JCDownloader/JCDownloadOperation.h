//
//  JCDownloadOperation.h
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/21.
//  Copyright © 2016 Boych<https://github.com/Boych>. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 下载状态 */
typedef NS_ENUM(NSInteger, JCDownloadStatus) {
    JCDownloadStatusWait,        //等待下载，默认值
    JCDownloadStatusDownloading, //下载中
    JCDownloadStatusPause,       //暂停下载
    JCDownloadStatusFinished,    //下载完成
    JCDownloadStatusUnknownError //下载出错
};

/** 下载相关数据 */
@interface JCDownloadItem : NSObject

@property (nonatomic, strong) NSString *downloadUrl;      //下载链接地址，不能为空
@property (nonatomic, strong) NSString *downloadFilePath; //下载文件本地路径，不能为空
@property (nonatomic, strong) NSString *downloadId;       //下载唯一标识，为空时自动生成
@property (nonatomic, strong) NSString *groupId;          //下载分组标识
@property (nonatomic, assign) JCDownloadStatus status;    //下载状态
@property (nonatomic, assign) int64_t totalUnitCount;     //下载文件总大小
@property (nonatomic, assign) int64_t completedUnitCount; //已下载文件大小

@end

FOUNDATION_EXPORT NSString *const JCDownloadProgressNotification;   //下载进度通知
FOUNDATION_EXPORT NSString *const JCDownloadCompletionNotification; //下载完成通知
FOUNDATION_EXPORT NSString *const JCDownloadIdKey;                  //下载Id Key，值为NSString对象
FOUNDATION_EXPORT NSString *const JCDownloadProgressKey;            //下载进度Key，值为NSProgress对象
FOUNDATION_EXPORT NSString *const JCDownloadCompletionFilePathKey;  //文件路径Key，值为NSURL对象
FOUNDATION_EXPORT NSString *const JCDownloadCompletionErrorKey;     //下载出错Key，值为NSError对象

/** 文件下载进度Block回调 */
typedef void(^JCDownloadProgressBlock)(NSProgress *progress);
/** 文件下载请求结束Block回调 */
typedef void(^JCDownloadCompletionBlock)(NSURL *filePath, NSError *error);

/** 文件下载类 */
@interface JCDownloadOperation : NSObject

@property (nonatomic, strong, readonly) JCDownloadItem *item;
@property (nonatomic, copy, readonly) JCDownloadProgressBlock progressBlock;
@property (nonatomic, copy, readonly) JCDownloadCompletionBlock completionBlock;

/** 实例化对象 */
+ (instancetype)operationWithItem:(JCDownloadItem *)item;

/** 开始下载 */
- (void)startDownload;

/** 开始下载并初始化Block回调 */
- (void)startWithProgressBlock:(JCDownloadProgressBlock)progressBlock
               completionBlock:(JCDownloadCompletionBlock)completionBlock;

/** 重置Block回调 */
- (void)resetProgressBlock:(JCDownloadProgressBlock)progressBlock
           completionBlock:(JCDownloadCompletionBlock)completionBlock;

/** 暂停下载 */
- (void)pauseDownload;

/** 结束下载（下载完成或异常结束）*/
- (void)finishDownload;

/** 删除下载（停止请求并删除文件）*/
- (void)removeDownload;

@end
