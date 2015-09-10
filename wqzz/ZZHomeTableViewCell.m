//
//  ZZHomeTableViewCell.m
//  wqzz
//
//  Created by Tiny on 15/9/6.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import "ZZHomeTableViewCell.h"
#import "ZZBookView.h"
#import "ZZDataSource.h"
#define Landscape [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height

@implementation ZZHomeTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    // 四本书
    for (id sub in [self.contentView subviews]) {
        [sub removeFromSuperview];
    }
    
    NSInteger count;
    if (Landscape) {
        count = 4;
    } else {
        count = 3;
    }
    
    CGPoint origin = CGPointMake(65-240, 25);
    for (int i = 0; i < count; i++) {
        
        ZZBookView *bookview = [[[NSBundle mainBundle] loadNibNamed:@"ZZBookView" owner:nil options:nil] firstObject];
        origin.x += 240;
        CGRect frame = bookview.frame;
        frame.origin = origin;
        bookview.frame = frame;
        bookview.book = [ZZDataSource book_getByIndex:(self.row*count +i)];
        NSLog(@"%d---%@",self.row*count +i, bookview.book);
        bookview.ImageView.image = [UIImage imageNamed:bookview.book.image];
        bookview.DLLabel.adjustsFontSizeToFitWidth = YES;
        
        if (bookview.book == nil) {
            continue;
        }
        
        [self.contentView addSubview:bookview];
        
    }
}


@end
