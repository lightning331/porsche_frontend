//
//  BeachRequestVC.m
//  P'0001
//
//  Created by Povel Sanrov on 11/02/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import "BeachRequestVC.h"
#import "Global.h"
#import "WebConnector.h"
#import <MBProgressHUD.h>

@interface BeachRequestVC () {
    NSInteger towels;
    NSInteger chairs;
    NSInteger umbrella;
}

@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSMutableArray *bottomItems;

@end

@implementation BeachRequestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Global *global = [Global sharedInstance];
    self.btnImageArray = global.btnImageArray;
    self.bottomItems = global.bottomItems;
    
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        UIFont *font = self.lblTowels.font;
        NSString *fontName = font.fontName;
        [self.lblTowels setFont:[UIFont fontWithName:fontName size:33]];
        [self.lblChairs setFont:[UIFont fontWithName:fontName size:33]];
        [self.lblUmbrella setFont:[UIFont fontWithName:fontName size:33]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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

- (IBAction)onBtnHome:(id)sender {
    [self.homeVC setSettingButtonHidden:NO];
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:NO];
    }];
}

- (IBAction)onBtnPlus:(id)sender {
    int status = 3;
    
    for (UIImageView* imgView in self.bottomItems)
        if ([self.btnImageArray objectAtIndex:status] == imgView.image)
            return;
    if (self.bottomItems.count == self.btnImageArray.count)
        [self.bottomItems removeObjectAtIndex:0];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[self.btnImageArray objectAtIndex:status]];
    imgView.tag = status;
    [self.bottomItems addObject:imgView];
    [self updateBottomButtons];
}

- (IBAction)onBtnMinusTowels:(id)sender {
    if (towels > 0) {
        towels--;
        self.lblTowels.text = [NSString stringWithFormat:@"%ld", (long)towels];
    }
}

- (IBAction)onBtnPlusTowels:(id)sender {
    if (towels < 99) {
        towels++;
        self.lblTowels.text = [NSString stringWithFormat:@"%ld", (long)towels];
    }
}

- (IBAction)onBtnMinusChairs:(id)sender {
    if (chairs > 0) {
        chairs--;
        self.lblChairs.text = [NSString stringWithFormat:@"%ld", (long)chairs];
    }
}

- (IBAction)onBtnPlusChairs:(id)sender {
    if (chairs < 99) {
        chairs++;
        self.lblChairs.text = [NSString stringWithFormat:@"%ld", (long)chairs];
    }
}

- (IBAction)onBtnMinusUmbrella:(id)sender {
    if (umbrella > 0) {
        umbrella--;
        self.lblUmbrella.text = [NSString stringWithFormat:@"%ld", (long)umbrella];
    }
}

- (IBAction)onBtnPlusUmbrella:(id)sender {
    if (umbrella < 99) {
        umbrella++;
        self.lblUmbrella.text = [NSString stringWithFormat:@"%ld", (long)umbrella];
    }
}

- (IBAction)onBtnSendRequest:(id)sender {
    NSString *location = [self.scheduleData objectForKey:@"Location"];
    NSString *datetime = [self.scheduleData objectForKey:@"Datetime"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector sendScheduleRequestForPoolBeach:location datetime:datetime towels:towels chairs:chairs umbrella:umbrella completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if ([result[@"status"] isEqualToString:@"success"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"msg_request_sent",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
                        
            [self.homeVC dismissViewControllerAnimated:NO completion:^{
                [self.homeVC setHiddenCategories:NO];
            }];
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - Self Methods

- (void)updateBottomButtons {
    for (int i = 0; i < self.bottomItems.count; i++ ) {
        UIImageView *imgView = [self.bottomItems objectAtIndex:i];
        imgView.frame = CGRectMake(self.btnHome.frame.origin.x + ((self.btnPlus.frame.origin.x - self.btnHome.frame.origin.x) / self.btnImageArray.count) * (i+ 1), self.btnHome.frame.origin.y, self.btnHome.frame.size.width, self.btnHome.frame.size.height);
        
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
    NSInteger index = tap.view.tag;
    
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC showSubcategories:index];
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
