//
//  JCDownloadAgent.m
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/21.
//  Copyright © 2016 Joych<https://github.com/imjoych>. All rights reserved.
//

#import "JCDownloadAgent.h"
#import "JCDownloadOperation.h"
#import "JCDownloadUtilities.h"
#import <AFNetworking/AFNetworking.h>

static NSString *const JCDownloadAgentFolder = @"com.jc.JCDownloader.folder";

static dispatch_queue_t jc_download_agent_file_operation_queue() {
    static dispatch_queue_t download_agent_file_operation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        download_agent_file_operation_queue = dispatch_queue_create("com.jc.JCDownloader.download.agent.file.operation", DISPATCH_QUEUE_SERIAL);
    });
    return download_agent_file_operation_queue;
}

@interface JCDownloadAgent () {
    dispatch_queue_t _taskQueue;
    dispatch_queue_t _resumeQueue;
}

@property (nonatomic, strong) NSMutableDictionary *tasksDict;
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *pauseAndResumeDict;

@end

@implementation JCDownloadAgent

- (instancetype)init
{
    if (self = [super init]) {
        _tasksDict = [NSMutableDictionary dictionary];
        _manager = [AFHTTPSessionManager manager];
        _minFileSizeForAutoProducingResumeData = 2 * 1024 * 1024;
        _pauseAndResumeDict = [NSMutableDictionary dictionary];
        _taskQueue = dispatch_queue_create("com.jcdownloader.downloadagent.taskqueue", DISPATCH_QUEUE_SERIAL);
        _resumeQueue = dispatch_queue_create("com.jcdownloader.downloadagent.resumequeue", DISPATCH_QUEUE_SERIAL);
        [self removeInvalidTempFiles];
    }
    return self;
}

+ (instancetype)sharedAgent
{
    static JCDownloadAgent *sharedAgent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAgent = [[JCDownloadAgent alloc] init];
    });
    return sharedAgent;
}

- (BOOL)isFileDownloaded:(JCDownloadItem *)downloadItem
{
    int64_t fileSize = [JCDownloadUtilities fileSizeWithFilePath:downloadItem.downloadFilePath];
    if (fileSize > 0
        && fileSize >= downloadItem.totalUnitCount) {
        return YES;
    }
    return NO;
}

- (void)removeDownloadFile:(JCDownloadItem *)downloadItem
{
    [self removeDownloadFile:downloadItem isDownloading:NO];
}

- (void)createResumeDataWithItem:(JCDownloadItem *)item
{
    if (!item || !item.downloadUrl || !item.tempFileName) {
        return;
    }
    NSString *resumeDataPath = [self resumeDataPath:item];
    if (resumeDataPath.length < 1 || [[NSFileManager defaultManager] fileExistsAtPath:resumeDataPath]) {
        return;
    }
    NSMutableDictionary *resumeDictionary = [NSMutableDictionary dictionary];
    resumeDictionary[@"NSURLSessionResumeInfoTempFileName"] = item.tempFileName;
    resumeDictionary[@"NSURLSessionDownloadURL"] = item.downloadUrl;
    NSString *tempFilePath = [self tempFilePathWithFileName:item.tempFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempFilePath]) {
        int64_t fileSize = [JCDownloadUtilities fileSizeWithFilePath:tempFilePath];
        if (fileSize > 0) {
            resumeDictionary[@"NSURLSessionResumeBytesReceived"] = @(fileSize);
        }
    }
    NSError *error;
    NSData *resumeData = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListImmutable error:&error];
    if (!error && resumeData) {
        [self saveResumeData:resumeData
                downloadItem:item];
    }
}

- (NSString *)tempFilePathWithFileName:(NSString *)tempFileName
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:tempFileName];
}

