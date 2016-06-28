# JCDownloader
A useful iOS downloader framework based on [AFNetworking](https://github.com/AFNetworking/AFNetworking).

## Features
This framework supports the development of iOS 7.0+ in ARC.

* Single file download start/pause/remove operation and so on.
* File list downloads with groupId.
* Breakpoint downloading supported.

### Single file download
```objective-c
JCDownloadItem *downloadItem = [[JCDownloadItem alloc] init];
downloadItem.downloadUrl = @"download url";
downloadItem.downloadFilePath = @"download file path";
self.operation = [JCDownloadOperation operationWithItem:downloadItem];
[self.operation startWithProgressBlock:^(NSProgress *progress) {
    //update progress
} completionBlock:^(NSURL *filePath, NSError *error) {
    //download operation completion, do something
}];
```

```objective-c
[self.operation resetProgressBlock:^(NSProgress *progress) {
    //update progress
} completionBlock:^(NSURL *filePath, NSError *error) {
    //download operation completion, do something
}];
```

```objective-c
[self.operation pauseDownload];
```

```objective-c
[self.operation removeDownload];
```

### File list downloads

```objective-c
extern NSString *const JCTImageDownloadGroupId;
```

```objective-c
NSMutableArray *downloadList = [NSMutableArray array];
for (NSInteger index = 0; index < [self urlList].count; index++) {
    JCTImageDownloadItem *item = [[JCTImageDownloadItem alloc] init];
    item.groupId = JCTImageDownloadGroupId;
    item.downloadUrl = [self urlList][index];
    item.downloadFilePath = [JCDownloadUtilities filePathWithFileName:[item.downloadUrl lastPathComponent] folderName:@"downloadImages"];
    JCDownloadOperation *operation = [JCDownloadOperation operationWithItem:item];
    [downloadList addObject:operation];
}
[[JCDownloadQueue sharedQueue] startDownloadList:downloadList];
```

```objective-c
[[JCDownloadQueue sharedQueue] startDownloadsWithGroupId:JCTImageDownloadGroupId];
```

```objective-c
[[JCDownloadQueue sharedQueue] pauseDownloadsWithGroupId:JCTImageDownloadGroupId];
```

```objective-c
[[JCDownloadQueue sharedQueue] removeDownloadsWithGroupId:JCTImageDownloadGroupId];
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
