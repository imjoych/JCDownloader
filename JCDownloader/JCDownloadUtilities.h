//
//  JCDownloadUtilities.h
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/23.
//  Copyright © 2016 Boych<https://github.com/Boych>. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 下载工具类 */
@interface JCDownloadUtilities : NSObject

/** 字符串MD5加密 */
+ (NSString *)md5WithString:(NSString *)string;

/** 获取文件路径（NSCachesDirectory目录下）
 @param fileName 文件名
 @param folderName 文件夹名称（可为空）
 */
+ (NSString *)filePathWithFileName:(NSString *)fileName
                        folderName:(NSString *)folderName;

#pragma mark - Size

/** 计算文件大小 */
+ (int64_t)fileSizeWithFilePath:(NSString *)filePath;

/** 文件大小字符串 */
+ (NSString *)sizeStringWithFileSize:(int64_t)fileSize;

/** 设备剩余空间 */
+ (int64_t)deviceFreeSpace;

/** 设备总空间 */
+ (int64_t)deviceTotalSpace;

@end
