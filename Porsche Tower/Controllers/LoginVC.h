//
//  LoginVC.h
//  Porsche Tower
//
//  Created by Daniel on 5/9/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface LoginVC : BaseVC

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UILabel *lblLogin;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckbox;

- (IBAction)onLogin:(id)sender;
- (IBAction)onUseTouchID:(id)sender;

@end
