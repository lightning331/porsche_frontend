//
//  MenuVC.m
//  Porsche Tower
//
//  Created by Povel Sanrov on 08/07/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import "MenuVC.h"
#import "Global.h"
#import "WebConnector.h"
#import <MBProgressHUD.h>
#import "DescriptionVC.h"
#import "CalendarVC.h"
#import "GymServiceVC.h"
#import "DescriptionWithCallVC.h"
#import "ElevatorControlVC.h"
#import "DiningVC.h"

@interface MenuVC () {
    NSArray *menuArray;
}

@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSArray *backImageArray;
@property (nonatomic) NSMutableArray *bottomItems;

@end

@implementation MenuVC

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
    
    // Car Elevator -> Request/Schedule -> Select Car
    if ([self.type isEqualToString:@"request_car_elevator"] || [self.type isEqualToString:@"schedule_car_elevator"]) {
        menuArray = [NSArray arrayWithObjects:NSLocalizedString(@"title_ride_down", nil), @"Valet", nil];
        [self.tableView reloadData];
    }
    else if ([self.type isEqualToString:@"repeat_schedule"]) {
        menuArray = [NSArray arrayWithObjects:NSLocalizedString(@"title_one_time", nil), NSLocalizedString(@"title_daily", nil), NSLocalizedString(@"title_weekly", nil), nil];
        [self.tableView reloadData];
    }
//    // In Unit -> Request Maintenance
//    else if ([self.type isEqualToString:@"request_maintenance"])
//    {
//        menuArray = [NSArray arrayWithObjects:NSLocalizedString(@"title_request_maintenance", nil), nil];
//        [self.tableView reloadData];
//    }
    // Wellness -> Fitness
    else if ([self.type isEqualToString:@"gym"]) {
        menuArray = [NSArray arrayWithObjects:NSLocalizedString(@"title_personal_trainers", nil), NSLocalizedString(@"title_classes", nil), nil];
        [self.tableView reloadData];
    }
    // Activities -> Theater
    else if ([self.type isEqualToString:@"theater"]) {
        menuArray = [NSArray arrayWithObjects:NSLocalizedString(@"title_schedule_for_priate", nil), NSLocalizedString(@"title_movie_schedule", nil), nil];
        [self.tableView reloadData];
    }
    // Concierge -> Transportation
    else if ([self.type isEqualToString:@"transportation"]) {
        menuArray = [NSArray arrayWithObjects:NSLocalizedString(@"title_taxis", nil), NSLocalizedString(@"title_shuttles", nil), NSLocalizedString(@"title_car_rental", nil), nil];
        [self.tableView reloadData];
    }
    // Car Concierge -> Detailing/Service/Storage
    // Wellness -> Salon Spa/Massage/Barber
    // Activities -> Golf Sim/Racing Sim/Community Room
    // Dining -> In House Dining/Local Restaurants
    // In Unit -> Request Maintenance
    // Concierge -> Housekeeping/Dry Cleaning
    else {
        [self getMenuList];
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

- (IBAction)onBtnHome:(id)sender {
    [self.homeVC setSettingButtonHidden:NO];
    [self.homeVC dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:NO];
    }];
}

