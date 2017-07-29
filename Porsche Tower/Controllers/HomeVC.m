//
//  ViewController.m
//  Porsche Tower
//
//  Created by Daniel on 5/7/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import "HomeVC.h"
#import "Global.h"
#import "MenuVC.h"
#import "SettingsVC.h"
#import "ShowroomBookingVC.h"
#import "PersonalNotificationsVC.h"
#import "EventNotificationsVC.h"
#import "MaintenanceVC.h"
#import "WeatherVC.h"
#import "SelectTimeVC.h"
#import "ScheduledPickupsVC.h"
#import <MBProgressHUD.h>
#import "WebConnector.h"

#define TIME 1.4
#define TAG_BOTTOM_BUTTON   20

@interface HomeVC ()<DLCustomScrollViewDelegate,DLCustomScrollViewDataSource>

{
    NSInteger status;
    
    BOOL isSubMenu;
    NSArray *subMenuArray;
    
    NSMutableArray *bottomItems;
}

@property (nonatomic) CGFloat viewSize;
@property (nonatomic) CGSize viewBackSize;
@property (nonatomic) NSArray *btnImageArray;
@property (nonatomic) NSArray *backImageArray;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    
    //subtitle
    
    [self.lblSettings setHidden:YES];
    [self.lblSubTitle setHidden:NO];
    
    // Sub Title Font
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        [self.lblSubTitle setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:27]];
    }
    else {
        [self.lblSubTitle setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:17]];
    }
    if (self.view.bounds.size.width == 1366)
        [self.lblSubTitle setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:36]];
    
    Global *global = [Global sharedInstance];
    self.btnImageArray = global.btnImageArray;
    self.backImageArray = global.backImageArray;
    
    isSubMenu = NO;
    subMenuArray = [[NSArray alloc] init];
    self.pickerView.hidden = YES;
    self.viewPickerBackground.hidden = YES;
    self.tableView.hidden = YES;
    
    UITapGestureRecognizer *submenuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapSubmenu:)];
    [self.pickerView addGestureRecognizer:submenuTap];
    submenuTap.delegate = self;
    
    UIPanGestureRecognizer *submenuPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanSubmenu:)];
    [self.pickerView addGestureRecognizer:submenuPan];
    submenuPan.delegate = self;
    
    self.imgTopLeft.hidden = YES;
    
    bottomItems = global.bottomItems;
    
    self.scrollView.dataSource = self;
    self.scrollView.maxScrollDistance = 5;
    self.scrollView.delegate = self;
    self.scrollView.tag = 1;
    
    self.scrollViewBack.dataSource = self;
    self.scrollViewBack.maxScrollDistance = 5;
    self.scrollViewBack.delegate = nil;
    self.scrollViewBack.tag = 2;
    
    status = -1;
    
    UIImage *img1 = [self.btnImageArray objectAtIndex:0];
    self.viewSize = img1.size.width / TIME;
    
    UIImage *img = [self.backImageArray objectAtIndex:0];
    
    NSLog(@"bound.width : %f scrollview.width : %f", self.view.bounds.size.width, self.scrollView.bounds.size.width);
    
    //Background Image Size for each device
    if (self.view.bounds.size.width == 736)
        self.viewBackSize = CGSizeMake(self.scrollView.bounds.size.width / 2.4f, img.size.height);
    else if (self.view.bounds.size.width == 667)
        self.viewBackSize = CGSizeMake(self.scrollView.bounds.size.width / 2.8f, img.size.height * 1.3f);
    else if (self.view.bounds.size.width == 568)
        self.viewBackSize = CGSizeMake(self.scrollView.bounds.size.width / 3.2f, img.size.height);
    else if (self.view.bounds.size.width == 1024) {
        self.viewSize = img1.size.width;
        self.viewBackSize = CGSizeMake(self.scrollView.bounds.size.width / 1.9f, img.size.height / img.size.width * self.scrollView.bounds.size.width / 2.0f);
    }
    else if (self.view.bounds.size.width == 1366) {
        self.viewSize = img1.size.width;
        self.viewBackSize = CGSizeMake(self.scrollView.bounds.size.width / 1.3f, img.size.height / img.size.width * self.scrollView.bounds.size.width / 1.3f);
    }
    else
        self.viewBackSize = CGSizeMake(img.size.width, img.size.height);
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self setSettingButtonHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setSettingButtonHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isCarScheduled = [userDefaults boolForKey:@"IsCarScheduled"];
    BOOL isGotMessage = [userDefaults boolForKey:@"IsGotMessage"];
    BOOL isGotEvent = [userDefaults boolForKey:@"IsGotEvent"];
    if (isCarScheduled) {
        NSMutableArray *owners = [userDefaults objectForKey:@"CurrentUser"];
        NSString *ownerID = [userDefaults objectForKey:@"ScheduleOwnerID"];
        for (int i = 0; i < owners.count; i++) {
            if ([ownerID isEqualToString:owners[i][@"id"]]) {
                [userDefaults removeObjectForKey:@"IsCarScheduled"];
                
                [self gotoCarSelect];
                
                break;
            }
        }
    }
    else if (isGotMessage) {
        [userDefaults removeObjectForKey:@"IsGotMessage"];
        [self gotoPersonalNotifications];
    }
    else if (isGotEvent) {
        [userDefaults removeObjectForKey:@"IsGotEvent"];
        [self gotoEventNotifications];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (status == -1) {
        status = 0;
        
        [self.scrollView reloadData];
        [self.scrollViewBack reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Self Methods

- (void)updateBottomButtons {
    for (int i = 0; i < bottomItems.count; i++ ) {
        UIImageView *imgView = [bottomItems objectAtIndex:i];
        imgView.frame = CGRectMake(self.btnHome.frame.origin.x + ((self.btnPlus.frame.origin.x - self.btnHome.frame.origin.x) / (CATEGORY_COUNT + 1)) * (i+ 1), self.btnHome.frame.origin.y, self.btnHome.frame.size.width, self.btnHome.frame.size.height);
        
        imgView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBottom:)];
        [imgView addGestureRecognizer:singleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressBottom:)];
        [imgView addGestureRecognizer:longPress];
        
        [self.view addSubview:imgView];
    }
}

