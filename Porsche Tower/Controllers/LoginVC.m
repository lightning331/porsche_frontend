//
//  LoginVC.m
//  Porsche Tower
//
//  Created by Daniel on 5/9/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import "LoginVC.h"
#import "Global.h"
#import <MBProgressHUD.h>
#import "WebConnector.h"
#import "HomeVC.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "Setting.h"

@interface LoginVC ()

@property (nonatomic) bool isChecked;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblLogin.text = NSLocalizedString(@"outlet_login", nil);
    self.txtEmail.placeholder = NSLocalizedString(@"outlet_email", nil);
    self.txtPassword.placeholder = NSLocalizedString(@"outlet_password", nil);
    [self.btnSignIn setTitle:NSLocalizedString(@"outlet_signin", nil) forState:UIControlStateNormal];
    [self.btnUseTouchID setTitle:NSLocalizedString(@"outlet_use_touchid", nil) forState:UIControlStateNormal];
    
//    NSString *language = LocalizationGetLanguage;
//    switch (language)
//    
//    {
//        case "en":
//            
//            statements
//            
//            break;
//            
//        case "de":
//            
//            statements
//            
//            break;
//            
//        case "es":
//            
//            statements
//            
//            break;
//            
//        case "it":
//            
//            statements
//            
//            break;
//            
//        default:
//            break;
//            
//    }
    
    
    UIFont *font = [UIFont fontWithName:NAME_OF_MAINFONT size:11.0f];
    [self.lblLogin setFont:font];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"server url:%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SERVER_URL"]);
    NSLog(@"SERVER_URL:%@", SERVER_URL);
    
#ifdef DEV_MODE
    [self loginProcess:@"foxymen9@gmail.com" password:@"test"];
#endif
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([[prefs objectForKey:@"UseTouchID"] boolValue]) {
        self.viewContent.hidden = YES;
        
        LAContext *myContext = [[LAContext alloc] init];
        NSError *authError = nil;
        NSString *myLocalizedReasonString = @"Used for quick and secure access to the P'0001 app";
        
        if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
            [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                      localizedReason:myLocalizedReasonString
                                reply:^(BOOL success, NSError *error) {
                                    if (success) {
                                        NSLog(@"User authenticated successfully, take appropriate action");
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                            HomeVC *homeVC = [storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
                                            
                                            [self.navigationController pushViewController:homeVC animated:YES];
                                        });
                                    } else {
                                        NSLog(@"User did not authenticate successfully, look at error and take appropriate action");
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_error", nil) message:NSLocalizedString(@"msg_not_device_owner", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            [alert show];
                                            self.viewContent.hidden = NO;
                                        });
                                    }
                                }];
        } else {
            // Could not evaluate policy; look at authError and present an appropriate message to user
            NSLog(@"%@", authError);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_error", nil)
                message:NSLocalizedString(@"msg_cannot_authenticate_touchid", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                self.viewContent.hidden = NO;
            });
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UI Actions

- (IBAction)onLogin:(id)sender {
    NSString *email = self.txtEmail.text;
    NSString *password = self.txtPassword.text;
    
    if ([email isEqualToString:@""] || [password isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"msg_pls_all_fields", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([Utility validateEmailWithString:email]) {
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"msg_valid_email", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self loginProcess:email password:password];
}

- (IBAction)onUseTouchID:(id)sender {
    self.isChecked = !self.isChecked;
    [self updateCheckBox];
}

- (IBAction)onChxUseTouchId:(id)sender {
    self.isChecked = !self.isChecked;
    [self updateCheckBox];
}

#pragma mark - Self Methodsdf

- (void)updateCheckBox {
    if (self.isChecked == false)
        [self.btnCheckbox setImage:[UIImage imageNamed:@"checkbox_unchecked"] forState:UIControlStateNormal];
    else
        [self.btnCheckbox setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
}

- (void)loginProcess:(NSString *)email password:(NSString *)password {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector login:email password:password completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if ([result[@"status"] isEqualToString:@"success"]) {
            NSDictionary *owner = result[@"owner"];
            if (owner != nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs setObject:owner forKey:@"CurrentUser"];
                
                if (self.isChecked) {
                    [prefs setObject:[NSNumber numberWithBool:true] forKey:@"UseTouchID"];
                } else {
                    [prefs removeObjectForKey:@"UseTouchID"];
                }
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                HomeVC *homeVC = [storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
                
                
                [self.navigationController pushViewController:homeVC animated:YES];
                self.txtEmail.text = @"";
                self.txtPassword.text = @"";
                self.isChecked = false;
                [self updateCheckBox];
                [self.view endEditing:YES];
                
            } else {
                NSString *url = [NSString stringWithFormat:@"%@Auth/LoginProcess?email=%@&password=%@", BASE_URL, email, password];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
                
                self.txtEmail.text = @"";
                self.txtPassword.text = @"";
            }
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to login" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to login" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}
@end
