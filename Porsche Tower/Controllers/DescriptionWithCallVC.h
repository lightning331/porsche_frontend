//
//  DescriptionWithCallVC.h
//  Porsche Tower
//
//  Created by Povel Sanrov on 14/08/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"

@interface DescriptionWithCallVC : BaseVC <UIAlertViewDelegate>

@property HomeVC *homeVC;
@property NSMutableDictionary *scheduleData;

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIButton *btnPlus;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;

- (IBAction)onBtnCategory:(id)sender;
- (IBAction)onBtnCall:(id)sender;
- (IBAction)onBtnClose:(id)sender;
- (IBAction)onBtnHome:(id)sender;
- (IBAction)onBtnPlus:(id)sender;

@end
