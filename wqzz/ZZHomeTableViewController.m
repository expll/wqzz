//
//  ZZHomeTableViewController.m
//  wqzz
//
//  Created by Tiny on 15/9/6.
//  Copyright (c) 2015年 com.sadf. All rights reserved.
//

#import "ZZHomeTableViewController.h"
#import "ZZHomeTableViewCell.h"
#import "ZZDataSource.h"
#import "Toast+UIView.h"
#define Landscape [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height

@interface ZZHomeTableViewController ()
{
    NSArray *books;
    NSMutableArray *bookViews;
}

@end

@implementation ZZHomeTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backImageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    [backImageView setImage:[UIImage imageNamed:@"bizhi2"]];
    self.tableView.backgroundView = backImageView;
    
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

    
    bookViews = [NSMutableArray arrayWithCapacity:0];
    NSInteger countNum;
    if (Landscape) {
        countNum = 4;
    } else {
        countNum = 3;
    }
    
    NSInteger count = [ZZDataSource book_getCount];
    NSInteger rowNum;
    if (count %countNum == 0) {
        rowNum = count/countNum;
    } else {
        rowNum = count/countNum + 1;
    }
    
    
    for (int i = 0; i < rowNum; i++) {
        NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < countNum; i++) {
            
            ZZBookView *bookview = [[[NSBundle mainBundle] loadNibNamed:@"ZZBookView" owner:nil options:nil] firstObject];
            [tmpArr addObject:bookview];
            
        }
        [bookViews addObject:tmpArr];
    }
    



    //books = [ZZDataSource getBooks];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    
    @try {
        ///////////////////////////////////////////////////////////////
        NSMutableArray *copy = [NSMutableArray arrayWithCapacity:0];
        for (id arr in bookViews) {
            for (id arr2 in arr) {
                [copy addObject:arr2];
            }
        }
        
        
        
        NSInteger countNum;
        if (Landscape) {
            countNum = 4;
            NSLog(@"@@@@@@@@@@@@@@@@@@@");
        } else {
            countNum = 3;
            NSLog(@"####################");
        }
        
        NSInteger count = [ZZDataSource book_getCount];
        NSInteger rowNum;
        if (count %countNum == 0) {
            rowNum = count/countNum;
        } else {
            rowNum = count/countNum + 1;
        }
        
        for (int i = 0; i < rowNum; i++) {
            for (int j = 0; j < countNum; j++) {
                NSLog(@"%d, %d, %d, %d", i, j, countNum, rowNum);
                if ((i*countNum + j) < copy.count){
                    bookViews[i][j] = copy[(i*countNum + j)];
                }
                
                
            }
        }

    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    NSInteger countNum;
    if (Landscape) {
        countNum = 4;
    } else {
        countNum = 3;
    }
    
    NSInteger count = [ZZDataSource book_getCount];
    if (count %countNum == 0) {
        return count/countNum;
    } else {
        return count/countNum + 1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZZHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zzcell" forIndexPath:indexPath];
    cell.cellData = bookViews[indexPath.row];
    
    cell.row = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];

    

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}



@end
