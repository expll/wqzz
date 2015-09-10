//
//  ZZDataSource.m
//  wqzz
//
//  Created by Tiny on 15/9/7.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import "ZZDataSource.h"
#import "FMDB.h"
#import "MKNetworkKit.h"
#import "Reachability.h"
#import "Toast+UIView.h"
#import "SIDownloadManager.h"
#import "SIBreakpointsDownload.h"
#import "ZipArchive.h"


FMDatabase *fmdb;
NSString *dbPath;
BOOL flag; // 非WIFI是否下载；

static CGPDFDocumentRef documents;
CGPDFDocumentRef SharedPDFdocument()
{
    return documents;
}
void SetSharedPDFdocument(CGPDFDocumentRef doc)
{
    documents = doc;
}

@interface ZZDataSource()
{
    
}

@end

@implementation ZZDataSource

+ (void)InitZZDataSource
{
    //[self net_check];
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    dbPath = [docPath stringByAppendingPathComponent:@"BOOKS.db"];
    
    //dbPath = @"/Users/tiny/Desktop/BOOKS.db";
    
    [ZZDataSource fmdb_createTable];
    NSInteger count = [ZZDataSource book_getCount];
    if (count == 0) {
        [ZZDataSource fmdb_insert];
    }
    
    
}



#pragma mark

+ (void)net_check
{
    Reachability *r = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
        {
            [[[[UIApplication sharedApplication] delegate] window] makeToast:@"世界上最遥远的距离是没有网络~"];
        }break;
        case ReachableViaWWAN:
        {
            [[[[UIApplication sharedApplication] delegate] window] makeToast:@"当前网络是2G/3G~"];
        }break;
        case ReachableViaWiFi:
        {
            [[[[UIApplication sharedApplication] delegate] window] makeToast:@"当前网络是WIFI~"];
        }break;
    }
    
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(net_reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    [r startNotifier];
    
    prestatus = [r currentReachabilityStatus];
}

static NetworkStatus prestatus;
+ (void)net_reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable) {
        [[[[UIApplication sharedApplication] delegate] window] makeToast:@"当前没网络，注意检查网络"];
        [[SIDownloadManager sharedSIDownloadManager] cancelAllDonloads];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelDownload" object:nil];
        
        
    } else {
        if (prestatus == NotReachable) {
            if (status == ReachableViaWWAN) {
                [[[[UIApplication sharedApplication] delegate] window] makeToast:@"当前网络是2G/3G~"];
            }
        }
    }
    
    
    
    
    
    
    prestatus = status;

}

#pragma mark

+ (ZZBook *)book_getByIndex:(NSInteger)index
{
    NSString *sql = [NSString stringWithFormat:@"select * from t_book where id = %d;", index+1];
    
    FMResultSet *resultSet = [fmdb executeQuery:sql];
    
    //2.遍历结果集合
    while ([resultSet next]) {
        
        NSString *name = [resultSet objectForColumnName:@"name"];
        NSString *code = [resultSet objectForColumnName:@"code"];
        NSString *image = [resultSet objectForColumnName:@"image"];
        NSString *url = [resultSet objectForColumnName:@"url"];
        NSInteger status = [resultSet intForColumn:@"status"];
        NSInteger readedIndex = [resultSet intForColumn:@"readedIndex"];
        float downloadProgress = [resultSet doubleForColumn:@"downloadProgress"];
        
        ZZBook *book = [[ZZBook alloc] init];
        book.name = name;
        book.code = code;
        book.image = image;
        book.url = url;
        book.status = status;
        book.readedIndex = readedIndex;
        book.downloadProgress = downloadProgress;
        
        return book;
        
    }

    return nil;
}

+ (NSInteger)book_getCount
{
    FMResultSet *resultSet = [fmdb executeQuery:@"select * from t_book where id > -1;"];
    NSInteger count = 0;
    while ([resultSet next]) {
        count++;
    }
    return count;
}

+ (void)book_save:(ZZBook *)book
{
    NSString *sql = [NSString stringWithFormat:@"update t_book set code='%@'  where name='%@'; update t_book set image='%@' where name='%@'; update t_book set url='%@'   where name='%@'; update t_book set status=%d  where name='%@'; update t_book set readedIndex=%d  where name='%@'; update t_book set downloadProgress=%.2f  where name='%@'",
                     book.code, book.name,
                     book.image, book.name,
                     book.url, book.name,
                     book.status, book.name,
                     book.readedIndex, book.name,
                     book.downloadProgress, book.name];
    BOOL result = [fmdb executeStatements:sql];
    
    if (result) {
        NSLog(@"保存成功");
    } else {
        NSLog(@"保存失败");
    }

}

+ (void)book_cancelDownload:(ZZBook *)book
{
    [[SIDownloadManager sharedSIDownloadManager] cancelDownloadFileTaskInQueue:book.url];
}

+ (void)book_continuDownload:(ZZBook *)book
{
    [self book_download:book];
}

