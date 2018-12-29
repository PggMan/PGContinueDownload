//
//  NSString+PGMD5.h
//  PGContinueDownload
//
//  Created by 印度阿三 on 2018/12/27.
//  Copyright © 2018 印度阿三. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (PGMD5)
- (NSString *)pg_md5String;
+ (NSString *)pg_getFileMD5WithPath:(NSString*)path;
@end

NS_ASSUME_NONNULL_END
