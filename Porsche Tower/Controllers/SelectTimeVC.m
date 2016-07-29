//
//  SelectTimeVC.m
//  Porsche Tower
//
//  Created by Povel Sanrov on 14/07/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import "SelectTimeVC.h"
#import "MenuVC.h"
#import "Global.h"
#import "WebConnector.h"
#import <MBProgressHUD.h>
#import "BeachRequestVC.h"

@interface SelectTimeVC ()

@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSArray *backImageArray;
@property (nonatomic) NSMutableArray *bottomItems;

@end

@implementation SelectTimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.timePicker.backgroundColor = [UIColor blackColor];
    [self.timePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
    
    Global *global = [Global sharedInstance];
    self.btnImageArray = global.btnImageArray;
    self.backImageArray = global.backImageArray;
    self.bottomItems = global.bottomItems;
    
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        [self.btnCancel.titleLabel setFont:[UIFont systemFontOfSize:25]];
        [self.btnSave.titleLabel setFont:[UIFont systemFontOfSize:25]];
    }
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:10*60];
    [self.timePicker setDate:date];
    
    [self.btnCancel setTitle:NSLocalizedString(@"outlet_cancel", nil) forState:UIControlStateNormal];
    [self.btnSave setTitle:NSLocalizedString(@"outlet_save", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [dateFormatter setTimeZone:[calendar timeZone]];
    NSString *dateString = [dateFormatter stringFromDate:self.selectedDate];
    self.lblDate.text = dateString;
    
    [self updateBottomButtons];
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

#pragma mark - UI Actions

- (IBAction)onBtnCategory:(id)sender {
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:YES];
    }];
}

- (IBAction)onBtnCancel:(id)sender {
    NSString *type = [self.scheduleData objectForKey:@"type"];
    if ([type isEqualToString:@"pool_beach"])
    {
        HomeVC *homeVC = (HomeVC*)self.presentationController.presentingViewController;
        [homeVC updatePickerViewHidden:NO];
    }
    else
    {
        MenuVC *menuVC = (MenuVC *)self.presentationController.presentingViewController;
        [menuVC updateBottomButtons];
    }
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (IBAction)onBtnSave:(id)sender {
    BOOL ok = [MFMailComposeViewController canSendMail];
    ok = YES;
    if (!ok) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_error", nil) message:NSLocalizedString(@"msg_dev_not_configured", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSDate *date = [self.timePicker date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *timeComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
        NSInteger hour = [timeComponents hour];
        NSInteger minute = [timeComponents minute];
        
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.selectedDate];
        [components setHour:hour];
        [components setMinute:minute];
        self.selectedDate = [calendar dateFromComponents:components];
        
        if ([self.selectedDate timeIntervalSinceNow] < 5*60) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_error", nil) message:NSLocalizedString(@"msg_cant_select_date", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[calendar timeZone]];
        NSString *datetimeString = [dateFormatter stringFromDate:self.selectedDate];
        [self.scheduleData setObject:datetimeString forKey:@"Datetime"];
        
        NSString *type = [self.scheduleData objectForKey:@"type"];
        
        //Schedule Car Elevator
        if ([type isEqualToString:@"showroom_booking"]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *requestElevator = [[userDefaults objectForKey:@"ScheduleElevator"] mutableCopy];
            [requestElevator setObject:datetimeString forKey:@"Datetime"];
            [userDefaults setObject:requestElevator forKey:@"ScheduleElevator"];
            [userDefaults synchronize];
            
            [self.homeVC dismissViewControllerAnimated:NO completion:^{
                [self.homeVC openMenu:@"repeat_schedule"];
            }];
        }
        // Request Pool/Beach
        else if ([type isEqualToString:@"pool_beach"]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            BeachRequestVC *beachRequestVC = [storyboard instantiateViewControllerWithIdentifier:@"BeachRequestVC"];
            beachRequestVC.view.backgroundColor = [UIColor clearColor];
            beachRequestVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            beachRequestVC.homeVC = self.homeVC;
            
            beachRequestVC.scheduleData = [self.scheduleData mutableCopy];
            
            self.definesPresentationContext = YES;
            [self presentViewController:beachRequestVC animated:NO completion:^{
                
            }];
        }
        // Dining Order/Reservation Request
        /*
        else if ([type isEqualToString:@"restaurants_in_house"] ||
                 [type isEqualToString:@"local_restaurants"]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            WebConnector *webConnector = [[WebConnector alloc] init];
            [webConnector sendRestaurantRequest:@"reservation" restaurant:[self.scheduleData objectForKey:@"index"] datetime:datetimeString completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
                if ([result[@"status"] isEqualToString:@"success"]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Your request has been sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    
                    [self.homeVC dismissViewControllerAnimated:NO completion:^{
                        [self.homeVC setHiddenCategories:NO];
                    }];
                }
            } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        }*/
        else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            WebConnector *webConnector = [[WebConnector alloc] init];
            [webConnector sendScheduleRequest:type index:[self.scheduleData objectForKey:@"index"] datetime:datetimeString completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
                if ([result[@"status"] isEqualToString:@"success"]) {
                    if ([type isEqualToString:@"storage"]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"msg_car_scheduled_for_storage",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    }
                    else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"msg_request_sent",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    }
                    
                    [self.homeVC dismissViewControllerAnimated:NO completion:^{
                        [self.homeVC setHiddenCategories:NO];
                    }];
                }
            } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        }
    }
}