- (void)updatePickerViewHidden:(BOOL)isHidden {
    self.pickerView.hidden = isHidden;
}

- (void)setHiddenCategories:(BOOL)hidden {
    isSubMenu = hidden;
    
    if (isSubMenu) {
        if (status == 0) {
            self.pickerView.hidden = YES;
            self.tableView.hidden = NO;
        } else {
            self.pickerView.hidden = NO;
            self.tableView.hidden = YES;
        }
        self.viewPickerBackground.hidden = NO;
        self.imgTopLeft.hidden = NO;
        self.scrollView.hidden = YES;
    }
    else {
        self.pickerView.hidden = YES;
        self.viewPickerBackground.hidden = YES;
        self.tableView.hidden = YES;
        self.imgTopLeft.hidden = YES;
        self.scrollView.hidden = NO;
        
        self.lblSubTitle.text = CATEGORY_ARRAY[status];
    }
    
    [self updateBottomButtons];
}

- (void)showSubcategories:(NSInteger)index {
    if (index < 0)
        if ((-index) % CATEGORY_COUNT == 0)
            status = 0;
        else
            status = CATEGORY_COUNT - ((-index) % CATEGORY_COUNT);
        else
            status = index % CATEGORY_COUNT;
    
    [self.scrollView scrollToIndex:index animated:YES];
    
    self.imgTopLeft.image = [self.btnImageArray objectAtIndex:status];
    
    self.lblSubTitle.text = CATEGORY_ARRAY[status];
    
    [self setHiddenCategories:YES];
    
//    if (status == 7) {
//        subMenuArray = [[NSArray alloc] init];
//        [self.pickerView reloadAllComponents];
//        
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        
//        WebConnector *webConnector = [[WebConnector alloc] init];
//        [webConnector getDataList:@"document" completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
//            
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            
//            NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
//            if ([result[@"status"] isEqualToString:@"success"]) {
//                NSMutableArray *documentArray = [result[@"document_list"] mutableCopy];
//                NSMutableArray *documentNameArray = [[NSMutableArray alloc] init];
//                for (NSInteger i = 0; i < documentArray.count; i++) {
//                    [documentNameArray addObject:documentArray[i][@"name"]];
//                }
//                subMenuArray = [[NSArray alloc] initWithArray:documentNameArray];
//                [self.pickerView reloadAllComponents];
//            }
//        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//        }];
//    }
//    else {
        subMenuArray = SUBCATEGORY_ARRAY[status];
        [self.pickerView reloadAllComponents];
        [self.tableView reloadData];
//    }
}