- (IBAction)onBtnPlus:(id)sender {
    int status = 0;
    if ([self.type isEqualToString:@"request_car_elevator"] ||
        [self.type isEqualToString:@"schedule_car_elevator"] ||
        [self.type isEqualToString:@"request_car_elevator_choose_time"] ||
        [self.type isEqualToString:@"repeat_schedule"]) {
        status = 0;
    }
    else if ([self.type isEqualToString:@"request_maintenance"]) {
        status = 1;
    }
    else if ([self.type isEqualToString:@"service_car"] ||
        [self.type isEqualToString:@"detailing"] ||
        [self.type isEqualToString:@"storage"]) {
        status = 2;
    }
    else if ([self.type isEqualToString:@"spa"] ||
             [self.type isEqualToString:@"gym"] ||
             [self.type isEqualToString:@"gym_classes"] ||
             [self.type isEqualToString:@"gym_trainers"] ||
             [self.type isEqualToString:@"gym_equipment"] ||
             [self.type isEqualToString:@"massage"] ||
             [self.type isEqualToString:@"barber"]) {
        status = 4;
    }
    else if ([self.type isEqualToString:@"golf_sim"] ||
             [self.type isEqualToString:@"racing_sim"] ||
             [self.type isEqualToString:@"theater"] ||
             [self.type isEqualToString:@"community_room"]) {
        status = 5;
    }
    else if ([self.type isEqualToString:@"restaurants_in_house"] ||
             [self.type isEqualToString:@"local_restaurants"]) {
        status = 6;
    }
    else if ([self.type isEqualToString:@"document"]) {
        status = 7;
    }
    else if ([self.type isEqualToString:@"housekeeping"] ||
             [self.type isEqualToString:@"transportation"] ||
             [self.type isEqualToString:@"taxis"] ||
             [self.type isEqualToString:@"shuttles"] ||
             [self.type isEqualToString:@"car_rental"] ||
             [self.type isEqualToString:@"dry_cleaning"]) {
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
    self.tableView.hidden = NO;
    
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

- (void)getMenuList {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector getDataList:self.type completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        NSLog(@"result of getmenulist:%@", result);
        if ([result[@"status"] isEqualToString:@"success"]) {
            menuArray = [result[[NSString stringWithFormat:@"%@_list", self.type]] mutableCopy];
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error of getmenulist:%@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)openDescriptionView:(NSInteger)index hasCall:(BOOL)hasCall {
    NSMutableDictionary *scheduleData = [[menuArray objectAtIndex:index] mutableCopy];
    [scheduleData setObject:self.type forKey:@"type"];
    
    if (hasCall == NO) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DescriptionVC *descriptionVC = [storyboard instantiateViewControllerWithIdentifier:@"DescriptionVC"];
        descriptionVC.view.backgroundColor = [UIColor clearColor];
        descriptionVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        descriptionVC.homeVC = self.homeVC;
        
        descriptionVC.scheduleData = [scheduleData mutableCopy];
        
        self.definesPresentationContext = YES;
        [self presentViewController:descriptionVC animated:NO completion:^{
            return;
        }];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DescriptionWithCallVC *descriptionWithCallVC = [storyboard instantiateViewControllerWithIdentifier:@"DescriptionWithCallVC"];
        descriptionWithCallVC.view.backgroundColor = [UIColor clearColor];
        descriptionWithCallVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        descriptionWithCallVC.homeVC = self.homeVC;
        
        descriptionWithCallVC.scheduleData = [scheduleData mutableCopy];
        
        self.definesPresentationContext = YES;
        [self presentViewController:descriptionWithCallVC animated:NO completion:^{
            return;
        }];
    }
}

- (void)openDining:(NSInteger)index {
    NSMutableDictionary *scheduleData = [[menuArray objectAtIndex:index] mutableCopy];
    [scheduleData setObject:self.type forKey:@"type"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DiningVC *diningVC = [storyboard instantiateViewControllerWithIdentifier:@"DiningVC"];
    diningVC.view.backgroundColor = [UIColor clearColor];
    diningVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    diningVC.homeVC = self.homeVC;
    
    diningVC.scheduleData = [scheduleData mutableCopy];
    
    self.definesPresentationContext = YES;
    [self presentViewController:diningVC animated:NO completion:^{
        return;
    }];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        [cell.textLabel setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:28]];
    }
    else {
        [cell.textLabel setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:18]];
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    
    // Car Elevator -> Request/Schedule -> Select Car
    if ([self.type isEqualToString:@"request_car_elevator"] ||
        [self.type isEqualToString:@"schedule_car_elevator"] ||
        [self.type isEqualToString:@"repeat_schedule"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
    }
    // Car Elevator -> Request/Schedule -> Select Car -> Ride Down/Valet
    else if ([self.type isEqualToString:@"request_car_elevator_choose_time"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
    }
    // In Unit -> Request Maintenance -> Request Maintenance
    else if ([self.type isEqualToString:@"request_maintenance"])
    {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"title"];
    }
    // Car Concierge -> Detailing/Service/Storage
    else if ([self.type isEqualToString:@"detailing"] ||
        [self.type isEqualToString:@"service_car"] ||
        [self.type isEqualToString:@"storage"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"service"];
    }
    // Wellness -> Salon Spa/Barber
    else if ([self.type isEqualToString:@"spa"] ||
        [self.type isEqualToString:@"barber"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"service"];
    }
    // Wellness -> Fitness
    else if ([self.type isEqualToString:@"gym"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
    }
    // Wellness -> Fitness -> Personal Trainers
    else if ([self.type isEqualToString:@"gym_trainers"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"staff_name"];
    }
    // Wellness -> Fitness -> Classes
    else if ([self.type isEqualToString:@"gym_classes"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"gym_class_name"];
    }
    //
    else if ([self.type isEqualToString:@"gym_equipment"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"name"];
    }
    else if ([self.type isEqualToString:@"massage"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"name"];
    }
    // Activities -> Golf Sim/Racing Sim/Community Room
    else if ([self.type isEqualToString:@"golf_sim"] ||
        [self.type isEqualToString:@"racing_sim"] ||
        [self.type isEqualToString:@"community_room"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"service"];
    }
    // Activities -> Theater
    else if ([self.type isEqualToString:@"theater"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
    }
    // Dining -> In House Dining/Local Restaurants
    else if ([self.type isEqualToString:@"restaurants_in_house"] ||
             [self.type isEqualToString:@"local_restaurants"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"name"];
    }
    // Concierge -> Housekeeping/Dry Cleaning
    else if ([self.type isEqualToString:@"housekeeping"] ||
             [self.type isEqualToString:@"dry_cleaning"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"name"];
    }
    // Concierge -> Transportation
    else if ([self.type isEqualToString:@"transportation"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
    }
    // Concierge -> Transportation -> Taxis/Shuttles/Car Rental
    else if ([self.type isEqualToString:@"taxis"] ||
             [self.type isEqualToString:@"shuttles"] ||
             [self.type isEqualToString:@"car_rental"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"company"];
    }
    // Documents -> Documents
    else if ([self.type isEqualToString:@"document"]) {
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row][@"name"];
    }
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        height = 62;
    }
    else {
        height = 40;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.hidden = YES;
    
    // Car Elevator -> Request -> Select Car -> Selecting ...
    if ([self.type isEqualToString:@"request_car_elevator"]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *requestElevator = [[userDefaults objectForKey:@"RequestElevator"] mutableCopy];
        [requestElevator setObject:menuArray[indexPath.row] forKey:@"Valet"];
        [userDefaults setObject:requestElevator forKey:@"RequestElevator"];
        
//        self.type = @"request_car_elevator_choose_time";
//        menuArray = [NSArray arrayWithObjects:@"As Soon As Possible", @"Send Car In 5 Min", @"Send Car In 10 Min", @"Send Car In 15 Min", nil];
//        [self.tableView reloadData];
//        self.tableView.hidden = NO;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ElevatorControlVC *elevatorControlVC = [storyboard instantiateViewControllerWithIdentifier:@"ElevatorControlVC"];
        elevatorControlVC.view.backgroundColor = [UIColor clearColor];
        elevatorControlVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        elevatorControlVC.homeVC = self.homeVC;
        if (indexPath.row == 0) {
            elevatorControlVC.delayTime = 0;
        } else {
            elevatorControlVC.delayTime = 95;
        }
        
        self.definesPresentationContext = YES;
        [self presentViewController:elevatorControlVC animated:NO completion:^{
            return;
        }];
    }
    // Car Elevator -> Request -> Select Car -> Ride Down/Valet -> Selecting ...
    else if ([self.type isEqualToString:@"request_car_elevator_choose_time"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ElevatorControlVC *elevatorControlVC = [storyboard instantiateViewControllerWithIdentifier:@"ElevatorControlVC"];
        elevatorControlVC.view.backgroundColor = [UIColor clearColor];
        elevatorControlVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        elevatorControlVC.homeVC = self.homeVC;
        elevatorControlVC.delayTime = indexPath.row * 5;
        
        self.definesPresentationContext = YES;
        [self presentViewController:elevatorControlVC animated:NO completion:^{
            return;
        }];
    }
    // Car Elevator -> Schedule -> Select Car -> Selecting ...
    else if ([self.type isEqualToString:@"schedule_car_elevator"]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *scheduleElevator = [[userDefaults objectForKey:@"ScheduleElevator"] mutableCopy];
        [scheduleElevator setObject:menuArray[indexPath.row] forKey:@"Valet"];
        [userDefaults setObject:scheduleElevator forKey:@"ScheduleElevator"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CalendarVC *calendarVC = [storyboard instantiateViewControllerWithIdentifier:@"CalendarVC"];
        calendarVC.view.backgroundColor = [UIColor clearColor];
        calendarVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        calendarVC.homeVC = self.homeVC;
        
        calendarVC.scheduleData = [[NSMutableDictionary alloc] init];
        [calendarVC.scheduleData setObject:@"showroom_booking" forKey:@"type"];
        
        self.definesPresentationContext = YES;
        [self presentViewController:calendarVC animated:NO completion:^{
            return;
        }];
    }
    // Car Elevator -> Schedule -> Select Car -> Ride Down/Valet -> Select Date -> Select Time -> Selecting ...
    else if ([self.type isEqualToString:@"repeat_schedule"]) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *scheduleElevator = [prefs objectForKey:@"ScheduleElevator"];
        NSMutableDictionary *selectedCar = [[scheduleElevator objectForKey:@"SelectedCar"] mutableCopy];
        NSString *valet = [[scheduleElevator objectForKey:@"Valet"] mutableCopy];
        NSMutableDictionary *owner = [[scheduleElevator objectForKey:@"Owner"] mutableCopy];
        NSString *datetimeString = [[scheduleElevator objectForKey:@"Datetime"] mutableCopy];
        
        NSString *repeat = @"";
        switch (indexPath.row) {
            case 0:
                repeat = @"none";
                break;
                
            case 1:
                repeat = @"daily";
                break;
                
            case 2:
                repeat = @"weekly";
                break;
                
            case 3:
                repeat = @"monthlyByDay";
                break;
                
            case 4:
                repeat = @"monthlyByDate";
                break;
                
            default:
                repeat = @"none";
                break;
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector scheduleCarElevator:selectedCar[@"index"] valet:valet elevator:owner[@"unit"][@"elevator1"] requestTime:datetimeString repeat:repeat completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
            if ([result[@"status"] isEqualToString:@"success"]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Your Car Has Been Scheduled For Pick-up" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                [self.homeVC dismissViewControllerAnimated:NO completion:^{
                    [self.homeVC setHiddenCategories:NO];
                }];
            }
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
    // In Unit -> Request Maintenance -> Request Maintenance
    else if ([self.type isEqualToString:@"request_maintenance"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CalendarVC *calendarVC = [storyboard instantiateViewControllerWithIdentifier:@"CalendarVC"];
        calendarVC.view.backgroundColor = [UIColor clearColor];
        calendarVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        calendarVC.homeVC = self.homeVC;
        
        NSMutableDictionary *scheduleData = [[menuArray objectAtIndex:indexPath.row] mutableCopy];
        [scheduleData setObject:self.type forKey:@"type"];
        
        calendarVC.scheduleData = scheduleData;
        
        [self presentViewController:calendarVC animated:NO completion:^{
            return;
        }];

    }
    // Car Concierge -> Detailing/Service/Storage -> Selecting ...
    else if ([self.type isEqualToString:@"detailing"] ||
             [self.type isEqualToString:@"service_car"] ||
             [self.type isEqualToString:@"storage"]) {
        [self openDescriptionView:indexPath.row hasCall:NO];
    }
    // Wellness -> Spa -> Selecting ...
    else if ([self.type isEqualToString:@"spa"]) {
        [self openDescriptionView:indexPath.row hasCall:NO];
    }
    // Wellness -> Fitness -> Selecting ...
    else if ([self.type isEqualToString:@"gym"]) {
        self.homeVC.lblSubTitle.text = [menuArray objectAtIndex:indexPath.row];
        
        if (indexPath.row == 0) {
            self.type = @"gym_trainers";
        }
        else if (indexPath.row == 1) {
            self.type = @"gym_classes";
        }
//        else if (indexPath.row == 2) {
//            self.type = @"gym_equipment";
//        }
        
        [self getMenuList];
    }
    // Wellness -> Fitness -> Personal Trainers/Classes -> Selecting ...
    else if ([self.type isEqualToString:@"gym_classes"] ||
             [self.type isEqualToString:@"gym_trainers"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GymServiceVC *gymServiceVC = [storyboard instantiateViewControllerWithIdentifier:@"GymServiceVC"];
        gymServiceVC.view.backgroundColor = [UIColor clearColor];
        gymServiceVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        gymServiceVC.homeVC = self.homeVC;
        
        gymServiceVC.emailData = [[NSMutableDictionary alloc] init];
        if ([self.type isEqualToString:@"gym_classes"]) {
            [gymServiceVC.emailData setObject:[menuArray objectAtIndex:indexPath.row][@"gym_class_name"] forKey:@"name"];
        }
        else {
            [gymServiceVC.emailData setObject:[menuArray objectAtIndex:indexPath.row][@"staff_name"] forKey:@"name"];
        }
        [gymServiceVC.emailData setObject:[menuArray objectAtIndex:indexPath.row][@"description"] forKey:@"description"];
        [gymServiceVC.emailData setObject:[menuArray objectAtIndex:indexPath.row][@"phone"] forKey:@"phone"];
        [gymServiceVC.emailData setObject:self.type forKey:@"type"];
        
        NSURL *url = [NSURL URLWithString:[menuArray objectAtIndex:indexPath.row][@"image"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        gymServiceVC.imgStaff.image = image;
        
        self.definesPresentationContext = YES;
        [self presentViewController:gymServiceVC animated:NO completion:^{
            return;
        }];
    }
    // Wellness -> Massage/Barber -> Selecting ...
    else if ([self.type isEqualToString:@"massage"] ||
             [self.type isEqualToString:@"barber"]) {
        [self openDescriptionView:indexPath.row hasCall:NO];
    }
    // Activities -> Golf Sim/Racing Sim/Community Room -> Selecting ...
    else if ([self.type isEqualToString:@"golf_sim"] ||
             [self.type isEqualToString:@"racing_sim"] ||
             [self.type isEqualToString:@"community_room"]) {
        [self openDescriptionView:indexPath.row hasCall:NO];
    }
    // Activities -> Theater -> Selecting ...
    else if ([self.type isEqualToString:@"theater"]) {
        
    }
    // Dining -> In House Dining/Local Restaurants -> Selecting ...
    else if ([self.type isEqualToString:@"restaurants_in_house"] ||
             [self.type isEqualToString:@"local_restaurants"]) {
//    else if ([self.type isEqualToString:@"roomservice"] ||
//             [self.type isEqualToString:@"bars"] ||
//             [self.type isEqualToString:@"restaurants"] ||
//             [self.type isEqualToString:@"lounges"] ||
//             [self.type isEqualToString:@"pool_restaurants"] ||
//             [self.type isEqualToString:@"terraces"]) {
        [self openDining:indexPath.row];
    }
    // Concierge -> Housekeeping -> Selecting ...
    else if ([self.type isEqualToString:@"housekeeping"]) {
        [self openDescriptionView:indexPath.row hasCall:NO];
    }
    // Concierge -> Transportation -> Selecting ...
    else if ([self.type isEqualToString:@"transportation"]) {
        self.homeVC.lblSubTitle.text = [menuArray objectAtIndex:indexPath.row];
        
        if (indexPath.row == 0) {
            self.type = @"taxis";
        }
        else if (indexPath.row == 1) {
            self.type = @"shuttles";
        }
        else if (indexPath.row == 2) {
            self.type = @"car_rental";
        }
        
        [self getMenuList];
    }
    // Concierge -> Transportation -> Taxis/Shuttles/Car Rental -> Selecting ...
    else if ([self.type isEqualToString:@"taxis"] ||
             [self.type isEqualToString:@"shuttles"] ||
             [self.type isEqualToString:@"car_rental"]) {
        [self openDescriptionView:indexPath.row hasCall:YES];
    }
    // Concierge -> Dry Cleaning -> Selecting ...
    else if ([self.type isEqualToString:@"dry_cleaning"]) {
        [self openDescriptionView:indexPath.row hasCall:NO];
    }
    // Documents -> Documents -> Selecting ...
    else if ([self.type isEqualToString:@"document"]) {
        NSLog(@"file : %@", [menuArray objectAtIndex:indexPath.row][@"file"]);
        if ([menuArray objectAtIndex:indexPath.row][@"file"])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[menuArray objectAtIndex:indexPath.row][@"file"]]];
            self.tableView.hidden = NO;
        }
    }
}

#pragma mark - TapGesture

- (void)handleTapBottom:(UITapGestureRecognizer *)tap {
    [self.homeVC setSettingButtonHidden:NO];
    
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

@end
