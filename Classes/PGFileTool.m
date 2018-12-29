//
//  PGFileTool.m
//  PGContinueDownload
//
//  Created by 印度阿三 on 2018/12/27.
//  Copyright © 2018 印度阿三. All rights reserved.
//

#import "PGFileTool.h"

#define KFileManager [NSFileManager defaultManager]

@implementation PGFileTool

+ (BOOL)createDirectoryIfNotExists:(NSString *)path{
    
    if (path.length <= 0) return NO;
    NSFileManager *mgr = KFileManager;
    if (![mgr fileExistsAtPath:path]) {
        NSError *error;
        [mgr createDirectoryAtPath:path
       withIntermediateDirectories:YES
                        attributes:nil
                             error:&error];
        
        if (error)return NO;
    }
    return YES;
}

+ (BOOL)fileExistsAtPath:(NSString *)path{
    NSFileManager *mgr = KFileManager;
    
    return [mgr fileExistsAtPath:path];
}

+ (long long)fileSizeAtPath:(NSString *)path{
    
    if (![self fileExistsAtPath:path]) return 0;
    
    NSFileManager *mgr = KFileManager;
    NSDictionary *fileInfoDic = [mgr attributesOfItemAtPath:path error:nil];
    
    return  [fileInfoDic[NSFileSize] longLongValue];
}

+ (void)removeFileAtPath:(NSString *)path {
    
    if (![self fileExistsAtPath:path]) return;
    
    NSFileManager *mgr = KFileManager;
    [mgr removeItemAtPath:path error:nil];
    
}

+ (BOOL)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    
    if (![self fileExistsAtPath:fromPath]) return NO;
    NSError *error;
    NSFileManager *mgr = KFileManager;
    [mgr moveItemAtPath:fromPath toPath:toPath error:&error];
    
    return !error;
}

@end
