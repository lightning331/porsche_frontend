//
//  WeatherVC.m
//  P'0001
//
//  Created by Povel Sanrov on 10/02/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import "WeatherVC.h"
#import "Global.h"
#import <MBProgressHUD.h>
#import "WebConnector.h"

@interface WeatherVC () {
    NSTimer *currentTimer;
}

@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSMutableArray *bottomItems;

@end

@implementation WeatherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Global *global = [Global sharedInstance];
    self.btnImageArray = global.btnImageArray;
    self.bottomItems = global.bottomItems;
    
    self.lblCurrentlyTitle.text = NSLocalizedString(@"outlet_currently", nil);
    self.lblSunnyTitle.text = NSLocalizedString(@"outlet_sunny", nil);
    self.lblWindTitle.text = NSLocalizedString(@"outlet_wind", nil);
    self.lblHumidityTitle.text = NSLocalizedString(@"outlet_humidity", nil);
    self.lblUVIndexTitle.text = NSLocalizedString(@"outlet_uvindex", nil);
    self.lblVisibilityTitle.text = NSLocalizedString(@"outlet_visibility", nil);
    self.lblNextHourPrecipTitle.text = NSLocalizedString(@"outlet_nexthourprecip", nil);
    
    
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        
        UIFont *font = self.lblCurrentlyTitle.font;
        NSString *fontName = font.fontName;
        [self.lblCurrentlyTitle setFont:[UIFont fontWithName:fontName size:31]];
        [self.lblCurrentTime setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblSunnyTitle setFont:[UIFont fontWithName:fontName size:27]];
        
        font = self.lblTemperature.font;
        fontName = font.fontName;
        [self.lblTemperature setFont:[UIFont fontWithName:fontName size:83]];
        
        font = self.lblFeelslike.font;
        fontName = font.fontName;
        [self.lblFeelslike setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblWeather setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblWindTitle setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblWind setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblHumidityTitle setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblHumidity setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblUVIndexTitle setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblUVIndex setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblVisibilityTitle setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblVisibility setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblNextHourPrecipTitle setFont:[UIFont fontWithName:fontName size:23]];
        [self.lblNextHourPrecip setFont:[UIFont fontWithName:fontName size:23]];
    }

    self.viewContent.layer.borderWidth = 1.0f;
    self.viewContent.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self showCurrentTime];
    
    self.lblTemperature.text = @" ";
    self.lblFeelslike.text = [NSString stringWithFormat:@"%@: ", NSLocalizedString(@"outlet_feels_like", nil)];
    self.lblWeather.text = @"";
    self.lblWind.text = @"";
    self.lblHumidity.text = @"";
    self.lblUVIndex.text = @"";
    self.lblVisibility.text = @"";
    self.lblNextHourPrecip.text = @"";
    
    [self showWeatherInformation:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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

- (IBAction)onBtnHome:(id)sender {
    [self.homeVC setSettingButtonHidden:NO];
    [currentTimer invalidate];
    
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:NO];
    }];
}

- (IBAction)onBtnPlus:(id)sender {
    int status = 9;
    
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

#pragma mark - Self Methods

- (void)showCurrentTime {
    [self refreshCurrentTime];
    
    currentTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refreshCurrentTime) userInfo:nil repeats:YES];
}

- (void)refreshCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, hh:mm a zzz"];
    self.lblCurrentTime.text = [formatter stringFromDate:[NSDate date]];
    
    [self showWeatherInformation:NO];
}

- (void)showWeatherInformation:(BOOL)animated {
    if (animated) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector getWeatherInformation:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (animated) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if (result[@"error"] == nil) {
            self.lblTemperature.text = [NSString stringWithFormat:@"%ldF", [result[@"current_observation"][@"temp_f"] integerValue]];
            self.lblFeelslike.text = [NSString stringWithFormat:@"Feels Like: %@F", result[@"current_observation"][@"feelslike_f"]];
            self.lblWeather.text = [NSString stringWithFormat:@"%@", result[@"current_observation"][@"weather"]];
            self.lblWind.text = [NSString stringWithFormat:@"%@ mph", result[@"current_observation"][@"wind_mph"]];
            self.lblHumidity.text = [NSString stringWithFormat:@"%@", result[@"current_observation"][@"relative_humidity"]];
            self.lblUVIndex.text = [NSString stringWithFormat:@"%@", result[@"current_observation"][@"UV"]];
            self.lblVisibility.text = [NSString stringWithFormat:@"%@ mi", result[@"current_observation"][@"visibility_mi"]];
            self.lblNextHourPrecip.text = [NSString stringWithFormat:@"%@ in", result[@"current_observation"][@"precip_1hr_in"]];
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (animated) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
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
