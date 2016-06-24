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

/** File download agent class. */
@interface JCDownloadAgent : NSObject <JCDownloadOperationProtocol>

@property (nonatomic, assign) int64_t minFileSizeForAutoProducingResumeData; ///< minimum file size for automatically producing resumeData, default is 2M.

/** Singleton instance of JCDownloadAgent. */
+ (instancetype)sharedAgent;

/** Check file is downloaded or not. */
- (BOOL)isFileDownloaded:(JCDownloadItem *)downloadItem;

/** Delete downloaded files. 
 *  @param downloadItem download operation info. It is prohibited to call the method when the download task is in the progress, which avoid conflicts with the system to write or delete the download temporary files.
 */
- (void)removeDownloadFile:(JCDownloadItem *)downloadItem;

@end
