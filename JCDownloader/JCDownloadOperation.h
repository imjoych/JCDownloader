//
//  JCDownloadOperation.h
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/21.
//  Copyright © 2016 Boych<https://github.com/Boych>. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Download status. */
typedef NS_ENUM(NSInteger, JCDownloadStatus) {
    JCDownloadStatusWait,        ///< waiting for download.
    JCDownloadStatusDownloading, ///< in the download.
    JCDownloadStatusPause,       ///< download is paused.
    JCDownloadStatusFinished,    ///< download is finished.
    JCDownloadStatusUnknownError ///< download error occured.
};

/** Download operation info Class. */
@interface JCDownloadItem : NSObject

@property (nonatomic, strong) NSString *downloadUrl;      ///< download link, can't be nil.
@property (nonatomic, strong) NSString *downloadFilePath; ///< local path for file cache, can't be nil.
@property (nonatomic, strong) NSString *downloadId;       ///< if nil, generated automatically by the downloadUrl.
@property (nonatomic, strong) NSString *groupId;          ///< default is nil.
@property (nonatomic, assign) JCDownloadStatus status;    ///< default is JCDownloadStatusWait.
@property (nonatomic, assign) int64_t totalUnitCount;     ///< file size.
@property (nonatomic, assign) int64_t completedUnitCount; ///< completed download size of file.

@end

FOUNDATION_EXPORT NSNotificationName const JCDownloadProgressNotification;   ///< notification of download progress.
FOUNDATION_EXPORT NSNotificationName const JCDownloadCompletionNotification; ///< notification of download completion.
FOUNDATION_EXPORT NSString *const JCDownloadIdKey;                  ///< download identifier key in notifications userInfo, instance type of the value is NSString.
FOUNDATION_EXPORT NSString *const JCDownloadProgressKey;            ///< download progress key in JCDownloadProgressNotification userInfo, instance type of the value is NSProgress.
FOUNDATION_EXPORT NSString *const JCDownloadCompletionFilePathKey;  ///< download completion file path key in JCDownloadCompletionNotification userInfo, instance type of the value is NSURL.
FOUNDATION_EXPORT NSString *const JCDownloadCompletionErrorKey;     ///< download completion error key in JCDownloadCompletionNotification userInfo, instance type of the value is NSError.

/** Block of file download progress. */
typedef void(^JCDownloadProgressBlock)(NSProgress *progress);
/** Block of file download completion. */
typedef void(^JCDownloadCompletionBlock)(NSURL *filePath, NSError *error);

/** Download operation Class. */
@interface JCDownloadOperation : NSObject

@property (nonatomic, strong, readonly) JCDownloadItem *item;
@property (nonatomic, copy, readonly) JCDownloadProgressBlock progressBlock;
@property (nonatomic, copy, readonly) JCDownloadCompletionBlock completionBlock;

/** Instance of JCDownloadOperation with item. */
+ (instancetype)operationWithItem:(JCDownloadItem *)item;

/** Start download. */
- (void)startDownload;

/** Start download with progressBlock and completionBlock. */
- (void)startWithProgressBlock:(JCDownloadProgressBlock)progressBlock
               completionBlock:(JCDownloadCompletionBlock)completionBlock;

/** Reset progressBlock and completionBlock. */
- (void)resetProgressBlock:(JCDownloadProgressBlock)progressBlock
           completionBlock:(JCDownloadCompletionBlock)completionBlock;

/** Pause download. */
- (void)pauseDownload;

/** Finish download (download is completed or error occured). */
- (void)finishDownload;

/** Remove download (stop download operation and remove download files). */
- (void)removeDownload;

@end
