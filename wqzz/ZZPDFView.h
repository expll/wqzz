//
//  ZZPDFView.h
//  wqzz
//
//  Created by Tiny on 15/9/10.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZZPDFView : UIView

@property(nonatomic, assign)NSInteger index;
@property(nonatomic) NSString *pdffile;
@property(nonatomic) CGPDFDocumentRef document;

@end
