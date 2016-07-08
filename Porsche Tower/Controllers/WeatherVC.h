//
//  WeatherVC.h
//  P'0001
//
//  Created by Povel Sanrov on 10/02/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"

@interface WeatherVC : UIViewController <UIAlertViewDelegate>

@property HomeVC *homeVC;

@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIButton *btnPlus;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentlyTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *lblSunnyTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTemperature;
@property (weak, nonatomic) IBOutlet UILabel *lblFeelslike;
@property (weak, nonatomic) IBOutlet UILabel *lblWeather;
@property (weak, nonatomic) IBOutlet UILabel *lblWindTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblWind;
@property (weak, nonatomic) IBOutlet UILabel *lblHumidityTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblHumidity;
@property (weak, nonatomic) IBOutlet UILabel *lblUVIndexTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblUVIndex;
@property (weak, nonatomic) IBOutlet UILabel *lblVisibilityTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblVisibility;
@property (weak, nonatomic) IBOutlet UILabel *lblNextHourPrecipTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblNextHourPrecip;

@end