- (void)setSecurityPolicyWithSSLPinningMode:(JCDownloadSSLPinningMode)SSLPinningMode pinnedCertificates:(NSSet<NSData *> *)pinnedCertificates allowInvalidCertificates:(BOOL)allowInvalidCertificates validatesDomainName:(BOOL)validatesDomainName
{
    AFSSLPinningMode pinningMode = (AFSSLPinningMode)SSLPinningMode;
    if (pinnedCertificates && pinningMode != AFSSLPinningModeNone) {
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:pinningMode];
        securityPolicy.pinnedCertificates = pinnedCertificates;
        securityPolicy.allowInvalidCertificates = allowInvalidCertificates;
        securityPolicy.validatesDomainName = validatesDomainName;
        self.manager.securityPolicy = securityPolicy;
    }
}

#pragma mark - JCDownloadOperationProtocol

- (void)startDownload:(JCDownloadOperation *)operation
{
    if (!operation) {
        return;
    }
    
    if (![self isValidDownload:operation.item]) {
        NSError *error = [NSError errorWithDomain:@"illegal download request." code:-1 userInfo:@{NSLocalizedDescriptionKey: @"非法下载请求"}];
        [self completionWithOperation:operation
                             filePath:nil
                                error:error];
        return;
    }
    
    if ([self isFileDownloaded:operation.item]) {
        int64_t fileSize = [JCDownloadUtilities fileSizeWithFilePath:operation.item.downloadFilePath];
        operation.item.totalUnitCount = fileSize;
        operation.item.completedUnitCount = fileSize;
        [self completionWithOperation:operation
                             filePath:[NSURL fileURLWithPath:operation.item.downloadFilePath]
                                error:nil];
        return;
    }
    
    NSURLSessionDownloadTask *task = [self downloadTaskWithOperation:operation];
    if (task) {
        NSString *key = [self downloadKey:operation.item];
        [self setTask:task forKey:key];
    }
}

- (void)pauseDownload:(JCDownloadOperation *)operation
{
    [self pauseDownload:operation
             completion:nil];
}

- (void)finishDownload:(JCDownloadOperation *)operation
{
    if (!operation) {
        return;
    }
    
    NSString *key = [self downloadKey:operation.item];
    NSURLSessionDownloadTask *requestTask = self.tasksDict[key];
    if ([requestTask respondsToSelector:@selector(cancel)]) {
        [requestTask cancel];
    }
    [self removeTaskForKey:key];
}

- (void)removeDownload:(JCDownloadOperation *)operation
{
    if (!operation) {
        return;
    }
    
    NSString *key = [self downloadKey:operation.item];
    NSURLSessionDownloadTask *requestTask = self.tasksDict[key];
    if ([requestTask respondsToSelector:@selector(cancel)]) {
        [requestTask cancel];
    }
    [self removeTaskForKey:key];
    [self removeDownloadFile:operation.item isDownloading:YES];
}

#pragma mark - data operation

- (NSMutableDictionary *)tasksDict
{
    __block NSMutableDictionary *tasks = nil;
    dispatch_sync(_taskQueue, ^{
        tasks = self->_tasksDict;
    });
    return tasks;
}

- (void)setTask:(NSURLSessionDownloadTask *)task forKey:(NSString *)key
{
    if (!task || key.length < 1) {
        return;
    }
    dispatch_barrier_async(_taskQueue, ^{
        self->_tasksDict[key] = task;
    });
}

- (void)removeTaskForKey:(NSString *)key
{
    if (key.length < 1) {
        return;
    }
    dispatch_barrier_async(_taskQueue, ^{
        [self->_tasksDict removeObjectForKey:key];
    });
}

#pragma mark - download operation

- (NSString *)downloadKey:(JCDownloadItem *)downloadItem
{
    return downloadItem.downloadId;
}

- (BOOL)isValidDownload:(JCDownloadItem *)downloadItem
{
    if (downloadItem.downloadUrl.length > 0
        && downloadItem.downloadFilePath.length > 0) {
        return YES;
    }
    return NO;
}

- (void)pauseDownload:(JCDownloadOperation *)operation
           completion:(void(^)(BOOL isSuccess))completion
{
    if (!operation) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    NSString *key = [self downloadKey:operation.item];
    NSURLSessionDownloadTask *requestTask = self.tasksDict[key];
    if ([requestTask respondsToSelector:@selector(cancelByProducingResumeData:)]) {
        __weak __typeof(self)weakSelf = self;
        [requestTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf saveResumeData:resumeData downloadItem:operation.item completion:^(BOOL isSaved) {
                if (completion) {
                    completion(isSaved);
                }
            }];
        }];
    }
    [self removeTaskForKey:key];
}