+ (void)book_download:(ZZBook *)book
{
//    Reachability *r = [Reachability reachabilityWithHostname:@"www.baidu.com"];
//    if ([r currentReachabilityStatus] == ReachableViaWiFi) {
//        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"当前是2G/3G网络,是否继续下载?" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:@"继续", nil] show];
//        if (flag == NO) {
//            return;
//        }
//    }
    
    
    NSString *url = [book url];
    NSString *zipFile = [[url componentsSeparatedByString:@"/"] lastObject];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *file = [documentDirectory stringByAppendingPathComponent:zipFile];
    
    [[SIDownloadManager sharedSIDownloadManager] setDelegate:self];
    [[SIDownloadManager sharedSIDownloadManager] addDownloadFileTaskInQueue:book.url
                                                                 toFilePath:file
                                                           breakpointResume:YES
                                                                rewriteFile:NO];
}

#pragma -mark SIDownloadManagerDelegate
+ (void)downloadManagerDidComplete:(SIDownloadManager *)siDownloadManager
                     withOperation:(SIBreakpointsDownload *)paramOperation
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSString *url = [paramOperation url];
//        NSString *zipFile = [[url componentsSeparatedByString:@"/"] lastObject];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentDirectory = [paths objectAtIndex:0];
//        NSString *file = [documentDirectory stringByAppendingPathComponent:zipFile];
//        
//        ZipArchive *za = [[ZipArchive alloc] init];
//        if ([za UnzipOpenFile:file]) {
//            [za UnzipFileTo:documentDirectory overWrite:YES];
//        }
//        [za UnzipCloseFile];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadComplete" object:@{@"url":paramOperation.url }];
//        });
//        
//    });
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadComplete" object:@{@"url":paramOperation.url }];
    
    
}
+ (void)downloadManagerError:(SIDownloadManager *)siDownloadManager
                     withURL:(NSString *)paramURL
                   withError:(NSError *)paramError
{
    
}

+ (void)downloadManager:(SIDownloadManager *)siDownloadManager withOperation:(SIBreakpointsDownload *)paramOperation changeProgress:(double)paramProgress{

    

        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeProgress" object:@{@"paramProgress":@(paramProgress),
                                                                                              @"url":paramOperation.url
                                                                                              }];

    
    NSLog(@"downloading...%f", paramProgress);

}
+ (void)downloadManagerDownloadExist:(SIDownloadManager *)siDwonloadManager withURL:(NSString *)paramURL{}
+ (void)downloadManagerDownloadDone:(SIDownloadManager *)siDownloadManager withURL:(NSString *)paramURL{}
+ (void)downloadManagerPauseTask:(SIDownloadManager *)siDownloadManager withURL:(NSString *)paramURL{}

#pragma mark

+ (BOOL)fmdb_createTable
{
    fmdb = [[FMDatabase alloc] initWithPath:dbPath];
    if (![fmdb open]) {
        NSLog(@"数据库打开失败");
        return NO;
    }
    
    
    //NSString *sql = @"CREATE TABLE IF NOT EXISTS t_book(id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, code text NOT NULL, image text NOT NULL, url text NOT NULL, status integer NOT NULL, readedIndex integer NOT NULL);";
    
    NSString *sql = @"create table if not exists t_book (id integer primary key autoincrement, name text, code text, image text, url text, status integer, readedIndex integer, downloadProgress float);";
    BOOL result = [fmdb executeStatements:sql];
    

    if (result) {
        NSLog(@"创表成功");
    } else {
        NSLog(@"创表失败");
    }

    return result;
}


+(void)fmdb_insert
{
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"json"]] options:kNilOptions error:nil];
    
    
    for (id obj in jsonObject)
    {
        NSString *name = obj[@"name"];
        NSString *code = obj[@"code"];
        NSString *image = obj[@"image"];
        NSString *url = obj[@"url"];
        id status = obj[@"status"];
        id readedIndex = obj[@"readedIndex"];
        id downloadProgress = obj[@"downloadProgress"];
        
        NSString *sql = [NSString stringWithFormat:@"insert into t_book (name, code, image, url, status, readedIndex, downloadProgress) values ('%@','%@','%@','%@','%@', '%@', '%@');", name, code, image, url, status, readedIndex, downloadProgress];
        [fmdb executeStatements:sql];

    }
    
}


+(void)fmdb_delete:(id)idNum
{
    [fmdb executeUpdate:@"delete from t_book where id=?;", idNum];
}

+(void)fmdb_drop
{
    [fmdb executeUpdate:@"drop table if exists t_book;"];

}


+(void)fmdb_update:(NSDictionary *)dic
{
    // key 是 old
    // value 是 new
    
    for (id key in [dic allKeys]) {
        NSString *sql = [NSString stringWithFormat:@"update t_book set %@=? where %@=?", key, key];
        [fmdb executeUpdate:sql, dic[key], key];
    }
    
}

+(void)query
{
    //1.执行查询语句
    // FMResultSet *resultSet = [self.db executeQuery:@"select * from t_student;"];
    FMResultSet *resultSet = [fmdb executeQuery:@"select * from t_student where id<?;",@(14)];
    
    //2.遍历结果集合
    while ([resultSet next]) {
        int idNum = [resultSet intForColumn:@"id"];
        NSString *name = [resultSet objectForColumnName:@"name"];
        int age = [resultSet intForColumn:@"age"];
        NSLog(@"id=%i ,name=%@, age=%i",idNum,name,age);
    }
    
}


#pragma mark
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    flag = NO;
    if (buttonIndex == 1) {
        flag = YES;
    }
}





@end
