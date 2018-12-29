///
//  PGDownLoader.m
//  PGContinueDownload
//
//  Created by 印度阿三 on 2018/12/27.
//  Copyright © 2018 印度阿三. All rights reserved.
//

#import "PGDownLoader.h"
#import "PGFileTool.h"
#import "NSString+PGMD5.h"
#define kCache NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kMaskCode 999
@interface PGDownLoader()<NSURLSessionDataDelegate>
{
    long long _fileTmpSize;
    long long _totalSize;
    NSString *_filePathName;
    NSString *_temFilePathName;
}
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *temFilePath;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, weak) NSURLSessionDataTask *task;

@property(nonatomic,copy) void(^messageBlock)(long long totalSize, NSString *filePath);
@property(nonatomic,copy) void(^progressBlock)(float progress);
@property(nonatomic,copy) void(^loadSuccessBlock)(NSString *filePath);
@property(nonatomic,copy) void(^loadFailedBlock)(NSString *errorMsg);

/**下载状态*/
@property(nonatomic,assign)PGDownLoaderState state;
@end

@implementation PGDownLoader

#pragma mark -接口实现
- (void)downLoadWithURL:(NSURL *)url
               msgBlock:(void(^)(long long totalSize, NSString *downLoadedPath))msgBlock
               progress:(void(^)(float progress))progressBlock
                success:(void(^)(NSString *downLoadedPath))successBlock
                 failed:(void(^)(NSString *errorMsg))failedBlock;{
    
    self.messageBlock     = msgBlock;
    self.progressBlock    = progressBlock;
    self.loadSuccessBlock = successBlock;
    self.loadFailedBlock  = failedBlock;
    
    [self downLoadWithURL:url];
}

- (void)downLoadWithURL:(NSURL *)url{
    
    _filePathName = [self.filePath stringByAppendingPathComponent:url.lastPathComponent];
    
    _temFilePathName = [self.temFilePath stringByAppendingPathComponent:url.lastPathComponent];
    
    // 任务是否存在
    if ([url isEqual:self.task.originalRequest.URL]) {
        
        switch (self.state) {
            case PGDownLoaderStatePause:{
                
                [self resume];
                return;
                break;
            }
            case PGDownLoaderStateDowning:{
                return;
                break;
            }
            case PGDownLoaderStateSuccess:{
                !self.loadSuccessBlock?:
                self.loadSuccessBlock(self.filePath);
                return;
                
                break;
            }
            case PGDownLoaderStateFailed:{
                break;
            }
            default:
                break;
        }
    }
    
    //    // 检测, 本地有没有下载过临时缓存
    if ([PGFileTool fileExistsAtPath:_filePathName]) {
        !self.loadSuccessBlock?:
        self.loadSuccessBlock(_filePathName);
        
        return;
    }
    // 清空任务回话
    [self cancel];
    
    // 下载
    _fileTmpSize = [PGFileTool fileSizeAtPath:_temFilePathName];
    [self downLoadWithURL:url offset:_fileTmpSize];
}

#pragma mark - 私有API
- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset {
    
    NSUInteger state =NSURLRequestReloadIgnoringLocalCacheData;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:state
                                                       timeoutInterval:0];
    
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset]
   forHTTPHeaderField:@"Range"];
    
    self.task = [self.session dataTaskWithRequest:request];
    [self resume];
    
    self.state = PGDownLoaderStateDowning;
    
}

#pragma mark - 事件控制
// 清除回话
- (void)cancel{
    
    [self.session invalidateAndCancel];
    self.session = nil;
    self.state = PGDownLoaderStateNot;
}
// 恢复下载
- (void)resume{
    if ( self.state != PGDownLoaderStateDowning
        || self.state != PGDownLoaderStateSuccess) {
        
        [self.task resume];
        self.state = PGDownLoaderStateDowning;
    }
}

// 暂停
- (void)pause{
    if (self.state == PGDownLoaderStateDowning) {
        [self.task suspend];
        self.state = PGDownLoaderStatePause;
    }
}

