//
//  JCTImageDownloadCell.m
//  JCDownloader
//
//  Created by ChenJianjun on 16/5/21.
//  Copyright © 2016 Boych<https://github.com/Boych>. All rights reserved.
//

#import "JCTImageDownloadCell.h"
#import "JCTImageDownloadItem.h"
#import "JCDownloader.h"

NSString *const JCTImageDownloadCellIdentifier = @"kJCTImageDownloadCellIdentifier";

@interface JCTImageDownloadCell ()

@property (nonatomic, strong) UIImageView *myImageView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation JCTImageDownloadCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressNotification:) name:JCDownloadProgressNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completionNotification:) name:JCDownloadCompletionNotification object:nil];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setItem:(JCTImageDownloadItem *)item
{
    if (!item) {
        return;
    }
    _item = item;
    [self resetProgressWithCompletedUnitCount:item.completedUnitCount
                               totalUnitCount:item.totalUnitCount];
    if (item.imageCache) {
        [self resetImage:item.imageCache];
        return;
    }
    [self reloadDownloadedImage];
}

#pragma mark -

- (void)progressNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (![self.item.downloadId isEqualToString:userInfo[JCDownloadIdKey]]) {
        return;
    }
    NSProgress *progress = userInfo[JCDownloadProgressKey];
    [self resetProgressWithCompletedUnitCount:progress.completedUnitCount
                               totalUnitCount:progress.totalUnitCount];
}

- (void)completionNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (![self.item.downloadId isEqualToString:userInfo[JCDownloadIdKey]]) {
        return;
    }
    if ([userInfo.allKeys containsObject:JCDownloadCompletionFilePathKey]) {
        [self reloadDownloadedImage];
    } else if ([userInfo.allKeys containsObject:JCDownloadCompletionErrorKey]) {
        [self resetImage:[UIImage imageNamed:@"默认图"]];
    }
    [self resetProgressWithCompletedUnitCount:self.item.completedUnitCount
                               totalUnitCount:self.item.totalUnitCount];
}

- (void)reloadDownloadedImage
{
    [self resetImage:[UIImage imageNamed:@"默认图"]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfFile:self.item.downloadFilePath];
        UIImage *image = [UIImage imageWithData:data];
        UIImage *scaledImage = [self scaleImage:image toSize:CGSizeMake(152, 112)];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (scaledImage) {
                self.item.imageCache = scaledImage;
                [self resetImage:scaledImage];
            } else {
                [self resetImage:[UIImage imageNamed:@"默认图"]];
            }
        });
    });
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size
{
    if (!image) {
        return nil;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void)resetProgressWithCompletedUnitCount:(int64_t)completedUnitCount
                             totalUnitCount:(int64_t)totalUnitCount
{
    if (totalUnitCount > 0) {
        [self resetProgress:(CGFloat)completedUnitCount/totalUnitCount];
    } else {
        [self resetProgress:0];
    }
    self.progressLabel.text = [NSString stringWithFormat:@"%@ / %@", [JCDownloadUtilities sizeStringWithFileSize:completedUnitCount], [JCDownloadUtilities sizeStringWithFileSize:totalUnitCount]];
}

- (void)resetProgress:(CGFloat)progress
{
    [self.progressView setProgress:progress];
}

- (void)resetImage:(UIImage *)image
{
    self.myImageView.image = image;
}

- (void)setupSubviews
{
    _myImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"默认图"]];
    [self.contentView addSubview:_myImageView];
    [_myImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.width.mas_equalTo(76);
    }];
    
    _progressView = [[UIProgressView alloc] init];
    _progressView.layer.cornerRadius = 2.f;
    _progressView.clipsToBounds = YES;
    [self.contentView addSubview:_progressView];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(10);
        make.height.mas_equalTo(4);
        make.left.mas_equalTo(_myImageView.mas_right).offset(8);
        make.right.mas_equalTo(-10);
    }];
    
    _progressLabel = [[UILabel alloc] init];
    _progressLabel.textAlignment = NSTextAlignmentRight;
    _progressLabel.textColor = [UIColor blackColor];
    _progressLabel.font = [UIFont systemFontOfSize:14.f];
    [self.contentView addSubview:_progressLabel];
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_progressView.mas_top);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(_myImageView.mas_right).offset(8);
        make.right.mas_equalTo(-12);
    }];
}

@end
