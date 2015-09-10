//
//  DataViewController.m
//  TEST
//
//  Created by Tiny on 15/9/8.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import "ZZDataViewController.h"
#import "ZZPDFView.h"

#define Landscape [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height

@interface ZZDataViewController ()

@end

@implementation ZZDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
//    UIView *barView = [[[[UIApplication sharedApplication] delegate] window] viewWithTag:123];
//    if (barView == nil) {
//        id bar = [self.storyboard instantiateViewControllerWithIdentifier:@"ZZCustomBar"];
//        barView = [bar view];
//        barView.tag = 123;
//        barView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44);
//        [[[[UIApplication sharedApplication] delegate] window] addSubview:barView];
//    }
    
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars =NO;
//    self.modalPresentationCapturesStatusBarAppearance =NO;
//    self.navigationController.navigationBar.translucent =NO;
    
    self.navigationController.navigationBar.hidden = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.dataLabel.text = [self.dataObject description];
    
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //self.ImageView.image = [UIImage imageWithContentsOfFile:self.dataObject];
    self.PDFView.index = self.index;
    self.PDFView.pdffile = self.pdffile;
    
}

- (void)viewDidLayoutSubviews
{
    
    if (Landscape) {
        // Landscape
        
    } else {
        // portrait

    }
}



- (IBAction)hideNavigationBar:(id)sender {
    
    if (self.navigationController.navigationBar.hidden == YES) {
        self.navigationController.navigationBar.hidden = NO;
    } else {
        self.navigationController.navigationBar.hidden = YES;
    }
    
    

}




@end
