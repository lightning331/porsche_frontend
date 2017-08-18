//
//  GymServiceVC.m
//  Porsche Tower
//
//  Created by Povel Sanrov on 09/08/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import "GymServiceVC.h"
#import "Global.h"
#import "MenuVC.h"

@interface GymServiceVC ()

@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSArray *backImageArray;
@property (nonatomic) NSMutableArray *bottomItems;

@end

@implementation GymServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Global *global = [Global sharedInstance];
    self.btnImageArray = global.btnImageArray;
    self.backImageArray = global.backImageArray;
    self.bottomItems = global.bottomItems;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.viewContent.layer.borderColor = [UIColor redColor].CGColor;
    self.viewContent.layer.borderWidth = 2;
    
    self.viewImageBorder.layer.borderColor = [UIColor redColor].CGColor;
    self.viewImageBorder.layer.borderWidth = 2;
    
    self.txtDescription.text = [NSString stringWithFormat:@"%@\n%@", [self.emailData objectForKey:@"name"], [self.emailData objectForKey:@"description"]];
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        [self.txtDescription setFont:[UIFont fontWithName:@"Helvetica Neue" size:22]];
        self.btnCall.hidden = YES;
    }
    else {
        [self.txtDescription setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    }
    
    [self updateBottomButtons];
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

- (IBAction)onBtnCategory:(id)sender {
    [self.homeVC setSettingButtonHidden:NO];
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:YES];
    }];
}

- (IBAction)onBtnClose:(id)sender {
    MenuVC *menuVC = (MenuVC *)self.presentationController.presentingViewController;
    [menuVC updateBottomButtons];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (IBAction)onBtnCall:(id)sender {
    NSString *strPhone = [[self.emailData objectForKey:@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *teleStr = [NSString stringWithFormat:@"telprompt:%@", strPhone];
    NSURL *phoneURL = [NSURL URLWithString:teleStr];
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:NSLocalizedString(@"msg_call_not_available",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)onBtnEmail:(id)sender {
    BOOL ok = [MFMailComposeViewController canSendMail];
    if (!ok) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_error", nil) message:NSLocalizedString(@"msg_dev_not_configured", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSString *email = @"bhaas@unlimitedcompanies.com";
        NSString *emailTitle = @"";
        
        NSString *messageBody = @"";
        
        NSArray *toRecipents = [NSArray arrayWithObject:email];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        [self presentViewController:mc animated:YES completion:NULL];
    }
}

- (IBAction)onBtnHome:(id)sender {
    [self.homeVC setSettingButtonHidden:NO];
    MenuVC *menuVC = (MenuVC *)self.presentationController.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [menuVC dismissViewControllerAnimated:NO completion:^{
            [self.homeVC setHiddenCategories:NO];
        }];
    }];
}

- (IBAction)onBtnPlus:(id)sender {
    for (UIImageView* imgView in self.bottomItems)
        if ([self.btnImageArray objectAtIndex:4] == imgView.image)
            return;
    if (self.bottomItems.count == self.btnImageArray.count)
        [self.bottomItems removeObjectAtIndex:0];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[self.btnImageArray objectAtIndex:4]];
    imgView.tag = 4;
    [self.bottomItems addObject:imgView];
    [self updateBottomButtons];
}

#pragma mark - Self Methods

- (void)updateBottomButtons {
    for (int i = 0; i < self.bottomItems.count; i++ ) {
        UIImageView *imgView = [self.bottomItems objectAtIndex:i];
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
    [self.homeVC setSettingButtonHidden:NO];
    MenuVC *menuVC = (MenuVC *)self.presentationController.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [menuVC dismissViewControllerAnimated:NO completion:^{
            NSInteger index = tap.view.tag;
            [self.homeVC showSubcategories:index];
        }];
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

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled");
            //NSLog(NSLocalizedString(@"msg_mail_cancelled",nil));
            [self messageAlert:NSLocalizedString(@"msg_mail_cancelled",nil) stats:@"Cancelled"];
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved");
            //NSLog(NSLocalizedString(@"msg_mail_saved",nil));
            [self messageAlert:NSLocalizedString(@"msg_mail_saved",nil) stats:@"Saved"];
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail sent");
//            NSLog(NSLocalizedString(@"msg_mail_send",nil));
            [self messageAlert:NSLocalizedString(@"msg_mail_send",nil) stats:@"Sent"];
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            //NSLog(@"Due to some error your email sending failed.");
            [self messageAlert:NSLocalizedString(@"msg_mail_failed",nil) stats:@"Failed"];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

-(void) messageAlert:(NSString*)str stats:(NSString*)status {
    if ([status isEqualToString:@"Failed"]) {
        UIAlertView *connectionAlert = [[UIAlertView alloc] init];
        [connectionAlert setTitle:NSLocalizedString(@"title_error", nil)];
        [connectionAlert setMessage:str];
        [connectionAlert setDelegate:self];
        [connectionAlert setTag:1];
        [connectionAlert addButtonWithTitle:@"OK"];
        [connectionAlert show];
    }
    else {
        UIAlertView *connectionAlert = [[UIAlertView alloc] init];
        [connectionAlert setTitle:@""];
        [connectionAlert setMessage:str];
        [connectionAlert setDelegate:self];
        [connectionAlert setTag:1];
        [connectionAlert addButtonWithTitle:@"OK"];
        [connectionAlert show];
        
        if (![status isEqualToString:@"Cancelled"]) {
            [self dismissViewControllerAnimated:NO completion:^{
                
            }];
        }
    }
}

@end
