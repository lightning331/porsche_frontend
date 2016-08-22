//
//  CalendarVC.m
//  Porsche Tower
//
//  Created by Povel Sanrov on 10/07/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import "CalendarVC.h"
#import "Global.h"
#import "MenuVC.h"
#import "SelectTimeVC.h"
#import "ShowroomBookingVC.h"

@interface CalendarVC ()

@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSArray *backImageArray;
@property (nonatomic) NSMutableArray *bottomItems;

@property (nonatomic, strong) PMCalendarController *pmCC;

@end

@implementation CalendarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Global *global = [Global sharedInstance];
    self.btnImageArray = global.btnImageArray;
    self.backImageArray = global.backImageArray;
    self.bottomItems = global.bottomItems;
    
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        [self.btnCancel setBackgroundColor:[UIColor clearColor]];
        [self.btnCancel setBackgroundImage:nil forState:UIControlStateNormal];
        [self.btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.btnCancel.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:24]];
    }
    
    [self.btnCancel setTitle:NSLocalizedString(@"outlet_cancel", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.pmCC = [[PMCalendarController alloc] initWithSize:self.viewCalendar.frame.size];
    self.pmCC.delegate = self;
    self.pmCC.mondayFirstDayOfWeek = NO;
    
    [self.pmCC presentCalendarFromView:self.viewCalendar
              permittedArrowDirections:PMCalendarArrowDirectionAny
                              animated:YES];
    
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

- (IBAction)onBtnCancel:(id)sender {
    [self.homeVC setSettingButtonHidden:NO];
    
    UIViewController *viewController = self.presentationController.presentingViewController;
    if ([viewController isKindOfClass:[MenuVC class]]) {
        [(MenuVC *)viewController updateBottomButtons];
    }
    else {
        ShowroomBookingVC *showroomBookingVC = (ShowroomBookingVC *)viewController;
        [showroomBookingVC updateBottomButtons];
    }
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (IBAction)onBtnHome:(id)sender {
    [self.homeVC setSettingButtonHidden:NO];
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:NO];
    }];
}

- (IBAction)onBtnPlus:(id)sender {
    int status = 0;
    NSString *type = [self.scheduleData objectForKey:@"type"];
    if ([type isEqualToString:@"schedule_car_elevator"]) {
        status = 0;
    }
    else if ([type isEqualToString:@"service_car"] ||
             [type isEqualToString:@"detailing"] ||
             [type isEqualToString:@"storage"]) {
        status = 2;
    }
    else if ([type isEqualToString:@"pool_beach"]) {
        status = 3;
    }
    else if ([type isEqualToString:@"spa"] ||
             [type isEqualToString:@"gym_equipment"] ||
             [type isEqualToString:@"massage"] ||
             [type isEqualToString:@"barber"]) {
        status = 4;
    }
    else if ([type isEqualToString:@"golf_sim"] ||
             [type isEqualToString:@"racing_sim"] ||
             [type isEqualToString:@"theater"] ||
             [type isEqualToString:@"community_room"]) {
        status = 5;
    }
    else if ([type isEqualToString:@"housekeeping"] ||
             [type isEqualToString:@"dry_cleaning"]) {
        status = 10;
    }
    
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

#pragma mark - PMCalendarControllerDelegate methods

- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod {
    self.selectedDate = newPeriod.startDate;
    NSDate *now = [NSDate date];
    NSInteger delta = [now timeIntervalSinceDate:self.selectedDate] / 86400;
    
    if (delta > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_error", nil) message:NSLocalizedString(@"msg_cant_select_date", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    MenuVC *menuVC = (MenuVC *)self.presentationController.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SelectTimeVC *selectTimeVC = [storyboard instantiateViewControllerWithIdentifier:@"SelectTimeVC"];
        selectTimeVC.view.backgroundColor = [UIColor clearColor];
        selectTimeVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        selectTimeVC.homeVC = self.homeVC;
        selectTimeVC.scheduleData = [self.scheduleData mutableCopy];
        selectTimeVC.selectedDate = self.selectedDate;
        
        menuVC.definesPresentationContext = YES;
        [menuVC presentViewController:selectTimeVC animated:NO completion:^{
            return;
        }];
    }];
}

@end