- (void)openMenu:(NSString *)type {
    self.pickerView.hidden = YES;
    
    if ([type isEqualToString:@"repeat_schedule"]) {
        self.lblSubTitle.text = NSLocalizedString(@"msg_repeat_scheduled_pickup", nil);
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MenuVC *menuVC = [storyboard instantiateViewControllerWithIdentifier:@"MenuVC"];
    menuVC.view.backgroundColor = [UIColor clearColor];
    menuVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    menuVC.homeVC = self;
    menuVC.type = type;
    
    self.definesPresentationContext = YES;
    [self customPresentViewController:menuVC animated:NO completion:^{
        
    }];
}

- (void)openTime:(NSString *)location {
    self.pickerView.hidden = YES;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SelectTimeVC *selectTimeVC = [storyboard instantiateViewControllerWithIdentifier:@"SelectTimeVC"];
    selectTimeVC.view.backgroundColor = [UIColor clearColor];
    selectTimeVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    selectTimeVC.homeVC = self;
    selectTimeVC.scheduleData = [[NSMutableDictionary alloc] init];
    [selectTimeVC.scheduleData setObject:location forKey:@"Location"];
    [selectTimeVC.scheduleData setObject:@"pool_beach" forKey:@"type"];
    selectTimeVC.selectedDate = [NSDate date];
    
    self.definesPresentationContext = YES;
    [self customPresentViewController:selectTimeVC animated:NO completion:^{
        
    }];
}

- (void)gotoCarSelect {
    
    [self showSubcategories:0];
    
    self.lblSubTitle.text = [subMenuArray objectAtIndex:0];
    self.pickerView.hidden = YES;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowroomBookingVC *showroomBookingVC = [storyboard instantiateViewControllerWithIdentifier:@"ShowroomBookingVC"];
    showroomBookingVC.view.backgroundColor = [UIColor clearColor];
    showroomBookingVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    showroomBookingVC.homeVC = self;
    showroomBookingVC.type = @"request";
    
    self.definesPresentationContext = YES;
    [self customPresentViewController:showroomBookingVC animated:NO completion:^{
        
    }];
}

- (void)getAutoField {
    
}

- (void)gotoPersonalNotifications
{
    [self showSubcategories:8];
    
    self.lblSubTitle.text = [subMenuArray objectAtIndex:1];
    self.pickerView.hidden = YES;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PersonalNotificationsVC *personalNotificationsVC = [storyboard instantiateViewControllerWithIdentifier:@"PersonalNotificationsVC"];
    personalNotificationsVC.view.backgroundColor = [UIColor clearColor];
    personalNotificationsVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    personalNotificationsVC.homeVC = self;
    
    self.definesPresentationContext = YES;
    [self customPresentViewController:personalNotificationsVC animated:NO completion:^{
        
    }];
}

- (void)gotoEventNotifications
{
    [self showSubcategories:8];
    
    self.lblSubTitle.text = [subMenuArray objectAtIndex:3];
    self.pickerView.hidden = YES;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EventNotificationsVC *eventNotificationsVC = [storyboard instantiateViewControllerWithIdentifier:@"EventNotificationsVC"];
    eventNotificationsVC.view.backgroundColor = [UIColor clearColor];
    eventNotificationsVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    eventNotificationsVC.homeVC = self;
    
    self.definesPresentationContext = YES;
    [self customPresentViewController:eventNotificationsVC animated:NO completion:^{
        
    }];
}

-(void)customPresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    [self setSettingButtonHidden:YES];
    [self presentViewController:viewControllerToPresent animated:flag completion:^{
        
    }];

}

- (void)setSettingButtonHidden: (BOOL)hidden{
    [self.btnSettings setHidden:hidden];
}

#pragma mark - UI Actions

