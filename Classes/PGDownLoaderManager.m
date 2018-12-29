//
//  PGDownLoaderManager.m
//  PGContinueDownload
//
//  Created by 印度阿三 on 2018/12/27.
//  Copyright © 2018 印度阿三. All rights reserved.
//

#import "PGDownLoaderManager.h"
#import "NSString+PGMD5.h"
@interface PGDownLoaderManager() <NSCopying, NSMutableCopying>
// key : url MD5  value: 下载器
@property (nonatomic, strong) NSMutableDictionary *infoDic;
@end
static PGDownLoaderManager *_shareInstance;
@implementation PGDownLoaderManager

#pragma mark - 单例
+ (instancetype)shareInstance{
    if (!_shareInstance) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _shareInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _shareInstance;
}


#pragma mark - 下载
- (void)downLoadWithURL:(NSURL *)url
               msgBlock:(void(^)(long long totalSize, NSString *downLoadedPath))msgBlock
               progress:(void(^)(float progress))progressBlock
                success:(void(^)(NSString *filePath))successBlock
                 failed:(void(^)(NSString *errorMsg))failedBlock{
    
    [self downLoadWithURL:url
             fileAbstract:@"-1"
                 msgBlock:msgBlock
                 progress:progressBlock
                  success:successBlock
                   failed:failedBlock];
}

- (void)downLoadWithURL:(NSURL *)url
           fileAbstract:(NSString *)fileMd5
               msgBlock:(void(^)(long long totalSize, NSString *downLoadedPath))msgBlock
               progress:(void(^)(float progress))progressBlock
                success:(void(^)(NSString *filePath))successBlock
                 failed:(void(^)(NSString *errorMsg))failedBlock{
    
    
    NSString *md5Url =  [url.absoluteString pg_md5String];
    PGDownLoader *loader = [self.infoDic objectForKey:md5Url];
    if (!loader) {
        loader = [[PGDownLoader alloc] init];
        [self.infoDic setObject:loader forKey:md5Url];
    }
    
    loader.fileMd5 = fileMd5;
    [loader downLoadWithURL:url
                   msgBlock:msgBlock
                   progress:progressBlock
                    success:successBlock
                     failed:failedBlock];

    
    
    
}

- (void)pauseWithURL:(NSURL *)url {
    
    NSString *urlKey = [url.absoluteString pg_md5String];
    PGDownLoader *loader = self.infoDic[urlKey];
    [loader pause];
}

#pragma mark - 交互事件
- (void)pauseAll{
    [self.downLoadInfo.allValues performSelector:@selector(pause) withObject:nil];
    
}

- (void)cancel:(NSURL *)url{
    NSString *urlKey = [url.absoluteString pg_md5String];
    PGDownLoader *loader = self.infoDic[urlKey];
    [loader cancel];
    
}
- (void)pause:(NSURL *)url{
    NSString *urlKey = [url.absoluteString pg_md5String];
    PGDownLoader *loader = self.infoDic[urlKey];
    [loader pause];
}
- (void)resume:(NSURL *)url{
    NSString *urlKey = [url.absoluteString pg_md5String];
    PGDownLoader *loader = self.infoDic[urlKey];
    [loader resume];
}
- (void)cancelAndClean:(NSURL *)url{
    NSString *urlKey = [url.absoluteString pg_md5String];
    PGDownLoader *loader = self.infoDic[urlKey];
    [loader cancelAndClean];
}

#pragma mark - 懒加载
- (NSMutableDictionary *)downLoadInfo {
    if (!_infoDic) {
        _infoDic = [NSMutableDictionary dictionary];
    }
    return _infoDic;
}

@end
