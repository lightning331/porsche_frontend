//
//  ElevatorControlVC.m
//  P'0001
//
//  Created by Povel Sanrov on 22/01/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import "ElevatorControlVC.h"
#import "MenuVC.h"
#import "Global.h"
#import "WebConnector.h"
#import <MBProgressHUD.h>

@interface ElevatorControlVC () {
    NSTimer *timer;
    NSInteger totalMinute;
    NSInteger totalSecond;
    NSInteger currentMinute;
    NSInteger currentSeconds;
    
    NSMutableDictionary *selectedCar;
    NSString *valet;
    NSMutableDictionary *owner;
    
    NSString *pickup;
    NSString *sendTime;
    
    NSTimer *currentTimer;
}

@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSMutableArray *bottomItems;

@end

@implementation ElevatorControlVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Global *global = [Global sharedInstance];
    self.btnImageArray = global.btnImageArray;
    self.bottomItems = global.bottomItems;
    
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *requestElevator = [userDefaults objectForKey:@"RequestElevator"];
    selectedCar = [[requestElevator objectForKey:@"SelectedCar"] mutableCopy];
    valet = [[requestElevator objectForKey:@"Valet"] mutableCopy];
    if ([valet isEqualToString:@"Valet"]) {
        self.imgDescription.hidden = YES;
    }
    owner = [[requestElevator objectForKey:@"Owner"] mutableCopy];
    
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        [self.lblArrivalTime setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:27]];
        [self.lblCountdown setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:40]];
        [self.lblCountdownLabel setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:11]];
        [self.lblCarsInQue setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:27]];
        [self.lblCurrentTime setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:19]];
    }
    
    [self showCurrentTime];
    [self resetArrivalTime:0 second:0];
    [self resetCountdown:0 second:0];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([selectedCar[@"status"] isEqualToString:@"active"]) {
        [self activeStatus];
        
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector getPickup:selectedCar[@"index"] completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
            if ([result[@"status"] isEqualToString:@"success"]) {
                
                pickup = [result[@"index"] mutableCopy];
                self.delayTime = [result[@"delay"] integerValue];
                sendTime = [result[@"send_time"] mutableCopy];
                
                NSInteger queueSize = [result[@"queue_size"] integerValue];
                self.lblCarsInQue.text = [NSString stringWithFormat:@"%ld", (long)queueSize];
                
                NSInteger countdown = [result[@"countdown"] integerValue];
                
                [self resetArrivalTime:countdown / 60 second:countdown % 60];
                
                [self resetCountdown:countdown / 60 second:countdown % 60];
                [self startCountdown:countdown / 60 second:countdown % 60];
            }
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
    else {
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector getQueueSize:owner[@"unit"][@"elevator1"] completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
            if ([result[@"status"] isEqualToString:@"success"]) {
                NSInteger queueSize = [result[@"queue_size"] integerValue];
                NSInteger queueTime = [result[@"queue_time"] integerValue];
                
                self.lblCarsInQue.text = [NSString stringWithFormat:@"%ld", (long)queueSize];
                
                NSInteger totalDelay = [self calculateTotalDelayBySecond:queueTime];
                totalMinute = totalDelay / 60;
                totalSecond = totalDelay % 60;
                
                [self resetArrivalTime:totalMinute second:totalSecond];
                
                [self resetCountdown:totalMinute second:totalSecond];
            }
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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

- (IBAction)onBtnStart:(id)sender {
    
    if (self.state == NO) {
        [self activeStatus];
        
        [self sendRequest];
    }
    else {
        //car concierge phone number
        NSString *strPhone = @"(786) 805-6961";
        
        NSString *alertMessage = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"msg_call_car_concierge", nil), strPhone];
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"title_elevator_activated", nil) message: alertMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // Call car concierge
            NSString *strPhone = @"786-805-6961";
            NSString *teleStr = [NSString stringWithFormat:@"telprompt:%@", strPhone];
            NSURL *phoneURL = [NSURL URLWithString:teleStr];
            if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
                [[UIApplication sharedApplication] openURL:phoneURL];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:NSLocalizedString(@"msg_call_not_available",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_elevator_activated", nil) message:NSLocalizedString(@"msg_sure_to_cancel_elevator", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            alertView.tag = 1001;
            [alertView show];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)onBtnHome:(id)sender {
    [timer invalidate];
    [currentTimer invalidate];
    [self.homeVC setSettingButtonHidden:NO];
    
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:NO];
    }];
}

- (IBAction)onBtnPlus:(id)sender {
    int status = 0;
        
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

- (void)showCurrentTime {
    [self refreshCurrentTime];
    
    currentTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshCurrentTime) userInfo:nil repeats:YES];
}

- (void)refreshCurrentTime {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dataComponents = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    NSInteger hour = [dataComponents hour];
    NSInteger minute = [dataComponents minute];
    
    NSString *ampm = hour >= 12 ? @"PM" : @"AM";
    hour = hour %12;
    hour = hour ? hour : 12;
    self.lblCurrentTime.text = [NSString stringWithFormat:@"%ld:%@%@", (long)hour, (minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)minute] : [NSString stringWithFormat:@"%ld", (long)minute]), ampm];
}

