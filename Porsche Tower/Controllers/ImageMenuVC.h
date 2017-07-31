//
//  ImageMenuVC.h
//  P'0001
//
//  Created by Daniel on 31/7/17.
//  Copyright © 2017 Daniel Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"

@interface ImageMenuVC : BaseVC <UIAlertViewDelegate>

@property HomeVC *homeVC;
@property NSMutableDictionary *scheduleData;

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIButton *btnPlus;

- (IBAction)onBtnCategory:(id)sender;
- (IBAction)onBtnClose:(id)sender;
- (IBAction)onBtnHome:(id)sender;
- (IBAction)onBtnPlus:(id)sender;

@end
