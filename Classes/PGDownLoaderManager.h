//
//  PGDownLoaderManager.h
//  PGContinueDownload
//
//  Created by 印度阿三 on 2018/12/27.
//  Copyright © 2018 印度阿三. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGDownLoader.h"
NS_ASSUME_NONNULL_BEGIN

@interface PGDownLoaderManager : NSObject
+ (instancetype)shareInstance;

/**
 下载文件没有对文件的完整性进行校验
 */
- (void)downLoadWithURL:(NSURL *)url
               msgBlock:(void(^)(long long totalSize, NSString *downLoadedPath))msgBlock
               progress:(void(^)(float progress))progressBlock
                success:(void(^)(NSString *filePath))successBlock
                 failed:(void(^)(NSString *errorMsg))failedBlock;
/**
 下载文件并对文件的完整性进行校验

 @param url 文件地址
 @param fileMd5 所要下载的文件摘要
 @param msgBlock 下载信息
 @param progressBlock 下载过程
 @param successBlock 下载成功
 @param failedBlock 下载失败
 */
- (void)downLoadWithURL:(NSURL *)url
           fileAbstract:(NSString *)fileMd5
               msgBlock:(void(^)(long long totalSize, NSString *downLoadedPath))msgBlock
               progress:(void(^)(float progress))progressBlock
                success:(void(^)(NSString *filePath))successBlock
                 failed:(void(^)(NSString *errorMsg))failedBlock;

/** 取消 */
- (void)cancel:(NSURL *)url;
/** 暂停 */
- (void)pause:(NSURL *)url;
/** 恢复 */
- (void)resume:(NSURL *)url;
/** 删除 */
- (void)cancelAndClean:(NSURL *)url;
/**暂停所有*/
- (void)pauseAll;


@end

NS_ASSUME_NONNULL_END
