//
//  SettingsVC.m
//  P'0001
//
//  Created by Bendt Jensen on 01/08/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import "SettingsVC.h"

@interface SettingsVC ()

@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSArray *backImageArray;
@property (nonatomic) NSMutableArray *bottomItems;

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)onBtnHome:(id)sender {
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:NO];
    }];
}

- (IBAction)onBtnPlus:(id)sender {
}

- (IBAction)onLogout:(id)sender {
}

- (IBAction)onResetPass:(id)sender {
}

- (IBAction)onTouchID:(id)sender {
}

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
    NSInteger index = 0;
    index = tap.view.tag;
    
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


- (IBAction)onEnglish:(id)sender {
}

- (IBAction)onGerman:(id)sender {
}

- (IBAction)onItalian:(id)sender {
}

- (IBAction)onSpanish:(id)sender {
}

- (IBAction)on1Min:(id)sender {
}

- (IBAction)on2Min:(id)sender {
}

- (IBAction)on3Min:(id)sender {
}

- (IBAction)on4Min:(id)sender {
}
@end
