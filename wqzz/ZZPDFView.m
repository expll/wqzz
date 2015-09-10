//
//  ZZPDFView.m
//  wqzz
//
//  Created by Tiny on 15/9/10.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import "ZZPDFView.h"
extern CGPDFDocumentRef GetPDFDocumentRef(NSString *filename);

@implementation ZZPDFView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.frame.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    [self DisplayPDFPage:context :self.index+1 :self.pdffile];

}




- (void) DisplayPDFPage:(CGContextRef)myContext:(size_t)pageNumber:(NSString *)filename
{
    CGPDFPageRef page;
    
    if (!self.document) {
        self.document = GetPDFDocumentRef (filename);
    }
    _document = GetPDFDocumentRef (filename);
    page = CGPDFDocumentGetPage (_document, pageNumber);
    CGContextDrawPDFPage (myContext, page);
    CGPDFDocumentRelease (_document);
}


@end