- (IBAction)onBtnPlus:(id)sender {
    if (isSubMenu)
    {
        for (UIImageView* imgView in bottomItems)
            if (imgView.tag == status)
                return;
        if (bottomItems.count == CATEGORY_COUNT)
            [bottomItems removeObjectAtIndex:0];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[self.btnImageArray objectAtIndex:status]];
        imgView.tag = status;
        [bottomItems addObject:imgView];
        [self updateBottomButtons];
    }
}

- (IBAction)onBtnSettings:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsVC *settingsVC = [storyboard instantiateViewControllerWithIdentifier:@"SettingsVC"];
    settingsVC.view.backgroundColor = [UIColor clearColor];
    settingsVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    settingsVC.homeVC = self;
    self.definesPresentationContext = YES;
    [self customPresentViewController:settingsVC animated:NO completion:^{
        
    }];
    
//    [self.lblSubTitle setText:NSLocalizedString(@"outlet_settings", nil)];
    [self.lblSettings setHidden:NO];
    [self.lblSubTitle setHidden:YES];
    
}

- (IBAction)onBtnHome:(id)sender {
    [self setHiddenCategories:NO];
}

# pragma mark - DLCustomScrollView dataSource

- (NSInteger)numberOfViews:(DLCustomScrollView *)scrollView
{
    return 100000;
}

- (CGFloat)widthOfView:(DLCustomScrollView *)scrollView
{
    NSLog(@"scrollWidth: %@", NSStringFromCGRect(scrollView.bounds));
    if (scrollView.tag == 1) {
        return (scrollView.bounds.size.width / 3.5f);
    } else {
        return (scrollView.bounds.size.width / 1.7f);
//        return (scrollView.bounds.size.width /1.7f);
    }
}

# pragma mark - DLCustomScrollView delegate

- (UIView *)scrollView:(DLCustomScrollView *)scrollView viewAtIndex:(NSInteger)index reusingView:(UIView *)view;
{
    //First ScrollView
    if (scrollView.tag == 1)
    {
        //If view was already created
        if (view) {
            if (index < 0)
            {
                if (((-index) % CATEGORY_COUNT) == 0)
                {
                    ((UIImageView*)view).image = (UIImage*)[self.btnImageArray objectAtIndex:0];
                    view.tag = 0;
                }
                else
                {
                    ((UIImageView*)view).image = (UIImage*)[self.btnImageArray objectAtIndex:(CATEGORY_COUNT - ((-index) % CATEGORY_COUNT))];
                    view.tag = CATEGORY_COUNT - ((-index) %  CATEGORY_COUNT);
                    NSLog(@"ind %lu", (long)index);
                    NSLog(@"tag %lu", (long)view.tag);
                }
            }
            else
            {
                ((UIImageView*)view).image = (UIImage*)[self.btnImageArray objectAtIndex:(index % CATEGORY_COUNT)];
                view.tag = index % CATEGORY_COUNT;
            }
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTap:)];
            [view addGestureRecognizer:singleTap];
            return view;
        }
        //If view is empty
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.viewSize, self.viewSize)];
        if (index < 0)
        {
            if ((-index) % CATEGORY_COUNT == 0)
            {
                imgView.image = (UIImage*)[self.btnImageArray objectAtIndex:0];
                imgView.tag = 0;
            }
            else
            {
                imgView.image = (UIImage*)[self.btnImageArray objectAtIndex:(CATEGORY_COUNT - ((-index) %  CATEGORY_COUNT))];
                imgView.tag = CATEGORY_COUNT - ((-index) %  CATEGORY_COUNT);
            }
        }
        else
        {
            imgView.image = (UIImage*)[self.btnImageArray objectAtIndex:(index % CATEGORY_COUNT)];
            imgView.tag = index % CATEGORY_COUNT;
        }
        imgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [imgView addGestureRecognizer:singleTap];
        return imgView;
    }
    
    //Background ScrollView
    
    //If view is already created
    if (view) {
        if (index < 0)
            if ((-index) % CATEGORY_COUNT == 0)
            {
                ((UIImageView*)view).image = (UIImage*)[self.backImageArray objectAtIndex:0];
            }
            else
            {
                ((UIImageView*)view).image = (UIImage*)[self.backImageArray objectAtIndex:(CATEGORY_COUNT - ((-index) %  CATEGORY_COUNT))];
            }
            else
            {
                ((UIImageView*)view).image = (UIImage*)[self.backImageArray objectAtIndex:(index % CATEGORY_COUNT)];
            }
        view.contentMode = UIViewContentModeScaleToFill;
        return view;
    }
    //If view is empty
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.viewBackSize.width , self.viewBackSize.height)];
    if (index < 0)
        if ((-index) % CATEGORY_COUNT == 0)
            imgView.image = (UIImage*)[self.backImageArray objectAtIndex:0];
        else
            imgView.image = (UIImage*)[self.backImageArray objectAtIndex:(CATEGORY_COUNT - ((-index) %  CATEGORY_COUNT))];
        else
            imgView.image = (UIImage*)[self.backImageArray objectAtIndex:(index % CATEGORY_COUNT)];
    imgView.contentMode = UIViewContentModeScaleToFill;
    return imgView;
}

