//
//  ModelController.h
//  TEST
//
//  Created by Tiny on 15/9/8.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZZDataViewController;

@interface ZZModelController : NSObject <UIPageViewControllerDataSource>

@property (strong, nonatomic) id pageData;

- (ZZDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(ZZDataViewController *)viewController;

@end