/** Remove invalid download temp files. */
- (void)removeInvalidTempFiles
{
    NSString *tempPath = NSTemporaryDirectory();
    NSArray *tempFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
    for (NSString *fileName in tempFiles) {
        NSString *filePath = [tempPath stringByAppendingPathComponent:fileName];
        if ([JCDownloadUtilities fileSizeWithFilePath:filePath] == 0) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

/** Remove download file.
 * @param isDownloading Is download task in progress or not.
 */
- (void)removeDownloadFile:(JCDownloadItem *)downloadItem
             isDownloading:(BOOL)isDownloading
{
    dispatch_async(jc_download_agent_file_operation_queue(), ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:downloadItem.downloadFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:downloadItem.downloadFilePath error:nil];
        }
    });
    if (isDownloading) {
        [self removeResumeData:downloadItem];
    } else {
        [self removeTempFileAndResumeData:downloadItem];
    }
}

#pragma mark - resume data operation

- (NSString *)resumeDataPath:(JCDownloadItem *)downloadItem
{
    NSString *key = [self downloadKey:downloadItem];
    NSString *resumeDataName = [NSString stringWithFormat:@"%@_resumeData", key];
    NSString *resumeDataPath = [JCDownloadUtilities filePathWithFileName:resumeDataName
                                                              folderName:JCDownloadAgentFolder];
    return resumeDataPath;
}

- (void)removeResumeData:(JCDownloadItem *)downloadItem
{
    dispatch_async(jc_download_agent_file_operation_queue(), ^{
        NSString *resumeDataPath = [self resumeDataPath:downloadItem];
        if (resumeDataPath.length > 0
            && [[NSFileManager defaultManager] fileExistsAtPath:resumeDataPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:resumeDataPath error:nil];
        }
    });
}

- (void)removeTempFileAndResumeData:(JCDownloadItem *)downloadItem
{
    dispatch_async(jc_download_agent_file_operation_queue(), ^{
        NSString *resumeDataPath = [self resumeDataPath:downloadItem];
        if (resumeDataPath.length > 0
            && [[NSFileManager defaultManager] fileExistsAtPath:resumeDataPath]) {
            NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataPath];
            NSDictionary *resumeDictionary = [self resumeDictionaryWithResumeData:resumeData];
            NSString *tempFilePath = [self tempFilePathWithResumeDictionary:resumeDictionary];
            if ([[NSFileManager defaultManager] fileExistsAtPath:tempFilePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
            }
            [[NSFileManager defaultManager] removeItemAtPath:resumeDataPath error:nil];
        }
    });
}

- (void)saveResumeData:(NSData *)resumeData
          downloadItem:(JCDownloadItem *)downloadItem
{
    [self saveResumeData:resumeData
            downloadItem:downloadItem
              completion:nil];
}

- (void)saveResumeData:(NSData *)resumeData
          downloadItem:(JCDownloadItem *)downloadItem
            completion:(void(^)(BOOL isSaved))completion
{
    if (!resumeData
        || ![self resumeDataPath:downloadItem]) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    dispatch_async(jc_download_agent_file_operation_queue(), ^{
        BOOL saved = [resumeData writeToFile:[self resumeDataPath:downloadItem] atomically:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(saved);
            }
        });
    });
}

