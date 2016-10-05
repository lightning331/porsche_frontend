//
//  ShowroomBookingVC.m
//  Porsche Tower
//
//  Created by Povel Sanrov on 27/07/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import "ShowroomBookingVC.h"
#import "Global.h"
#import <MBProgressHUD.h>
#import "WebConnector.h"
#import "CalendarVC.h"
#import "MenuVC.h"
#import "ElevatorControlVC.h"

@interface ShowroomBookingVC () {
    NSMutableArray *carInfoArray;
}

@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSArray *backImageArray;
@property (nonatomic) NSMutableArray *bottomItems;

@end

@implementation ShowroomBookingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector getDataList:@"car_information" completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if ([result[@"status"] isEqualToString:@"success"]) {
            carInfoArray = [[NSMutableArray alloc] initWithArray:[result[@"car_info_list"] mutableCopy]];
            
            NSLog(@"%@", carInfoArray);
            
            for (int i = 0; i < carInfoArray.count; i++) {
                NSMutableDictionary *carInfo = [carInfoArray[i] mutableCopy];
                NSURL *url = [NSURL URLWithString:carInfo[@"image"]];
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *image = [UIImage imageWithData:data];
                if (image)
                    [carInfo setObject:image forKey:@"imageData"];
                [carInfoArray replaceObjectAtIndex:i withObject:carInfo];
            }
            
            [self.collectionView reloadData];
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    Global *global = [Global sharedInstance];
    self.btnImageArray = global.btnImageArray;
    self.backImageArray = global.backImageArray;
    self.bottomItems = global.bottomItems;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
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
    [self dismissViewControllerAnimated:NO completion:^{
        [self.homeVC setHiddenCategories:NO];
    }];
}

