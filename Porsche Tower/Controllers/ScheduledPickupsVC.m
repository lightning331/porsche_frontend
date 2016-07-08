//
//  ScheduledPickupsVC.m
//  P'0001
//
//  Created by Povel Sanrov on 6/23/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import "ScheduledPickupsVC.h"
#import "Global.h"
#import "WebConnector.h"
#import <MBProgressHUD.h>

@interface ScheduledPickupsVC () {
    NSArray *scheduledPickups;
    NSInteger cancelPickupIndex;
}

@end

@implementation ScheduledPickupsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector getDataList:@"scheduled_pickups" completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if ([result[@"status"] isEqualToString:@"success"]) {
            scheduledPickups = [result[@"scheduled_pickups"] mutableCopy];
            [self.tableView reloadData];
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        self.lblCar.font = [UIFont systemFontOfSize:20];
        self.lblDate.font = [UIFont systemFontOfSize:20];
        self.lblTime.font = [UIFont systemFontOfSize:20];
        self.lblCancel.font = [UIFont systemFontOfSize:20];
    }
    else {
        self.lblCar.font = [UIFont systemFontOfSize:10];
        self.lblDate.font = [UIFont systemFontOfSize:10];
        self.lblTime.font = [UIFont systemFontOfSize:10];
        self.lblCancel.font = [UIFont systemFontOfSize:10];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBtnCategory:(id)sender {
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:YES];
    }];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return scheduledPickups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor blackColor];
    }
    else {
        cell.backgroundColor = [UIColor colorWithWhite:0.17 alpha:1.0];
    }
    
    UIView *selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    CGFloat height;
    UIFont *font = [UIFont systemFontOfSize:17];
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        height = 62;
        font = [UIFont systemFontOfSize:27];
    }
    else {
        height = 35;
    }
    
    UILabel *lblCar = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.lblCar.frame.size.width, height)];
    lblCar.textColor = [UIColor whiteColor];
    lblCar.text = [scheduledPickups objectAtIndex:indexPath.row][@"car"][@"name"];
    lblCar.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    lblCar.font = font;
    [cell addSubview:lblCar];
    
    NSString *requestTime = [scheduledPickups objectAtIndex:indexPath.row][@"request_time"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [dateFormatter setTimeZone:[calendar timeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:requestTime];
    [dateFormatter setDateFormat:@"M-d-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"h:ma"];
    NSString *timeString = [dateFormatter stringFromDate:date];
    
    UILabel *lblDate = [[UILabel alloc] initWithFrame:CGRectMake(self.lblDate.frame.origin.x, 0, self.lblDate.frame.size.width, height)];
    lblDate.textColor = [UIColor whiteColor];
    lblDate.text = dateString;
    lblDate.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    lblDate.font = font;
    [cell addSubview:lblDate];
    
    UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(self.lblTime.frame.origin.x, 0, self.lblTime.frame.size.width, height)];
    lblTime.textColor = [UIColor whiteColor];
    lblTime.text = timeString;
    lblTime.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    lblTime.font = font;
    [cell addSubview:lblTime];
    
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(self.lblCancel.frame.origin.x, 0, self.lblCancel.frame.size.width, height)];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel setTitle:@"X" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = font;
    btnCancel.tag = indexPath.row;
    [btnCancel addTarget:self action:@selector(cancelPickup:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnCancel];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        height = 62;
    }
    else {
        height = 35;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)cancelPickup:(UIButton*)sender {
    cancelPickupIndex = sender.tag;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cancel Pick-Up" message:@"Are you sure you want to cancel this event?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

#pragma mark UIAlertView delegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector cancelScheduledCarElevator:[scheduledPickups objectAtIndex:cancelPickupIndex][@"index"] completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
            if ([result[@"status"] isEqualToString:@"success"]) {
                scheduledPickups = [result[@"scheduled_pickups"] mutableCopy];
                [self.tableView reloadData];
            }
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}

@end
