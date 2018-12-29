# PGContinueDownload

[![CI Status](https://img.shields.io/travis/PggMan/PGContinueDownload.svg?style=flat)](https://travis-ci.org/PggMan/PGContinueDownload)
[![Version](https://img.shields.io/cocoapods/v/PGContinueDownload.svg?style=flat)](https://cocoapods.org/pods/PGContinueDownload)
[![License](https://img.shields.io/cocoapods/l/PGContinueDownload.svg?style=flat)](https://cocoapods.org/pods/PGContinueDownload)
[![Platform](https://img.shields.io/cocoapods/p/PGContinueDownload.svg?style=flat)](https://cocoapods.org/pods/PGContinueDownload)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PGContinueDownload is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PGContinueDownload'
```

## Use
```objc-c
  
 [[PGDownLoaderManager shareInstance] downLoadWithURL:kURL msgBlock:^(long long totalSize, NSString * _Nonnull downLoadedPath) {
        NSLog(@"开始下载");
    } progress:^(float progress) {
        NSLog(@"下载中--%f", progress);
    } success:^(NSString * _Nonnull downLoadedPath) {
        NSLog(@"完成");
    } failed:^(NSString * _Nonnull errorMsg) {
        NSLog(@"失败");
    }];

```

## Author

PggMan, gepeng7711@gmail.com

## License

PGContinueDownload is available under the MIT license. See the LICENSE file for more info.
