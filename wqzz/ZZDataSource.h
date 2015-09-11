//
//  ZZDataSource.h
//  wqzz
//
//  Created by Tiny on 15/9/7.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZBook.h"

@interface ZZDataSource : NSObject

+ (void)InitZZDataSource;

+ (ZZBook *)book_getByIndex:(NSInteger)index;
+ (NSInteger)book_getCount;
+ (void)book_save:(ZZBook *)book;
+ (void)book_download:(ZZBook *)book;
+ (void)book_cancelDownload:(ZZBook *)book;
+ (void)book_continuDownload:(ZZBook *)book;




@end
