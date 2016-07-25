//
//  DescriptionVC.h
//  Porsche Tower
//
//  Created by Povel Sanrov on 09/07/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"

@interface DescriptionVC : BaseVC <UIAlertViewDelegate>

@property HomeVC *homeVC;
@property NSMutableDictionary *scheduleData;

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIButton *btnPlus;

- (IBAction)onBtnCategory:(id)sender;
- (IBAction)onBtnSelect:(id)sender;
- (IBAction)onBtnClose:(id)sender;
- (IBAction)onBtnHome:(id)sender;
- (IBAction)onBtnPlus:(id)sender;

@end