- (NSInteger)calculateTotalDelayBySecond:(NSInteger)queueTime {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"HH:mm:ss"];
    
    NSDate *flightTime = [dateFormater dateFromString:owner[@"unit"][@"flight_time"]];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dataComponents = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:flightTime];
    NSInteger minuteFlightTime = [dataComponents minute];
    NSInteger secondFlightTime = [dataComponents second];
    
    NSInteger second = secondFlightTime + queueTime +  + self.delayTime;
    NSInteger minute = minuteFlightTime;
    
    return minute * 60 + second;
}

- (void)resetArrivalTime:(NSInteger)minute second:(NSInteger)second {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dataComponents = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    NSInteger arrivalHour = [dataComponents hour];
    NSInteger arrivalMinute = [dataComponents minute];
    NSInteger arrivalSecond = [dataComponents second];
    
    arrivalSecond = arrivalSecond + second;
    arrivalMinute = arrivalMinute + minute + arrivalSecond / 60;
    if (arrivalMinute >= 60) {
        arrivalHour = arrivalHour + arrivalMinute / 60;
        arrivalMinute = arrivalMinute % 60;
    }
    arrivalHour = (arrivalHour == 12) ? 12 : arrivalHour % 12;
    self.lblArrivalTime.text = [NSString stringWithFormat:@"%ld:%@", (long)arrivalHour, (arrivalMinute < 10 ? [NSString stringWithFormat:@"0%ld", (long)arrivalMinute] : [NSString stringWithFormat:@"%ld", (long)arrivalMinute])];
}

- (void)resetCountdown:(NSInteger)minute second:(NSInteger)second {
    self.lblCountdown.text = [NSString stringWithFormat:@"%ld:%@", (long)minute, (second < 10 ? [NSString stringWithFormat:@"0%ld", (long)second] : [NSString stringWithFormat:@"%ld", (long)second])];
}

- (void)activeStatus {
    self.state = YES;
    self.imgStartBtn.image = [UIImage imageNamed:@"elevator_control_start_btn_active2"];
}

- (void)deactiveStatus {
    self.state = NO;
    self.imgStartBtn.image = [UIImage imageNamed:@"elevator_control_start_btn_normal2"];
    
    [timer invalidate];
    [currentTimer invalidate];
    
    [self.homeVC setSettingButtonHidden:NO];
    [self.homeVC.lblSettings setHidden:YES];
    [self.homeVC.lblSubTitle setHidden:NO];
    
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:NO];
    }];
}

- (void)sendRequest {
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector requestCarElevator:selectedCar[@"index"] valet:valet elevator:owner[@"unit"][@"elevator1"] delay:[NSString stringWithFormat:@"%ld", (long)self.delayTime] completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if ([result[@"status"] isEqualToString:@"success"]) {
            pickup = result[@"pickup"];
            
            [self resetArrivalTime:totalMinute second:totalSecond];
            
            [self resetCountdown:totalMinute second:totalSecond];
            [self startCountdown:totalMinute second:totalSecond];
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)cancelRequest {
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector cancelCarElevator:pickup completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if ([result[@"status"] isEqualToString:@"success"]) {
            
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)successElevator {
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector successCarElevator:pickup completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if ([result[@"status"] isEqualToString:@"success"]) {
            
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)updateCountdown {
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector getTimeIncrease:pickup completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if ([result[@"status"] isEqualToString:@"success"]) {
            NSInteger timeIncrease = [result[@"time_increase"] integerValue];
            if (timeIncrease > 0 && ![result[@"send_time"] isEqualToString:sendTime] && self.state == YES) {
                sendTime = [result[@"send_time"] mutableCopy];
                NSInteger countdown = currentMinute * 60 + currentSeconds + timeIncrease;
                currentMinute = countdown / 60;
                currentSeconds = countdown % 60;
                
                [self resetArrivalTime:totalMinute + (totalSecond + timeIncrease) / 60 second:(totalSecond + timeIncrease) % 60];
            }
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)startCountdown:(NSInteger)minute second:(NSInteger)second {
    currentMinute = minute;
    currentSeconds = second;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

- (void)timerFired {
    if ((currentMinute > 0 || currentSeconds >= 0) && currentMinute >= 0) {
        if (currentSeconds == 0) {
            currentMinute -= 1;
            currentSeconds = 59;
        }
        else if (currentSeconds > 0) {
            currentSeconds -= 1;
        }
        if (currentMinute > -1) {
            self.lblCountdown.text = [NSString stringWithFormat:@"%ld:%@", (long)currentMinute, (currentSeconds < 10 ? [NSString stringWithFormat:@"0%ld", (long)currentSeconds] : [NSString stringWithFormat:@"%ld", (long)currentSeconds])];
            
            [self updateCountdown];
        }
    }
    else {
        NSString *msg_alert = NSLocalizedString(@"msg_car_ridedown_success", nil);
        if ([valet isEqualToString:@"Valet"]) {
            msg_alert = NSLocalizedString(@"msg_car_delivered_ready_to_pickup", nil);
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_car_ready_pickup", nil) message:msg_alert delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        [self successElevator];
        
        [self deactiveStatus];
    }
}

#pragma mark - TapGesture

- (void)handleTapBottom:(UITapGestureRecognizer *)tap {
    [self.homeVC setSettingButtonHidden:NO];
    NSInteger index = tap.view.tag;
    
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC showSubcategories:index];
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
    if (alertView.tag == 1001) {
        if (buttonIndex == 1) {
            [self cancelRequest];
            
            [self deactiveStatus];
        }
    }
    else {
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
}

@end
