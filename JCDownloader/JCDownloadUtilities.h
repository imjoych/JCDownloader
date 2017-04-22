//
//  JCDownloadUtilities.h
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/23.
//  Copyright © 2016 Joych<https://github.com/imjoych>. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Download utilities class. */
@interface JCDownloadUtilities : NSObject

/** Md5 of string. */
+ (NSString *)md5WithString:(NSString *)string;

/** Return file path (In NSCachesDirectory) with fileName and folderName. */
+ (NSString *)filePathWithFileName:(NSString *)fileName
                        folderName:(NSString *)folderName;

#pragma mark - Size

/** Calculate size of file at filePath. */
+ (int64_t)fileSizeWithFilePath:(NSString *)filePath;

/** Size string of file size which keep to two decimal places. */
+ (NSString *)sizeStringWithFileSize:(int64_t)fileSize;

/** Device free space. */
+ (int64_t)deviceFreeSpace;

/** Device total space. */
+ (int64_t)deviceTotalSpace;

@end