- (NSData *)validResumeData:(JCDownloadItem *)downloadItem
{
    NSString *resumeDataPath = [self resumeDataPath:downloadItem];
    if (resumeDataPath.length < 1
        || ![[NSFileManager defaultManager] fileExistsAtPath:resumeDataPath]) {
        return nil;
    }
    
    NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataPath];
    NSDictionary *resumeDictionary = [self resumeDictionaryWithResumeData:resumeData];
    //Check is download temp file exists or not
    NSString *tempFilePath = [self tempFilePathWithResumeDictionary:resumeDictionary];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempFilePath]) {
        return nil;
    }
    
    //Update resumeData info.
    BOOL isResumeDataChanged = NO;
    NSMutableDictionary *newResumeDictionary = [NSMutableDictionary dictionaryWithDictionary:resumeDictionary];
    
    //Check download url
    NSString *downloadUrl = [resumeDictionary objectForKey:@"NSURLSessionDownloadURL"];
    if (![downloadUrl isEqualToString:downloadItem.downloadUrl]) {
        isResumeDataChanged = YES;
        newResumeDictionary[@"NSURLSessionDownloadURL"] = downloadItem.downloadUrl;
    }
    
    //Check resume bytes received
    int64_t bytesReceived = [[resumeDictionary objectForKey:@"NSURLSessionResumeBytesReceived"] longLongValue];
    int64_t fileSize = [JCDownloadUtilities fileSizeWithFilePath:tempFilePath];
    if (bytesReceived < fileSize) {
        isResumeDataChanged = YES;
        newResumeDictionary[@"NSURLSessionResumeBytesReceived"] = @(fileSize);
    }
    if (isResumeDataChanged) {
        NSError *error;
        NSData *newResumeData = [NSPropertyListSerialization dataWithPropertyList:newResumeDictionary format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListImmutable error:&error];
        if (!error && newResumeData) {
            resumeData = newResumeData;
            [self saveResumeData:resumeData
                    downloadItem:downloadItem];
        }
    }
    return resumeData;
}

/** ResumeData serialization. */
- (NSDictionary *)resumeDictionaryWithResumeData:(NSData *)resumeData
{
    if (resumeData.length < 1) {
        return nil;
    }
    return [NSPropertyListSerialization propertyListWithData:resumeData
                                                     options:NSPropertyListImmutable
                                                      format:NULL
                                                       error:nil];
}

/** Download temp file path. */
- (NSString *)tempFilePathWithResumeDictionary:(NSDictionary *)resumeDictionary
{
    if (resumeDictionary.count < 1) {
        return nil;
    }
    NSString *tempFileName = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoTempFileName"];
    if (tempFileName.length < 1) {
        return nil;
    }
    return [self tempFilePathWithFileName:tempFileName];
}

#pragma mark - pause download and produce resume data

/** Pause download to produce resumeData, after that restart the download. */
- (void)pauseAndResumeOperation:(JCDownloadOperation *)operation
{
    if (operation.item.totalUnitCount < self.minFileSizeForAutoProducingResumeData) {
        return;
    }
    NSString *resumeDataPath = [self resumeDataPath:operation.item];
    int64_t fileSize = [JCDownloadUtilities fileSizeWithFilePath:resumeDataPath];
    if (fileSize > 0) {
        return;
    }
    
    [self addPauseAndResumeOperation:operation];
    __weak __typeof(self)weakSelf = self;
    operation.item.status = JCDownloadStatusPause;
    [self pauseDownload:operation completion:^(BOOL isSuccess) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        operation.item.status = JCDownloadStatusDownloading;
        [strongSelf startDownload:operation];
    }];
}

- (void)addPauseAndResumeOperation:(JCDownloadOperation *)operation
{
    if (!operation) {
        return;
    }
    NSString *key = [self downloadKey:operation.item];
    [self setPauseAndResumeOperation:operation forKey:key];
}

- (void)removePauseAndResumeOperation:(JCDownloadOperation *)operation
{
    if (![self isPauseAndResumeOperation:operation]) {
        return;
    }
    NSString *key = [self downloadKey:operation.item];
    [self removePauseAndResumeOperationForKey:key];
}

- (BOOL)isPauseAndResumeOperation:(JCDownloadOperation *)operation
{
    if (!operation) {
        return NO;
    }
    NSString *key = [self downloadKey:operation.item];
    return [self.pauseAndResumeDict.allKeys containsObject:key];
}