- (void)scrollView:(DLCustomScrollView *)scrollView updateView:(UIView *)view withDistanceToCenter:(CGFloat)distance scrollDirection:(ScrollDirection)direction
{
    // you can appy animations duration scrolling here
    if (scrollView.tag == 1)
    {
        CGFloat percent = distance / CGRectGetWidth(self.view.bounds) * 3;
        
        if (percent > -0.05 && percent < 0.05) {
            NSInteger index = view.tag;
            NSLog(@"Center Index: %ld", (long)index);
            
            if (index < 0)
                if ((-index) % CATEGORY_COUNT == 0)
                    index = 0;
                else
                    index = CATEGORY_COUNT - ((-index) % CATEGORY_COUNT);
                else
                    index = index % CATEGORY_COUNT;
            
            if (!isSubMenu) {
                self.lblSubTitle.text = CATEGORY_ARRAY[index];
            }
        }
        
        CATransform3D transform = CATransform3DIdentity;
        
        // scale transform
        CGFloat size = self.viewSize;
        CGPoint center = view.center;
        view.center = center;
        size = size * (TIME - 0.3 * (fabs(percent)));
        view.frame = CGRectMake(0, 0, size, size);
//        view.layer.cornerRadius = size / 2;
        view.center = center;
        
        // translate
        CGFloat translate = self.viewSize / 3 * percent;
        if (percent > 1) {
            translate = self.viewSize / 3;
        } else if (percent < -1) {
            translate = -self.viewSize / 3;
        }
        transform = CATransform3DTranslate(transform, translate, 0, 0);
        
        view.layer.transform = transform;
    }
    else
    {
        CGFloat percent = distance / CGRectGetWidth(self.view.bounds) * 3;
        
        CATransform3D transform = CATransform3DIdentity;
        
        // scale
        CGFloat size = self.viewSize;
        CGPoint center = view.center;
        view.center = center;
        size = size * (TIME - 0.3 * (fabs(percent)));
        view.frame = CGRectMake(0, 0, size, size);
        view.layer.cornerRadius = size / 2;
        view.center = center;
        
        // translate
        CGFloat translate = self.viewSize / 3 * percent;
        if (percent > 1) {
            translate = self.viewSize / 3;
        } else if (percent < -1) {
            translate = -self.viewSize / 3;
        }
        transform = CATransform3DTranslate(transform, translate, 0, 0);
        
        view.layer.transform = transform;
    }
    
}

- (void)scrollView:(DLCustomScrollView *)scrollView didScrollToOffset:(CGPoint)offset
{
    if (scrollView.tag == 1) {
        NSLog(@"didScrollToOffset");
        CGFloat maxOffset = [scrollView contentSize].width - CGRectGetWidth(scrollView.bounds);
        CGFloat percentage = offset.x / maxOffset;
        CGFloat backMaxOffset = [self.scrollViewBack contentSize].width - CGRectGetWidth(self.scrollViewBack.bounds);
        [self.scrollViewBack scrollToOffset:CGPointMake(percentage * backMaxOffset, 0) animated:NO];
    }
}

