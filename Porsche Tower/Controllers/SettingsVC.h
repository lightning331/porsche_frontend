//
//  SettingsVC.h
//  P'0001
//
//  Created by Bendt Jensen on 01/08/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import "BaseVC.h"
#import "HomeVC.h"

@interface SettingsVC : BaseVC<UIAlertViewDelegate>

@property HomeVC *homeVC;

@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIButton *btnPlus;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
@property (weak, nonatomic) IBOutlet UIButton *btnResetPass;
@property (weak, nonatomic) IBOutlet UIButton *btnTouchID;
@property (weak, nonatomic) IBOutlet UIButton *btnEnglish;
@property (weak, nonatomic) IBOutlet UIButton *btnGerman;
@property (weak, nonatomic) IBOutlet UIButton *btnItalian;
@property (weak, nonatomic) IBOutlet UIButton *btnSpanish;
@property (weak, nonatomic) IBOutlet UILabel *lblLanguage;
@property (weak, nonatomic) IBOutlet UILabel *lblLogoutTime;
@property (weak, nonatomic) IBOutlet UIButton *btn1Min;
@property (weak, nonatomic) IBOutlet UIButton *btn2Min;
@property (weak, nonatomic) IBOutlet UIButton *btn3Min;
@property (weak, nonatomic) IBOutlet UIButton *btn4Min;
@property (weak, nonatomic) IBOutlet UIButton *btnTouchIDName;

- (IBAction)onBtnHome:(id)sender;
- (IBAction)onBtnPlus:(id)sender;
- (IBAction)onLogout:(id)sender;
- (IBAction)onResetPass:(id)sender;
- (IBAction)onTouchID:(id)sender;
- (IBAction)onEnglish:(id)sender;
- (IBAction)onGerman:(id)sender;
- (IBAction)onItalian:(id)sender;
- (IBAction)onSpanish:(id)sender;
- (IBAction)on1Min:(id)sender;
- (IBAction)on2Min:(id)sender;
- (IBAction)on3Min:(id)sender;
- (IBAction)on4Min:(id)sender;

@end
