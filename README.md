# JCDownloader
A useful iOS downloader framework based on [AFNetworking](https://github.com/AFNetworking/AFNetworking).

## Features
This framework supports the development of iOS 7.0+ in ARC.

* Files download (breakpoint downloading supported).


### Download
```objective-c
- (void)startDownloadOperation
{
	JCDownloadItem *downloadItem = [[JCDownloadItem alloc] init];
    downloadItem.downloadUrl = @"download url";
    downloadItem.downloadFilePath = @"download file path";
    self.operation = [JCDownloadOperation operationWithItem:downloadItem];
    [self.operation startWithProgressBlock:^(NSProgress *progress) {
        //update progress
    } completionBlock:^(NSURL *filePath, NSError *error) {
        //download operation completion, do something
    }];
}
```

## CocoaPods
To integrate JCDownloader into your iOS project, specify it in your Podfile:
    
	pod 'JCDownloader'

##Contacts
If you have any questions or suggestions about the framework, please E-mail to contact me.

Author: [Boych](https://github.com/Boych)	
E-mail: ioschen@foxmail.com

## License
JCDownloader is released under the [MIT License](https://github.com/Boych/JCDownloader/blob/master/LICENSE).
