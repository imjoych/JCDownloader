//
//  JCDownloadAgent.h
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/21.
//  Copyright © 2016 Joych<https://github.com/imjoych>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCDownloadOperationProtocol.h"

/**
 * The criteria by which server trust should be evaluated against the pinned SSL certificates.
 */
typedef NS_ENUM(NSUInteger, JCDownloadSSLPinningMode) {
    JCDownloadSSLPinningModeNone,
    JCDownloadSSLPinningModePublicKey,
    JCDownloadSSLPinningModeCertificate,
};

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

/**
 * Set security policy for HTTPS.
 * @param SSLPinningMode The criteria by which server trust should be evaluated against the pinned SSL certificates.
 * @param pinnedCertificates The certificates used to evaluate server trust according to the SSL pinning mode.
 * @param allowInvalidCertificates Whether or not to trust servers with an invalid or expired SSL certificates.
 * @param validatesDomainName Whether or not to validate the domain name in the certificate's CN field.
 */
- (void)setSecurityPolicyWithSSLPinningMode:(JCDownloadSSLPinningMode)SSLPinningMode
                         pinnedCertificates:(NSSet<NSData *> *)pinnedCertificates
                   allowInvalidCertificates:(BOOL)allowInvalidCertificates
                        validatesDomainName:(BOOL)validatesDomainName;

@end
