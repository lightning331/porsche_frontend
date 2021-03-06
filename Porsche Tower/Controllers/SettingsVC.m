//
//  SettingsVC.m
//  P'0001
//
//  Created by Bendt Jensen on 01/08/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import "SettingsVC.h"
#import "Setting.h"
#import "AppDelegate.h"
#import "Global.h"
#import "LoginVC.h"
#import "WebConnector.h"
#import <MBProgressHUD.h>

@interface SettingsVC ()
{
    NSString *language;
    NSInteger logout_time;
    BOOL useTouchID;

}

@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSMutableArray *bottomItems;

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Global *global = [Global sharedInstance];
    self.btnImageArray = global.btnImageArray;
    self.bottomItems = global.bottomItems;
    
    [self updateLanguageButtons];
    [self updateLogoutTimeButtons];
    
    [self updateUIComponentTexts];
    [self updateTouchIDCheckBox];
    
    
    
//    [self.btnSelect setTitle:NSLocalizedString(@"outlet_select", nil) forState:UIControlStateNormal];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.homeVC.lblSubTitle setText:NSLocalizedString(@"outlet_settings", nil)];
    [self updateBottomButtons];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateUIComponentTexts{
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        [self.btn1Min.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
        [self.btn2Min.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
        [self.btn3Min.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
        [self.btn4Min.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
        [self.btnGerman.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
        [self.btnLogout.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
        [self.btnResetPass.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
        [self.btnEnglish.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
        [self.btnItalian.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
        [self.btnSpanish.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
        [self.btnTouchIDName.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
        [self.lblLanguage setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
        [self.lblLogoutTime setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
    }
    
    
    [self.btnLogout setTitle:NSLocalizedString(@"outlet_logout", nil) forState:UIControlStateNormal];
    [self.btnResetPass setTitle:NSLocalizedString(@"outlet_reset_pass", nil) forState:UIControlStateNormal];
    [self.btnTouchIDName setTitle:NSLocalizedString(@"outlet_touch_id", nil) forState:UIControlStateNormal];
    [self.btnEnglish setTitle:NSLocalizedString(@"outlet_english", nil) forState:UIControlStateNormal];
    [self.btnGerman setTitle:NSLocalizedString(@"outlet_german", nil) forState:UIControlStateNormal];
    [self.btnItalian setTitle:NSLocalizedString(@"outlet_italian", nil) forState:UIControlStateNormal];
    [self.btnSpanish setTitle:NSLocalizedString(@"outlet_spanish", nil) forState:UIControlStateNormal];
    [self.btn1Min setTitle:[NSString stringWithFormat:@"1 %@", NSLocalizedString(@"outlet_minute", nil)] forState:UIControlStateNormal];
    [self.btn2Min setTitle:[NSString stringWithFormat:@"2 %@", NSLocalizedString(@"outlet_minute", nil)] forState:UIControlStateNormal];
    [self.btn3Min setTitle:[NSString stringWithFormat:@"3 %@", NSLocalizedString(@"outlet_minute", nil)] forState:UIControlStateNormal];
    [self.btn4Min setTitle:[NSString stringWithFormat:@"4 %@", NSLocalizedString(@"outlet_minute", nil)] forState:UIControlStateNormal];
    
    [self.lblLanguage setText:NSLocalizedString(@"outlet_language_setting", nil)];
    [self.lblLogoutTime setText:NSLocalizedString(@"outlet_logout_time", nil)];
}

- (void)updateLanguageButtons {
    language = [Setting sharedInstance].language;
    if ([language isEqualToString:@"en"])
    {
        [self.btnEnglish setBackgroundImage:[UIImage imageNamed:@"btn_language_first_selected"] forState:UIControlStateNormal];
        [self.btnGerman setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btnItalian setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btnSpanish setBackgroundImage:[UIImage imageNamed:@"btn_language_last_normal"] forState:UIControlStateNormal];
    }
    else if ([language isEqualToString:@"de"])
    {
        [self.btnEnglish setBackgroundImage:[UIImage imageNamed:@"btn_language_first_normal"] forState:UIControlStateNormal];
        [self.btnGerman setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_selected"] forState:UIControlStateNormal];
        [self.btnItalian setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btnSpanish setBackgroundImage:[UIImage imageNamed:@"btn_language_last_normal"] forState:UIControlStateNormal];
    }
    else if ([language isEqualToString:@"it"])
    {
        [self.btnEnglish setBackgroundImage:[UIImage imageNamed:@"btn_language_first_normal"] forState:UIControlStateNormal];
        [self.btnGerman setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btnItalian setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_selected"] forState:UIControlStateNormal];
        [self.btnSpanish setBackgroundImage:[UIImage imageNamed:@"btn_language_last_normal"] forState:UIControlStateNormal];
    }
    else if ([language isEqualToString:@"es"])
    {
        [self.btnEnglish setBackgroundImage:[UIImage imageNamed:@"btn_language_first_normal"] forState:UIControlStateNormal];
        [self.btnGerman setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btnItalian setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btnSpanish setBackgroundImage:[UIImage imageNamed:@"btn_language_last_selected"] forState:UIControlStateNormal];
    }
    
    //SubTitle of HomeVC has to be changed
    [self.homeVC.lblSubTitle setText:NSLocalizedString(@"outlet_settings", nil)];
}

- (void)updateLogoutTimeButtons{
    logout_time = [Setting sharedInstance].logout_time;
    if (logout_time == 1)
    {
        [self.btn1Min setBackgroundImage:[UIImage imageNamed:@"btn_language_first_selected"] forState:UIControlStateNormal];
        [self.btn2Min setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btn3Min setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btn4Min setBackgroundImage:[UIImage imageNamed:@"btn_language_last_normal"] forState:UIControlStateNormal];
    }
    else if (logout_time == 2)
    {
        [self.btn1Min setBackgroundImage:[UIImage imageNamed:@"btn_language_first_normal"] forState:UIControlStateNormal];
        [self.btn2Min setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_selected"] forState:UIControlStateNormal];
        [self.btn3Min setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btn4Min setBackgroundImage:[UIImage imageNamed:@"btn_language_last_normal"] forState:UIControlStateNormal];
    }
    else if (logout_time == 3)
    {
        [self.btn1Min setBackgroundImage:[UIImage imageNamed:@"btn_language_first_normal"] forState:UIControlStateNormal];
        [self.btn2Min setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btn3Min setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_selected"] forState:UIControlStateNormal];
        [self.btn4Min setBackgroundImage:[UIImage imageNamed:@"btn_language_last_normal"] forState:UIControlStateNormal];
    }
    else if (logout_time == 4)
    {
        [self.btn1Min setBackgroundImage:[UIImage imageNamed:@"btn_language_first_normal"] forState:UIControlStateNormal];
        [self.btn2Min setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btn3Min setBackgroundImage:[UIImage imageNamed:@"btn_language_middle_normal"] forState:UIControlStateNormal];
        [self.btn4Min setBackgroundImage:[UIImage imageNamed:@"btn_language_last_selected"] forState:UIControlStateNormal];
    }
}

- (void)updateTouchIDCheckBox {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    useTouchID = [[prefs objectForKey:@"UseTouchID"] boolValue];
    if (useTouchID)
        [self.btnTouchID setBackgroundImage:[UIImage imageNamed:@"btn_touchid_on"] forState:UIControlStateNormal];
    else
        [self.btnTouchID setBackgroundImage:[UIImage imageNamed:@"btn_touchid_off"] forState:UIControlStateNormal];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBtnHome:(id)sender {
    [self.homeVC setSettingButtonHidden:NO];
    [self.homeVC.lblSubTitle setHidden:NO];
    [self.homeVC.lblSettings setHidden:YES];
    
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:NO];
    }];
}

- (IBAction)onBtnPlus:(id)sender {
}

- (IBAction)onLogout:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"UseTouchID"];
    [prefs removeObjectForKey:@"CurrentUser"];
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    LoginVC *lvc = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
//    [self.navigationController pushViewController:lvc animated:YES];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate logout];
}

- (IBAction)onResetPass:(id)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"outlet_reset_pass", nil)
                                                                              message: @""
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"outlet_new_password", nil);
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.secureTextEntry = YES;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"outlet_confirm_password", nil);
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.secureTextEntry = YES;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField *tf_new_password = textfields[0];
        UITextField *tf_confirm_password = textfields[1];
        NSString *newpass = tf_new_password.text;
        NSString *cfmpass = tf_confirm_password.text;
        
        if ([newpass isEqualToString:cfmpass]) {  //password match
            // call reset api
            WebConnector *webConnector = [[WebConnector alloc] init];
            [webConnector resetPassword:newpass completionHandler: ^(AFHTTPRequestOperation *operation, id responseObject) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
                if ([result[@"status"] isEqualToString:@"success"]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"msg_password_success",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"msg_password_failure",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
            } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                // Error message
            }];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"msg_password_mismatch",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)onTouchID:(id)sender {
    useTouchID = !useTouchID;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:useTouchID] forKey:@"UseTouchID"];
    [self updateTouchIDCheckBox];

}

- (IBAction)onEnglish:(id)sender {
    [[Setting sharedInstance] setCurrentLanguage:@"en"];
    [self updateLanguageButtons];
    [self updateUIComponentTexts];
}

- (IBAction)onGerman:(id)sender {
     [[Setting sharedInstance] setCurrentLanguage:@"de"];
    [self updateLanguageButtons];
    [self updateUIComponentTexts];
}

- (IBAction)onItalian:(id)sender {
     [[Setting sharedInstance] setCurrentLanguage:@"it"];
    [self updateLanguageButtons];
    [self updateUIComponentTexts];
}

- (IBAction)onSpanish:(id)sender {
     [[Setting sharedInstance] setCurrentLanguage:@"es"];
    [self updateLanguageButtons];
    [self updateUIComponentTexts];
}

- (IBAction)on1Min:(id)sender {
    [[Setting sharedInstance] setLogoutTime:1];
    [self updateLogoutTimeButtons];
}

- (IBAction)on2Min:(id)sender {
    [[Setting sharedInstance] setLogoutTime:2];
    [self updateLogoutTimeButtons];
}

- (IBAction)on3Min:(id)sender {
    [[Setting sharedInstance] setLogoutTime:3];
    [self updateLogoutTimeButtons];
}

- (IBAction)on4Min:(id)sender {
    [[Setting sharedInstance] setLogoutTime:4];
    [self updateLogoutTimeButtons];
}

- (void)updateBottomButtons {
    self.btnPlus.hidden = YES;
    for (int i = 0; i < self.bottomItems.count; i++ ) {
        UIImageView *imgView = [self.bottomItems objectAtIndex:i];
        NSLog(@"bottoms items :%@", self.bottomItems);
        
        imgView.frame = CGRectMake(self.btnHome.frame.origin.x + ((self.btnPlus.frame.origin.x - self.btnHome.frame.origin.x) / (CATEGORY_COUNT + 1)) * (i+ 1), self.btnHome.frame.origin.y, self.btnHome.frame.size.width, self.btnHome.frame.size.height);
        
        imgView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleTapBottom:)];
        [imgView addGestureRecognizer:singleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressBottom:)];
        [imgView addGestureRecognizer:longPress];
        
        [self.view addSubview:imgView];
    }
}

#pragma mark - TapGesture

- (void)handleTapBottom:(UITapGestureRecognizer *)tap {
    NSInteger index = 0;
    index = tap.view.tag;
    
    [self.homeVC.lblSubTitle setHidden:NO];
    [self.homeVC.lblSettings setHidden:YES];
    
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC showSubcategories:index];
        [self.homeVC setSettingButtonHidden:NO];
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