- (IBAction)onBtnPlus:(id)sender {
    int status = 0;
    if ([self.type isEqualToString:@"detailing"] ||
        [self.type isEqualToString:@"service_car"] ||
        [self.type isEqualToString:@"storage"])
        status = 2;
    else
        status = 0;
    for (UIImageView* imgView in self.bottomItems)
        if ([self.btnImageArray objectAtIndex:0] == imgView.image)
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
    self.collectionView.hidden = NO;
    
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

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return carInfoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CarImageCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
    imageView.alpha = 1.0;
    
    [imageView setImage:carInfoArray[indexPath.row][@"imageData"]];
    
    UIView *viewInfo = (UIView *)[cell viewWithTag:1001];
    
    UILabel *lblName = (UILabel *)[cell viewWithTag:102];
    lblName.text = carInfoArray[indexPath.row][@"name"];
    
    UILabel *lblSpace = (UILabel *)[cell viewWithTag:103];

    NSString *space = carInfoArray[indexPath.row][@"space"];
    if ([space isEqualToString:@"garage"]) {
        viewInfo.backgroundColor = [UIColor colorWithRed:156.0/255 green:3.0/255 blue:20.0/255 alpha:1.0];
        
        space = @"Garage";
    }
    NSString *status = carInfoArray[indexPath.row][@"status"];
    if ([status isEqualToString:@"in"]) {
        viewInfo.backgroundColor = [UIColor colorWithRed:11.0/255 green:65.0/255 blue:8.0/255 alpha:1.0];
        
        status = @"IN";
    }
    else if ([status isEqualToString:@"out"]) {
        viewInfo.backgroundColor = [UIColor colorWithRed:156.0/255 green:3.0/255 blue:20.0/255 alpha:1.0];
        
        status = @"OUT";
    }
    else if ([status isEqualToString:@"active"]) {
        viewInfo.backgroundColor = [UIColor yellowColor];
        lblName.textColor = [UIColor blackColor];
        lblSpace.textColor = [UIColor blackColor];
        
        status = @"ACTIVE";
    }
    
    lblSpace.text = [NSString stringWithFormat:@"%@ - %@", space, status];
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((collectionView.frame.size.width - 10) / 2, collectionView.frame.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.type isEqualToString:@"request"]) {
        if ([carInfoArray[indexPath.row][@"status"] isEqualToString:@"out"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_car_unavailable", nil) message:NSLocalizedString(@"msg_unavailable_contact_valet", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"title_close", nil) otherButtonTitles:NSLocalizedString(@"title_valet", nil), nil];
            alertView.tag = 1001;
            [alertView show];
        } else if ([carInfoArray[indexPath.row][@"space"] isEqualToString:@"garage"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_car_in_gargage", nil) message:NSLocalizedString(@"msg_parked_gargage_contact_valet", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"title_close", nil) otherButtonTitles:NSLocalizedString(@"title_valet", nil), nil];
            alertView.tag = 1001;
            [alertView show];
        } else {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *requestElevator = [[NSMutableDictionary alloc] init];
            
            NSMutableDictionary *carInfo = [carInfoArray[indexPath.row] mutableCopy];
            if ([carInfo objectForKey:@"imageData"])
                [carInfo removeObjectForKey:@"imageData"];
            [requestElevator setObject:carInfo forKey:@"SelectedCar"];
            
            NSMutableArray *owners = [userDefaults objectForKey:@"CurrentUser"];
            for (int i = 0; i < owners.count; i++) {
                if ([carInfo[@"owner"] isEqualToString:owners[i][@"index"]]) {
                    [requestElevator setObject:[owners[i] mutableCopy] forKey:@"Owner"];
                }
            }
            
            [userDefaults setObject:requestElevator forKey:@"RequestElevator"];
            
            if ([carInfoArray[indexPath.row][@"status"] isEqualToString:@"active"]) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                ElevatorControlVC *elevatorControlVC = [storyboard instantiateViewControllerWithIdentifier:@"ElevatorControlVC"];
                elevatorControlVC.view.backgroundColor = [UIColor clearColor];
                elevatorControlVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                elevatorControlVC.homeVC = self.homeVC;
                
                self.definesPresentationContext = YES;
                self.collectionView.hidden = YES;
                [self presentViewController:elevatorControlVC animated:NO completion:^{
                    
                }];
            }
            else {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MenuVC *menuVC = [storyboard instantiateViewControllerWithIdentifier:@"MenuVC"];
                menuVC.view.backgroundColor = [UIColor clearColor];
                menuVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                menuVC.homeVC = self.homeVC;
                menuVC.type = @"request_car_elevator";
                
                self.definesPresentationContext = YES;
                self.collectionView.hidden = YES;
                [self presentViewController:menuVC animated:NO completion:^{
                    
                }];
            }
        }
    } else if ([self.type isEqualToString:@"schedule"]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *scheduleElevator = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *carInfo = [carInfoArray[indexPath.row] mutableCopy];
        [carInfo removeObjectForKey:@"imageData"];
        [scheduleElevator setObject:carInfo forKey:@"SelectedCar"];
        
        NSMutableArray *owners = [userDefaults objectForKey:@"CurrentUser"];
        for (int i = 0; i < owners.count; i++) {
            if ([carInfo[@"owner"] isEqualToString:owners[i][@"index"]]) {
                [scheduleElevator setObject:[owners[i] mutableCopy] forKey:@"Owner"];
            }
        }
        
        [userDefaults setObject:scheduleElevator forKey:@"ScheduleElevator"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MenuVC *menuVC = [storyboard instantiateViewControllerWithIdentifier:@"MenuVC"];
        menuVC.view.backgroundColor = [UIColor clearColor];
        menuVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        menuVC.homeVC = self.homeVC;
        menuVC.type = @"schedule_car_elevator";
        
        self.definesPresentationContext = YES;
        self.collectionView.hidden = YES;
        [self presentViewController:menuVC animated:NO completion:^{
            
        }];
    } else if ([self.type isEqualToString:@"detailing"] ||
               [self.type isEqualToString:@"service_car"] ||
               [self.type isEqualToString:@"storage"]) {
        self.collectionView.hidden = YES;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MenuVC *menuVC = [storyboard instantiateViewControllerWithIdentifier:@"MenuVC"];
        menuVC.view.backgroundColor = [UIColor clearColor];
        menuVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        menuVC.homeVC = self.homeVC;
        menuVC.type = self.type;
        
        self.definesPresentationContext = YES;
        [self presentViewController:menuVC animated:NO completion:^{
            
        }];
    }
}

#pragma mark - TapGesture

- (void)handleTapBottom:(UITapGestureRecognizer *)tap {
    [self.homeVC setSettingButtonHidden:NO];
    
    [self dismissViewControllerAnimated:NO completion:^{
        NSInteger index = tap.view.tag;
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
    if (alertView.tag == 1001) {
        if (buttonIndex == 1) {
            // Call Valet...
        }
    } else {
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
}

@end
