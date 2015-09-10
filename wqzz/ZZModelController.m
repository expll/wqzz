//
//  ModelController.m
//  TEST
//
//  Created by Tiny on 15/9/8.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import "ZZModelController.h"
#import "ZZDataViewController.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


@interface ZZModelController ()


@end

@implementation ZZModelController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create the data model.
        
    }
    return self;
}

- (ZZDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // Return the data view controller for the given index.
    NSString *key = [[self.pageData allKeys] firstObject];
    if (([self.pageData[key] count] == 0) || (index >= [self.pageData[key] count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    ZZDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"ZZDataViewController"];


    
    //dataViewController.dataObject = self.pageData[index];
    dataViewController.index = [self.pageData[key][index] integerValue];
    dataViewController.pdffile = key;
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(ZZDataViewController *)viewController {
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
//    return [self.pageData indexOfObject:viewController.dataObject];
    return viewController.index;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(ZZDataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(ZZDataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    NSString *key = [[self.pageData allKeys] firstObject];
    if (index == [self.pageData[key] count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
