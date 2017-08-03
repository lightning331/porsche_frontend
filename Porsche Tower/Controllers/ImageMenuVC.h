//
//  ImageMenuVC.h
//  P'0001
//
//  Created by Daniel on 31/7/17.
//  Copyright © 2017 Daniel Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"

@interface ImageMenuVC : BaseVC <UIAlertViewDelegate, UIWebViewDelegate>

@property HomeVC *homeVC;
@property NSMutableDictionary *scheduleData;
@property NSString *pdf_url;

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIButton *btnPlus;
@property (weak, nonatomic) IBOutlet UIWebView *wbPDF;

- (IBAction)onBtnCategory:(id)sender;
- (IBAction)onBtnClose:(id)sender;
- (IBAction)onBtnHome:(id)sender;
- (IBAction)onBtnPlus:(id)sender;

@end
