//
//  ZZBookView.h
//  wqzz
//
//  Created by Tiny on 15/9/7.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZBook.h"
#import "ZZModelController.h"
#import "ZZPageViewController.h"

@interface ZZBookView : UIView
@property (weak, nonatomic) IBOutlet UILabel *DLLabel;
@property (weak, nonatomic) IBOutlet UIView *DLing;
@property (weak, nonatomic) IBOutlet UILabel *NotDL;
@property (weak, nonatomic) IBOutlet UIProgressView *DLProgress;
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (strong, nonatomic) ZZBook *book;

@property(nonatomic, strong)ZZPageViewController *pageViewController;
@property (readonly, strong, nonatomic) ZZModelController *modelController;
@property(nonatomic) CGPDFDocumentRef document;

@end
