//
//  ZZBookView.m
//  wqzz
//
//  Created by Tiny on 15/9/7.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import "ZZBookView.h"
#import "ZZBook.h"
#import "ZZDataSource.h"
#import "ZZDataViewController.h"
#import "ZZModelController.h"



CGPDFDocumentRef GetPDFDocumentRef(NSString *filename)
{
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    size_t count;
    
    path = CFStringCreateWithCString (NULL, [filename UTF8String], kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, 0);
    
    CFRelease (path);
    document = CGPDFDocumentCreateWithURL (url);
    CFRelease(url);
    count = CGPDFDocumentGetNumberOfPages (document);
    if (count == 0) {
        printf("[%s] needs at least one page!\n", [filename UTF8String]);
        return NULL;
    } else {
        printf("[%ld] pages loaded in this PDF!\n", count);
    }
    return document;
}


@interface ZZBookView()
{
    BOOL IsNotificationRegisted;
}

@end

@implementation ZZBookView
@synthesize modelController = _modelController;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


- (void)drawRect:(CGRect)rect {

    if (IsNotificationRegisted == NO) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeProgess:) name:@"ChangeProgress" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadComplete:) name:@"DownloadComplete" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadCancel:) name:@"CancelDownload" object:nil];
        IsNotificationRegisted = YES;
    }
    
 
    
    [self handleStatus];
}
- (IBAction)ClickDLPressed:(id)sender {

    ZZBook *book = self.book;
    
    switch (book.status) {
        case ZZB_Downloaded:
        {
            NSLog(@"阅读杂志");
            [self readBook];
            
        } break;
            
        case ZZB_Downloading:
        {
            book.status = ZZB_Pause;
            [self setNeedsDisplay];
            NSLog(@"暂停下载");
            [self pauseDownload];
            
            
        } break;
        case ZZB_Pause:
        {
            book.status = ZZB_Downloading;
            [self setNeedsDisplay];
            
            NSLog(@"继续下载");
            [self continuDownload];
            
        } break;
        case ZZB_NotDownload:
        {
            book.status = ZZB_Downloading;
            [self setNeedsDisplay];
            
            NSLog(@"开始下载");
            [self beginDownload];
            
        } break;
            
        default:
            break;
    }
    
    [ZZDataSource book_save:book];

    
}

- (void)handleStatus
{
    switch (self.book.status) {
        case ZZB_Downloaded:
        {
            self.DLing.hidden = YES;
            self.NotDL.hidden = YES;
            
        } break;
            
        case ZZB_Downloading:
        {
            self.DLing.hidden = NO;
            self.NotDL.hidden = YES;
            [self continuDownload];
            
        } break;
        case ZZB_Pause:
        {
            self.DLing.hidden = NO;
            self.NotDL.hidden = YES;
            self.DLProgress.progress = self.book.downloadProgress/100;
            self.DLLabel.text = [NSString stringWithFormat:@"已暂停(%.2f%%)", self.book.downloadProgress];
            
        } break;
        case ZZB_NotDownload:
        {
            self.DLing.hidden = YES;
            self.NotDL.hidden = NO;
            
        } break;
            
        default:
            break;
    }
}

- (void)changeProgess:(id)noti
{
    id object = [noti object];
    NSString *url = object[@"url"];
    double progress = [object[@"paramProgress"] doubleValue];
    if ([self.book.url isEqualToString:url]) {
        self.DLProgress.progress = progress;
        self.book.downloadProgress = progress*100;
        NSString *string = [NSString stringWithFormat:@"下载中(%.2f%%)", progress*100];
        self.DLLabel.text = string;
        
        [self setNeedsDisplay];
    }

}

- (void)downloadCancel:(id)noti
{
    
    if (self.book.status == ZZB_Downloading) {
        self.book.status = ZZB_Pause;
        [self setNeedsDisplay];
    }
    
}

- (void)downloadComplete:(id)noti
{
    id object = [noti object];
    NSString *url = object[@"url"];
    

    if ([self.book.url isEqualToString:url]) {
        self.book.status = ZZB_Downloaded;
        [ZZDataSource book_save:self.book];
        [self setNeedsDisplay];
    }
}


- (void)readBook
{
    self.pageViewController = [[ZZPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.bookName = self.book.name;
    self.pageViewController.delegate = self;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *filepath = [[documentDirectory stringByAppendingPathComponent:self.book.code] stringByAppendingString:@".pdf"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        NSLog(@"文件不存在、或者已损坏");
        return;
    }
    
    if (self.document == nil) {
        self.document = GetPDFDocumentRef(filepath);
    }

    NSInteger count = CGPDFDocumentGetNumberOfPages (self.document);
    self.pageViewController.bookPageNum = count;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < count; i++) {
        [arr addObject:@(i)];
    }
    
    
    if (!_modelController) {
        _modelController = [[ZZModelController alloc] init];
        _modelController.pageData = @{filepath:arr};
    }
    
    ZZDataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:[[[UIApplication sharedApplication] delegate] window].rootViewController.storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.pageViewController.dataSource = self.modelController;
    
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    [(id)topController pushViewController:_pageViewController animated:YES];
    
    
    //[topController presentViewController:_pageViewController animated:YES completion:nil];
    
}

- (void)pauseDownload
{
    [ZZDataSource book_cancelDownload:self.book];
}

- (void)continuDownload
{
    [ZZDataSource book_continuDownload:self.book];
}

- (void)beginDownload
{
    [ZZDataSource book_download:self.book];
}


#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        
        UIViewController *currentViewController = self.pageViewController.viewControllers[0];
        NSArray *viewControllers = @[currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }
    
    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    ZZDataViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = nil;
    
    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = @[previousViewController, currentViewController];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    
    return UIPageViewControllerSpineLocationMid;
}




@end
