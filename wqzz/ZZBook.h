//
//  ZZBook.h
//  wqzz
//
//  Created by Tiny on 15/9/7.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    ZZB_Downloaded,
    ZZB_Downloading,
    ZZB_Pause,
    ZZB_NotDownload,
}ZZBookStatus;

@interface ZZBook : NSObject

@property(strong, nonatomic)NSString *name;
@property(strong, nonatomic)NSString *code;
@property(strong, nonatomic)NSString *image;
@property(strong, nonatomic)NSString *url;
@property(assign, nonatomic)ZZBookStatus status;
@property(assign, nonatomic)NSInteger readedIndex;
@property(assign, nonatomic)double downloadProgress;


@end
