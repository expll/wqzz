//
//  ZZDataViewController.h
//  TEST
//
//  Created by Tiny on 15/9/8.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZPDFView.h"

@interface ZZDataViewController : UIViewController

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSString *pdffile;
@property (weak, nonatomic) IBOutlet ZZPDFView *PDFView;

@end

