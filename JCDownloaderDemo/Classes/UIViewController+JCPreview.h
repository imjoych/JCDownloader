//
//  UIViewController+JCPreview.h
//  JCDownloader
//
//  Created by ChenJianjun on 2017/2/15.
//  Copyright © 2017 Joych<https://github.com/imjoych>. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (JCPreview)

- (void)jc_openPDFWithURL:(NSURL *)url
                    title:(NSString *)title
               completion:(void(^)(BOOL success))completion;

@end
