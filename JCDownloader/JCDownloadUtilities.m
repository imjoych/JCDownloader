//
//  JCDownloadUtilities.m
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/23.
//  Copyright © 2016 Joych<https://github.com/imjoych>. All rights reserved.
//

#import "JCDownloadUtilities.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CoreGraphics/CoreGraphics.h>
#include <sys/mount.h>

static inline NSString *JCStringCCHashFunction(unsigned char *(function)(const void *data, CC_LONG len, unsigned char *md), CC_LONG digestLength, NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[digestLength];
    function(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:digestLength * 2];
    for (int i = 0; i < digestLength; i++) {
        [output appendFormat:@"%02X", digest[i]];
    }
    return output;
}

@implementation JCDownloadUtilities

+ (NSString *)md5WithString:(NSString *)string
{
    if (string.length < 1) {
        return nil;
    }
    return JCStringCCHashFunction(CC_MD5, CC_MD5_DIGEST_LENGTH, string);
}

+ (NSString *)filePathWithFileName:(NSString *)fileName
                        folderName:(NSString *)folderName
{
    if (fileName.length < 1) {
        return nil;
    }
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folderDirectory = cachesDirectory;
    if (folderName.length > 0) {
        folderDirectory = [NSString stringWithFormat:@"%@/%@", cachesDirectory, folderName];
    }
    BOOL isDirectory = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:folderDirectory isDirectory:&isDirectory];
    if (!(isExist && isDirectory)) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:folderDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    return [NSString stringWithFormat:@"%@/%@", folderDirectory, fileName];
}

#pragma mark - Size

+ (int64_t)fileSizeWithFilePath:(NSString *)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+ (NSString *)sizeStringWithFileSize:(int64_t)fileSize
{
    CGFloat kb = (CGFloat)fileSize / 1024;
    CGFloat mb = kb / 1024;
    CGFloat gb = mb / 1024;
    if (fileSize < 1024) {// < 1KB
        return [NSString stringWithFormat:@"%@B", @(fileSize)];
    } else if (mb < 1) {// < 1MB
        return [NSString stringWithFormat:@"%.2fK", kb];
    } else if (gb < 1) {// < 1GB
        return [NSString stringWithFormat:@"%.2fM", mb];
    } else { // >= 1GB
        return [NSString stringWithFormat:@"%.2fG", gb];
    }
}

+ (int64_t)deviceFreeSpace
{
    struct statfs buf;
    int64_t freeSpace = -1;
    if (statfs("/private/var", &buf) >= 0) {
        freeSpace = (int64_t)buf.f_bsize * buf.f_bfree;
    }
    return freeSpace;
}

+ (int64_t)deviceTotalSpace
{
    struct statfs buf;
    int64_t totalSpace = -1;
    if (statfs("/private/var", &buf) >= 0) {
        totalSpace = (int64_t)buf.f_bsize * buf.f_blocks;
    }
    return totalSpace;
}

@end