- (NSMutableDictionary *)pauseAndResumeDict
{
    __block NSMutableDictionary *dict = nil;
    dispatch_sync(_resumeQueue, ^{
        dict = self->_pauseAndResumeDict;
    });
    return dict;
}

- (void)setPauseAndResumeOperation:(JCDownloadOperation *)operation forKey:(NSString *)key
{
    if (key.length < 1 || !operation) {
        return;
    }
    dispatch_barrier_async(_resumeQueue, ^{
        self->_pauseAndResumeDict[key] = operation;
    });
}

- (void)removePauseAndResumeOperationForKey:(NSString *)key
{
    if (key.length < 1) {
        return;
    }
    dispatch_barrier_async(_resumeQueue, ^{
        [self->_pauseAndResumeDict removeObjectForKey:key];
    });
}

#pragma mark - Network

- (NSURLSessionDownloadTask *)downloadTaskWithOperation:(JCDownloadOperation *)operation
{
    NSURLSessionDownloadTask *task = nil;
    NSData *resumeData = [self validResumeData:operation.item];
    __weak __typeof(self)weakSelf = self;
    if (resumeData) {
        task = [self.manager downloadTaskWithResumeData:resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf downloadWithOperation:operation
                                         progress:downloadProgress];
                [strongSelf removePauseAndResumeOperation:operation];
            });
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:operation.item.downloadFilePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf completionWithOperation:operation
                                       filePath:filePath
                                          error:error];
        }];
        [task resume];
    } else {
        NSError *serializationError = nil;
        NSMutableURLRequest *urlRequest = [self.manager.requestSerializer requestWithMethod:@"GET" URLString:[operation.item.downloadUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] parameters:nil error:&serializationError];
        if (serializationError) {
            [self completionWithOperation:operation
                                 filePath:nil
                                    error:serializationError];
            return nil;
        }
        task = [self.manager downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf downloadWithOperation:operation
                                         progress:downloadProgress];
                [strongSelf pauseAndResumeOperation:operation];
            });
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:operation.item.downloadFilePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (error && [strongSelf isPauseAndResumeOperation:operation]) {
                return;
            }
            [strongSelf completionWithOperation:operation
                                       filePath:filePath
                                          error:error];
        }];
        [task resume];
    }
    return task;
}

- (void)downloadWithOperation:(JCDownloadOperation *)operation
                     progress:(NSProgress *)progress
{
    if (!progress) {
        return;
    }
    operation.item.totalUnitCount = progress.totalUnitCount;
    operation.item.completedUnitCount = progress.completedUnitCount;
    [[NSNotificationCenter defaultCenter] postNotificationName:JCDownloadProgressNotification
                                                        object:nil
                                                      userInfo:@{JCDownloadIdKey:operation.item.downloadId, JCDownloadProgressKey:progress}];
    if (operation.progressBlock) {
        operation.progressBlock(progress);
    }
}

- (void)completionWithOperation:(JCDownloadOperation *)operation
                       filePath:(NSURL *)filePath
                          error:(NSError *)error
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (error) {
        userInfo[JCDownloadCompletionErrorKey] = error;
        if (operation.item.status == JCDownloadStatusDownloading) {
            operation.item.status = JCDownloadStatusUnknownError;
        }
        if (error.code != NSURLErrorCancelled
            && [error.userInfo.allKeys containsObject:NSURLSessionDownloadTaskResumeData]) {
            [self saveResumeData:error.userInfo[NSURLSessionDownloadTaskResumeData]
                    downloadItem:operation.item];
        }
    } else if (filePath) {
        userInfo[JCDownloadCompletionFilePathKey] = filePath;
        operation.item.status = JCDownloadStatusFinished;
        [self removeResumeData:operation.item];
    }
    
    if (userInfo.count > 0) {
        userInfo[JCDownloadIdKey] = operation.item.downloadId;
        [[NSNotificationCenter defaultCenter] postNotificationName:JCDownloadCompletionNotification
                                                            object:nil
                                                          userInfo:userInfo];
    }
    if (operation.completionBlock) {
        operation.completionBlock(filePath, error);
    }
    [operation finishDownload];
}

@end