- (IBAction)onBtnHome:(id)sender {
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:NO];
    }];
}

- (IBAction)onBtnPlus:(id)sender {
    int status = 0;
    NSString *type = [self.scheduleData objectForKey:@"type"];
    if ([type isEqualToString:@"schedule_car_elevator"]) {
        status = 0;
    }
    else if ([type isEqualToString:@"service_car"] ||
             [type isEqualToString:@"detailing"] ||
             [type isEqualToString:@"storage"]) {
        status = 2;
    }
    else if ([type isEqualToString:@"pool_beach"]) {
        status = 3;
    }
    else if ([type isEqualToString:@"spa"] ||
             [type isEqualToString:@"gym_equipment"] ||
             [type isEqualToString:@"massage"] ||
             [type isEqualToString:@"barber"]) {
        status = 4;
    }
    else if ([type isEqualToString:@"golf_sim"] ||
             [type isEqualToString:@"racing_sim"] ||
             [type isEqualToString:@"theater"] ||
             [type isEqualToString:@"community_room"]) {
        status = 5;
    }
    else if ([type isEqualToString:@"housekeeping"] ||
             [type isEqualToString:@"dry_cleaning"]) {
        status = 10;
    }
    
    for (UIImageView* imgView in self.bottomItems)
        if ([self.btnImageArray objectAtIndex:status] == imgView.image)
            return;
    if (self.bottomItems.count == self.btnImageArray.count)
        [self.bottomItems removeObjectAtIndex:0];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[self.btnImageArray objectAtIndex:status]];
    imgView.tag = status;
    [self.bottomItems addObject:imgView];
    [self updateBottomButtons];
}

#pragma mark - Self Methods

- (void)updateBottomButtons {
    for (int i = 0; i < self.bottomItems.count; i++ ) {
        UIImageView *imgView = [self.bottomItems objectAtIndex:i];
        imgView.frame = CGRectMake(self.btnHome.frame.origin.x + ((self.btnPlus.frame.origin.x - self.btnHome.frame.origin.x) / self.btnImageArray.count) * (i+ 1), self.btnHome.frame.origin.y, self.btnHome.frame.size.width, self.btnHome.frame.size.height);
        
        imgView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTapBottom:)];
        [imgView addGestureRecognizer:singleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressBottom:)];
        [imgView addGestureRecognizer:longPress];
        
        [self.view addSubview:imgView];
    }
}

#pragma mark - TapGesture

- (void)handleTapBottom:(UITapGestureRecognizer *)tap {
    MenuVC *menuVC = (MenuVC *)self.presentationController.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [menuVC dismissViewControllerAnimated:NO completion:^{
            NSInteger index = tap.view.tag;
            [self.homeVC showSubcategories:index];
        }];
    }];
}

- (void)handleLongPressBottom:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state == UIGestureRecognizerStateEnded && self.bottomItems.count > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_remove_shortcut", nil) message:NSLocalizedString(@"msg_sure_to_remove_shortcut", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        alertView.tag = longPress.view.tag;
        
        [alertView show];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSInteger index = alertView.tag;
        
        for (UIImageView *imgView in self.bottomItems) {
            if (imgView.tag == index) {
                [self.bottomItems removeObject:imgView];
                [imgView removeFromSuperview];
                [self updateBottomButtons];
                return;
            }
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled");
            //NSLog(NSLocalizedString(@"msg_mail_cancelled",nil));
            [self messageAlert:NSLocalizedString(@"msg_mail_cancelled",nil) stats:@"Cancelled"];
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved");
            //NSLog(NSLocalizedString(@"msg_mail_saved",nil));
            [self messageAlert:NSLocalizedString(@"msg_mail_saved",nil) stats:@"Saved"];
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail sent");
            NSLog(NSLocalizedString(@"msg_mail_send",nil));
            [self messageAlert:NSLocalizedString(@"msg_mail_send",nil) stats:@"Sent"];
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            //NSLog(@"Due to some error your email sending failed.");
            [self messageAlert:NSLocalizedString(@"msg_mail_failed",nil) stats:@"Failed"];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

-(void) messageAlert:(NSString*)str stats:(NSString*)status {
    if ([status isEqualToString:@"Failed"]) {
        UIAlertView *connectionAlert = [[UIAlertView alloc] init];
        [connectionAlert setTitle:NSLocalizedString(@"title_error", nil)];
        [connectionAlert setMessage:str];
        [connectionAlert setDelegate:self];
        [connectionAlert setTag:1];
        [connectionAlert addButtonWithTitle:@"OK"];
        [connectionAlert show];
    }
    else {
        UIAlertView *connectionAlert = [[UIAlertView alloc] init];
        [connectionAlert setTitle:@""];
        [connectionAlert setMessage:str];
        [connectionAlert setDelegate:self];
        [connectionAlert setTag:1];
        [connectionAlert addButtonWithTitle:@"OK"];
        [connectionAlert show];
        
        if (![status isEqualToString:@"Cancelled"]) {
            [self dismissViewControllerAnimated:NO completion:^{
                
            }];
        }
    }
}

@end
