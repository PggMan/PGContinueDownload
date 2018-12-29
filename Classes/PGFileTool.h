//
//  PGFileTool.h
//  PGContinueDownload
//
//  Created by 印度阿三 on 2018/12/27.
//  Copyright © 2018 印度阿三. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGFileTool : NSObject

/**
 通过路径查找文件，若不存在则在次路径下创建

 @param path 路径
 @return 是否创建成功
 */
+ (BOOL)createDirectoryIfNotExists:(NSString *)path;

/**
 文件是否存在
 
 @param path 路径
 @return 是否存在
 */
+ (BOOL)fileExistsAtPath:(NSString *)path;

/**
 文件大小
 
 @param path 路径
 @return 文件大小
 */
+ (long long)fileSizeAtPath:(NSString *)path;

/**
 删除文件
 
 @param path 删除指定文件
 */
+ (void)removeFileAtPath:(NSString *)path;


/**
 

 @param fromPath 原地址
 @param toPath 新地址
 */

/**
 移动文件

 @param fromPath 原地址
 @param toPath 新地址
 @return 是否移动成功
 */
+ (BOOL)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
@end

NS_ASSUME_NONNULL_END