#pragma mark - UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return subMenuArray.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view) {
        CGSize size = [pickerView rowSizeForComponent:component];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        if ([[UIDevice currentDevice].model containsString:@"iPad"])
            [label setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:28]];
        else
            [label setFont:[UIFont fontWithName:NAME_OF_MAINFONT size:18]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        label.numberOfLines = 1;
        label.text = [subMenuArray objectAtIndex:row];
        [view addSubview:label];
    }
    
    return view;
}

#pragma mark - UIPickerView Delegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    CGFloat height;
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        height = 62;
    }
    else {
        height = 40;
    }
    return height;
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return subMenuArray.count;
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
    cell.textLabel.text = [subMenuArray objectAtIndex:indexPath.row];
        
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
    
    if (status == 0) { // Car Elevator
        self.lblSubTitle.text = [subMenuArray objectAtIndex:indexPath.row];
        self.tableView.hidden = YES;
        
        if (indexPath.row == 0 || indexPath.row == 1) {
            WebConnector *webConnector = [[WebConnector alloc] init];
            [webConnector getAutoField:^(AFHTTPRequestOperation *operation, id responseObject) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
                if ([result[@"status"] isEqualToString:@"success"]) {
                    NSString *autoField = result[@"auto_field"];
                    if ([autoField isEqualToString:@"1"]) {
                        // User able to see cars
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        ShowroomBookingVC *showroomBookingVC = [storyboard instantiateViewControllerWithIdentifier:@"ShowroomBookingVC"];
                        showroomBookingVC.view.backgroundColor = [UIColor clearColor];
                        showroomBookingVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                        showroomBookingVC.homeVC = self;
                        
                        if (indexPath.row == 0) {
                            showroomBookingVC.type = @"request";
                        } else if (indexPath.row == 1) {
                            showroomBookingVC.type = @"schedule";
                        }
                        
                        self.definesPresentationContext = YES;
                        [self customPresentViewController:showroomBookingVC animated:NO completion:^{
                            
                        }];
                    }
                    else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"msg_elevator_unavailable",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                        self.tableView.hidden = NO;
                        // Error message
                    }
                }
            } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                // Error message
            }];
        } else if (indexPath.row == 2) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ScheduledPickupsVC *scheduledPickupsVC = [storyboard instantiateViewControllerWithIdentifier:@"ScheduledPickupsVC"];
            scheduledPickupsVC.view.backgroundColor = [UIColor clearColor];
            scheduledPickupsVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            scheduledPickupsVC.homeVC = self;
            
            self.definesPresentationContext = YES;
            [self customPresentViewController:scheduledPickupsVC animated:NO completion:^{
                
            }];
        }
    }
}

#pragma mark - TapGesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return true;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    NSInteger index = tap.view.tag;
    NSLog(@"Index: %ld", (long)index);

    [self showSubcategories:index];
}

