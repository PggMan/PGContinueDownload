//
//  PGDownLoader.h
//  PGContinueDownload
//
//  Created by 印度阿三 on 2018/12/27.
//  Copyright © 2018 印度阿三. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PGDownLoaderState) {
    PGDownLoaderStateNot,
    PGDownLoaderStatePause,
    PGDownLoaderStateDowning,
    PGDownLoaderStateSuccess,
    PGDownLoaderStateFailed
};


@interface PGDownLoader : NSObject

//下载文件的md5值
@property(nonatomic,copy) NSString *fileMd5;

- (void)downLoadWithURL:(NSURL *)url;
- (void)downLoadWithURL:(NSURL *)url
               msgBlock:(void(^)(long long totalSize, NSString *downLoadedPath))msgBlock
               progress:(void(^)(float progress))progressBlock
                success:(void(^)(NSString *filePath))successBlock
                 failed:(void(^)(NSString *errorMsg))failedBlock;


- (void)cancel;
- (void)pause;
- (void)resume;
- (void)cancelAndClean;
@end

NS_ASSUME_NONNULL_END
