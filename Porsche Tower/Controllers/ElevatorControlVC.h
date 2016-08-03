//
//  ElevatorControlVC.h
//  P'0001
//
//  Created by Povel Sanrov on 22/01/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"

@interface ElevatorControlVC : BaseVC <UIAlertViewDelegate>

@property HomeVC *homeVC;
@property NSInteger delayTime;
@property BOOL state;

@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *lblArrivalTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgStartBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblCountdown;
@property (weak, nonatomic) IBOutlet UILabel *lblCountdownLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblCarsInQue;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIButton *btnPlus;
@property (weak, nonatomic) IBOutlet UIImageView *imgDescription;

-(void)setHomeVCSettingHide:(BOOL)ishidden;
@end