- (void)handleTapSubmenu:(UITapGestureRecognizer *)tap {
    
    CGPoint touchPoint = [tap locationInView:self.pickerView];
    CGSize rowSize = [self.pickerView rowSizeForComponent:0];
    CGSize pickerSize = self.pickerView.frame.size;
    
    if ((touchPoint.y > pickerSize.height / 2 - rowSize.height / 2 + 10) && (touchPoint.y < pickerSize.height / 2 + rowSize.height / 2 - 10)) {
        NSInteger index = [self.pickerView selectedRowInComponent:0];
        
        if (status == 0) { // Car Elevator
            self.lblSubTitle.text = [subMenuArray objectAtIndex:index];
            self.pickerView.hidden = YES;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ShowroomBookingVC *showroomBookingVC = [storyboard instantiateViewControllerWithIdentifier:@"ShowroomBookingVC"];
            showroomBookingVC.view.backgroundColor = [UIColor clearColor];
            showroomBookingVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            showroomBookingVC.homeVC = self;
            
            if (index == 0) {
                showroomBookingVC.type = @"request";
            } else if (index == 1) {
                showroomBookingVC.type = @"schedule";
            }
            
            self.definesPresentationContext = YES;
            [self customPresentViewController:showroomBookingVC animated:NO completion:^{
                    
            }];

        }
        else if (status == 1) { // In-Unit
            if (index == 0) {
//                [self openMenu:@"request_maintenance"];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                [dateFormatter setTimeZone:[calendar timeZone]];
                NSString *datetimeString = [dateFormatter stringFromDate:[NSDate date]];
                
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                /*
                 WebConnector *webConnector = [[WebConnector alloc] init];
                 [webConnector sendRestaurantRequest:@"order" restaurant:[self.scheduleData objectForKey:@"index"] datetime:datetimeString completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 
                 NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
                 if ([result[@"status"] isEqualToString:@"success"]) {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"msg_order_req_confirmed", nil) message:@"Your request was sent. A staff member will call to take your order shortly." delegate:nil cancelButtonTitle:NSLocalizedString(@"title_close", nil) otherButtonTitles:nil];
                 [alertView show];
                 }
                 } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 }];*/
                
//                NSString *type = [self.scheduleData objectForKey:@"type"];
                NSString *index_num = @"5";
                NSString *type = @"request_maintenance";
                
                WebConnector *webConnector = [[WebConnector alloc] init];
                [webConnector sendScheduleRequest:type index:index_num datetime:datetimeString completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSLog(@"response object: %@", responseObject);
                    
                    NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
                    if ([result[@"status"] isEqualToString:@"success"]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"msg_request_sent",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                        [self setHiddenCategories:NO];
                    }
                } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }];
            }
            else if (index == 1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"msg_front_desk_req_confirmed", nil) message:NSLocalizedString(@"msg_req_sent_front_desk", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"title_close", nil) otherButtonTitles:nil];
                [alertView show];
            }
            else if (index == 3) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"msg_security_req_confirmed", nil) message:NSLocalizedString(@"msg_req_sent_security", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"title_close", nil) otherButtonTitles:nil];
                [alertView show];
            }
        }
        else if (status == 2) { // Car Concierge
            self.lblSubTitle.text = [subMenuArray objectAtIndex:index];
            self.pickerView.hidden = YES;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ShowroomBookingVC *showroomBookingVC = [storyboard instantiateViewControllerWithIdentifier:@"ShowroomBookingVC"];
            showroomBookingVC.view.backgroundColor = [UIColor clearColor];
            showroomBookingVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            showroomBookingVC.homeVC = self;
            
            if (index == 0) {
                showroomBookingVC.type = @"detailing";
            } else if (index == 1) {
                showroomBookingVC.type = @"service_car";
            } else if (index == 2) {
                showroomBookingVC.type = @"storage";
            }
            
            self.definesPresentationContext = YES;
            [self customPresentViewController:showroomBookingVC animated:NO completion:^{
                
            }];
        }
        else if (status == 3) { // Pool & Beach
            self.lblSubTitle.text = [NSString stringWithFormat:@"%@ Request", [subMenuArray objectAtIndex:index]];
            
            if (index == 0) {
                [self openTime:@"Pool"];
            }
            else if (index == 1) {
                [self openTime:@"Beach"];
            }
        }
        else if (status == 4) { // Wellness
            self.lblSubTitle.text = [NSString stringWithFormat:@"%@ Menu", [subMenuArray objectAtIndex:index]];
            
            if (index == 0) {
                [self openMenu:@"spa"];
            }
            else if (index == 1) {
                [self openMenu:@"gym"];
            }
        }
        else if (status == 5) { // Activities
            self.lblSubTitle.text = [subMenuArray objectAtIndex:index];
            
            if (index == 0) {
                [self openMenu:@"golf_sim"];
            }
            else if (index == 1) {
                [self openMenu:@"racing_sim"];
            }
            else if (index == 2) {
                [self openMenu:@"theater"];
            }
            else if (index == 3) {
                [self openMenu:@"community_room"];
            }
        }
        else if (status == 6) { // Dining
            self.lblSubTitle.text = [subMenuArray objectAtIndex:index];
            
            if (index == 0) {
                [self openMenu:@"restaurants_in_house"];
            }
            else if (index == 1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"msg_order_req_confirmed", nil) message:NSLocalizedString(@"msg_req_sent_staff_member", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"title_close", nil) otherButtonTitles:nil];
                [alertView show];
            }
        }
        else if (status == 7) { // Documents
            if (index == 0)
            {
                //Documents
                self.lblSubTitle.text = [NSString stringWithFormat:@"%@", [subMenuArray objectAtIndex:index]];
                [self openMenu:@"document"];
                self.pickerView.hidden = YES;
            }
            else
            {
                //Unit Manual
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
                WebConnector *webConnector = [[WebConnector alloc] init];
                [webConnector getDataList:@"unit_manual" completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
        
                    NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
                    if ([result[@"status"] isEqualToString:@"success"]) {
                        NSMutableArray *documentArray = [result[@"unit_manual"] mutableCopy];
                        NSString *doc_url = documentArray[0][@"doc_url"];
                        if (doc_url)
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:doc_url]];
                    }
                } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@", error);
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }];
            }
            
            
            
        }
        else if (status == 8) { // Information Board
            self.lblSubTitle.text = [subMenuArray objectAtIndex:index];
            
            if (index == 1) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                PersonalNotificationsVC *personalNotificationsVC = [storyboard instantiateViewControllerWithIdentifier:@"PersonalNotificationsVC"];
                personalNotificationsVC.view.backgroundColor = [UIColor clearColor];
                personalNotificationsVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                personalNotificationsVC.homeVC = self;
                
                self.definesPresentationContext = YES;
                [self customPresentViewController:personalNotificationsVC animated:NO completion:^{
                    
                }];
            }
            else if (index == 2) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MaintenanceVC *maintenanceVC = [storyboard instantiateViewControllerWithIdentifier:@"MaintenanceVC"];
                maintenanceVC.view.backgroundColor = [UIColor clearColor];
                maintenanceVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                maintenanceVC.homeVC = self;
                
                self.definesPresentationContext = YES;
                [self customPresentViewController:maintenanceVC animated:NO completion:^{
                    
                }];
            }
            else if (index == 3) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                EventNotificationsVC *eventNotificationsVC = [storyboard instantiateViewControllerWithIdentifier:@"EventNotificationsVC"];
                eventNotificationsVC.view.backgroundColor = [UIColor clearColor];
                eventNotificationsVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                eventNotificationsVC.homeVC = self;
                
                self.definesPresentationContext = YES;
                [self customPresentViewController:eventNotificationsVC animated:NO completion:^{
                    
                }];
            }
        }
        else if (status == 9) { // Local Info
            self.lblSubTitle.text = [subMenuArray objectAtIndex:index];
            
            if (index == 0) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                WeatherVC *weatherVC = [storyboard instantiateViewControllerWithIdentifier:@"WeatherVC"];
                weatherVC.view.backgroundColor = [UIColor clearColor];
                weatherVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                weatherVC.homeVC = self;
                
                self.definesPresentationContext = YES;
                [self customPresentViewController:weatherVC animated:NO completion:^{
                    
                }];
                
                self.pickerView.hidden = YES;
            }
            else if (index == 1) {
                NSURL *url = [NSURL URLWithString:@"https://www.wunderground.com/webcams/zafer/7/show.html"];
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        else if (status == 10) { // Concierge
            self.lblSubTitle.text = [subMenuArray objectAtIndex:index];
            
            if (index == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"msg_housekeeping_req_confirmed", nil) message:NSLocalizedString(@"msg_req_sent_staff_member", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"title_close", nil) otherButtonTitles:nil];
                [alertView show];
            }
            else if (index == 1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"msg_transportation_req_confirmed", nil) message:NSLocalizedString(@"msg_req_sent_staff_member", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"title_close", nil) otherButtonTitles:nil];
                [alertView show];
            }
            else if (index == 2) {
                [self openMenu:@"dry_cleaning"];
            }
        }
    }
    
}

- (void)handlePanSubmenu:(UIPanGestureRecognizer *)pan {
    
}

- (void)handleTapBottom:(UITapGestureRecognizer *)tap {
    [self showSubcategories:tap.view.tag];
}

- (void)handleLongPressBottom:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state == UIGestureRecognizerStateEnded && bottomItems.count > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_remove_shortcut", nil) message:NSLocalizedString(@"msg_sure_to_remove_shortcut", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        alertView.tag = longPress.view.tag;
        
        [alertView show];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSInteger index = alertView.tag;
        
        for (UIImageView *imgView in bottomItems) {
            if (imgView.tag == index) {
                [bottomItems removeObject:imgView];
                [imgView removeFromSuperview];
                [self updateBottomButtons];
                return;
            }
        }
    }
}

@end
