//
//  ScheduledPickupsVC.h
//  P'0001
//
//  Created by Povel Sanrov on 6/23/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"

@interface ScheduledPickupsVC : UIViewController <UIAlertViewDelegate>

@property HomeVC *homeVC;

@property (weak, nonatomic) IBOutlet UILabel *lblCar;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblCancel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onBtnCategory:(id)sender;

@end
