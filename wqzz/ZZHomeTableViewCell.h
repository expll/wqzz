//
//  ZZHomeTableViewCell.h
//  wqzz
//
//  Created by Tiny on 15/9/6.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZBookView.h"

@interface ZZHomeTableViewCell : UITableViewCell

@property (assign, nonatomic) NSInteger section;
@property (assign, nonatomic) NSInteger row;
@property (nonatomic, weak) NSArray *cellData;


@end
