//
//  DiningVC.h
//  P'0001
//
//  Created by Povel Sanrov on 27/02/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"
#import "BaseVC.h"

@interface DiningVC : BaseVC

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
- (IBAction)onBtnMakeOrder:(id)sender;
- (IBAction)onBtnViewMenu:(id)sender;
- (IBAction)onBtnMakeReservation:(id)sender;
- (IBAction)onBtnHome:(id)sender;
- (IBAction)onBtnPlus:(id)sender;

@end