// 停止并且清除
- (void)cancelAndClean{
    [self cancel];
    [PGFileTool removeFileAtPath:_temFilePathName];
    self.state = PGDownLoaderStateNot;
}

#pragma mark - NSURLSessionDataDelegate
/**
 第一次接受到下载信息 响应头信息的时候调用
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSString *rangeText = response.allHeaderFields[@"Content-Range"];
    _totalSize = [[rangeText componentsSeparatedByString:@"/"].lastObject longLongValue];
    if (_fileTmpSize == _totalSize && _totalSize != 0) {
        // 校验文件完整性
        if (self.fileMd5.integerValue > 0) {
            NSString *locFileMd5 = [NSString pg_getFileMD5WithPath:_temFilePathName];
            if ([self.fileMd5 isEqualToString:locFileMd5]) {
                [PGFileTool moveFileFromPath:_temFilePathName
                                      toPath:_filePathName];
                self.state = PGDownLoaderStateSuccess;
                return;
                
            }else{
                // 文件不完整
                _fileTmpSize += kMaskCode;
            }
            // 不校验
        }else{
            [PGFileTool moveFileFromPath:_temFilePathName
                                  toPath:_filePathName];
            self.state = PGDownLoaderStateSuccess;
            return;
        }
    }
    
    if (_fileTmpSize > _totalSize) {
        [PGFileTool removeFileAtPath:_temFilePathName];
        [PGFileTool removeFileAtPath:_filePathName];
        completionHandler(NSURLSessionResponseCancel);
        [self downLoadWithURL:response.URL];
    }
    
    !self.messageBlock?:
    self.messageBlock(_totalSize, _temFilePathName);
    
    self.outputStream = [NSOutputStream
                         outputStreamToFileAtPath:_temFilePathName
                         append:YES];
    
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
}
/**
 如果是可以接收后续数据, 那么在接收过程中, 就会调用这个方法
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    _fileTmpSize += data.length;
    
    
    !self.progressBlock?:
    self.progressBlock(1.0 * _fileTmpSize / _totalSize);
    
    [self.outputStream write:data.bytes
                   maxLength:data.length];
    
}

/**
 请求完毕, != 下载完毕
 */
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{
    if (!error){
        
        if (_fileTmpSize == _totalSize) {
            // 校验文件完整性
            // 校验
            if (self.fileMd5.integerValue > 0) {
                NSString *locFileMd5 = [NSString pg_getFileMD5WithPath:_filePathName];
                if ([self.fileMd5 isEqualToString:locFileMd5]) {
                    [PGFileTool moveFileFromPath:_temFilePathName
                                          toPath:_filePathName];
                    self.state = PGDownLoaderStateSuccess;
                    return;
                    
                }else{
                    self.state = PGDownLoaderStateFailed;
                    !self.loadFailedBlock?:self.loadFailedBlock(@"文件不完整");
                }
                // 不校验
            }else{
                [PGFileTool moveFileFromPath:_temFilePathName
                                      toPath:_filePathName];
                self.state = PGDownLoaderStateSuccess;
                return;
            }
        }
        
    }else{
        self.state = PGDownLoaderStateFailed;
        !self.loadFailedBlock?:self.loadFailedBlock(error.localizedDescription);
    }
    
    
}
#pragma mark - setter getter
- (NSURLSession *)session{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue new]];
    }
    
    return _session;
}

- (NSString *)filePath{
    
    NSString *path = [kCache stringByAppendingPathComponent:@"downLoader/downloaded"];
    BOOL result = [PGFileTool createDirectoryIfNotExists:path];
    if (result) return path;
    
    return @"";
}

- (NSString *)temFilePath {
    NSString *path = [kCache stringByAppendingPathComponent:@"downLoader/downloading"];
    BOOL result = [PGFileTool createDirectoryIfNotExists:path];
    if (result) {
        return path;
    }
    return @"";
    
}
@end
