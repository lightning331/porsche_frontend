//
//  BeachRequestVC.h
//  P'0001
//
//  Created by Povel Sanrov on 11/02/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"

@interface BeachRequestVC : UIViewController <UIAlertViewDelegate>

@property HomeVC *homeVC;
@property NSMutableDictionary *scheduleData;

@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIButton *btnPlus;
@property (weak, nonatomic) IBOutlet UILabel *lblTowels;
@property (weak, nonatomic) IBOutlet UILabel *lblChairs;
@property (weak, nonatomic) IBOutlet UILabel *lblUmbrella;

- (IBAction)onBtnMinusTowels:(id)sender;
- (IBAction)onBtnPlusTowels:(id)sender;
- (IBAction)onBtnMinusChairs:(id)sender;
- (IBAction)onBtnPlusChairs:(id)sender;
- (IBAction)onBtnMinusUmbrella:(id)sender;
- (IBAction)onBtnPlusUmbrella:(id)sender;
- (IBAction)onBtnSendRequest:(id)sender;

@end
