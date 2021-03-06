//
//  DiningVC.m
//  P'0001
//
//  Created by Povel Sanrov on 27/02/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import "DiningVC.h"
#import "Global.h"
#import "MenuVC.h"
#import "DiningMenuVC.h"
#import <MBProgressHUD.h>
#import "WebConnector.h"
#import "CalendarVC.h"
#import "ImageMenuVC.h"

@interface DiningVC ()

@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSArray *backImageArray;
@property (nonatomic) NSMutableArray *bottomItems;

@end

@implementation DiningVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Global *global = [Global sharedInstance];
    self.btnImageArray = global.btnImageArray;
    self.backImageArray = global.backImageArray;
    self.bottomItems = global.bottomItems;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.viewContent.layer.borderColor = [UIColor redColor].CGColor;
    self.viewContent.layer.borderWidth = 2;
    
    self.txtDescription.text = [self.scheduleData objectForKey:@"description"];
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        [self.txtDescription setFont:[UIFont fontWithName:@"Helvetica Neue" size:22]];
        self.btnCall.hidden = YES;
    }
    else {
        [self.txtDescription setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    }
    
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
    [self.homeVC setSettingButtonHidden:NO];
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:YES];
    }];
}

- (IBAction)onBtnCall:(id)sender {
    NSString *strPhone = [[self.scheduleData objectForKey:@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *teleStr = [NSString stringWithFormat:@"telprompt:%@", strPhone];
    NSURL *phoneURL = [NSURL URLWithString:teleStr];
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:NSLocalizedString(@"msg_call_not_available",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)onBtnClose:(id)sender {
    MenuVC *menuVC = (MenuVC *)self.presentationController.presentingViewController;
    [menuVC updateBottomButtons];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (IBAction)onBtnMakeOrder:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [dateFormatter setTimeZone:[calendar timeZone]];
    NSString *datetimeString = [dateFormatter stringFromDate:[NSDate date]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    /*
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector sendRestaurantRequest:@"order" restaurant:[self.scheduleData objectForKey:@"index"] datetime:datetimeString completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if ([result[@"status"] isEqualToString:@"success"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"msg_order_req_confirmed", nil) message:@"Your request was sent. A staff member will call to take your order shortly." delegate:nil cancelButtonTitle:NSLocalizedString(@"title_close", nil) otherButtonTitles:nil];
            [alertView show];
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];*/
    
    NSLog(@"%@", [self.scheduleData objectForKey:@"type"]);
    NSString *type = [self.scheduleData objectForKey:@"type"];
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector sendScheduleRequest:type index:[self.scheduleData objectForKey:@"index"] datetime:datetimeString completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if ([result[@"status"] isEqualToString:@"success"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"msg_request_sent",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [self.homeVC dismissViewControllerAnimated:NO completion:^{
                [self.homeVC setSettingButtonHidden:NO];
                [self.homeVC setHiddenCategories:NO];
            }];
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (IBAction)onBtnViewMenu:(id)sender {
//    MenuVC *menuVC = (MenuVC *)self.presentationController.presentingViewController;
//    [self dismissViewControllerAnimated:NO completion:^{
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        DiningMenuVC *diningMenuVC = [storyboard instantiateViewControllerWithIdentifier:@"DiningMenuVC"];
//        diningMenuVC.view.backgroundColor = [UIColor clearColor];
//        diningMenuVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//        diningMenuVC.homeVC = self.homeVC;
//
//        diningMenuVC.scheduleData = [self.scheduleData mutableCopy];
//
//        menuVC.definesPresentationContext = YES;
//        [menuVC presentViewController:diningMenuVC animated:NO completion:^{
//            return;
//        }];
//    }];
    NSString *pdf_url = [self.scheduleData objectForKey:@"file"];
    [self openImageMenuWithURL:pdf_url];
}

- (void)openImageMenuWithURL:(NSString*)pdf_url {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImageMenuVC *imageVC = [storyboard instantiateViewControllerWithIdentifier:@"ImageMenuVC"];
    imageVC.view.backgroundColor = [UIColor clearColor];
    imageVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    imageVC.homeVC = self.homeVC;
    imageVC.pdf_url = pdf_url;
    
    self.definesPresentationContext = YES;
    [self presentViewController:imageVC animated:NO completion:^{
        return;
    }];
}

- (IBAction)onBtnMakeReservation:(id)sender {
    MenuVC *menuVC = (MenuVC *)self.presentationController.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CalendarVC *calendarVC = [storyboard instantiateViewControllerWithIdentifier:@"CalendarVC"];
        calendarVC.view.backgroundColor = [UIColor clearColor];
        calendarVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        calendarVC.homeVC = self.homeVC;
        
        calendarVC.scheduleData = [self.scheduleData mutableCopy];
        
        menuVC.definesPresentationContext = YES;
        [menuVC presentViewController:calendarVC animated:NO completion:^{
            return;
        }];
    }];
}

- (IBAction)onBtnHome:(id)sender {
    [self.homeVC setSettingButtonHidden:NO];
    MenuVC *menuVC = (MenuVC *)self.presentationController.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [menuVC dismissViewControllerAnimated:NO completion:^{
            [self.homeVC setHiddenCategories:NO];
        }];
    }];
}

- (IBAction)onBtnPlus:(id)sender {
    int status = 0;
    NSString *type = [self.scheduleData objectForKey:@"type"];
    
    if ([type isEqualToString:@"restaurants_in_house"] ||
        [type isEqualToString:@"local_restaurants"]) {
        status = 6;
    }
    else if ([type isEqualToString:@"taxis"] ||
             [type isEqualToString:@"shuttles"] ||
             [type isEqualToString:@"car_rental"]) {
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
        imgView.frame = CGRectMake(self.btnHome.frame.origin.x + ((self.btnPlus.frame.origin.x - self.btnHome.frame.origin.x) / (CATEGORY_COUNT + 1)) * (i+ 1), self.btnHome.frame.origin.y, self.btnHome.frame.size.width, self.btnHome.frame.size.height);
        
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
    [self.homeVC setSettingButtonHidden:NO];
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

@end
