//
//  Global.h
//  Porsche Tower
//
//  Created by Daniel on 5/7/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

//Porsh Design Font Name
#define NAME_OF_MAINFONT @"PorscheDesignFont"

#define BASE_URL         @"http://192.168.1.87/porsche/"
//#define BASE_URL         @"http://52.26.240.113/Porsche/"

#define NSLocalizedString(key, comment) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]


#define CATEGORY_ARRAY @[@"Car Elevator", @"In-Unit", @"Car Concierge", @"Pool & Beach", @"Wellness", @"Activities", @"Dining", @"Documents", @"Information Board", @"Local Info", @"Concierge"]

#define CATEGORY_COUNT CATEGORY_ARRAY.count

#define SUBCATEGORY_ARRAY @[@[@"Request Car Elevator", @"Schedule Car Elevator", @"Scheduled Pickups"], \
                            @[@"Request Maintenance", @"Request Front Desk Call Back", @"View Front Desk Camera", @"Request Security"], \
                            @[@"Detailing", @"Service", @"Storage"], \
                            @[@"Pool", @"Beach"], \
                            @[@"Salon Spa", @"Fitness", @"Request Room"], \
                            @[@"Golf Sim", @"Racing Sim", @"Theater", @"Community Room"], \
                            @[@"In House Dining", @"Request a Call"], \
                            @[@"Warranties", @"Owners Manual", @"Contractors Manual", @"Condominium Documents", @"Authorization Forms"], \
                            @[@"Directory", @"Personal Notifications", @"Building Maintenance", @"Building Events"], \
                            @[@"Weather", @"View Weather", @"View Beach"], \
                            @[@"Request HouseKeeping", @"Request Transportation", @"Dry Cleaning"]]

@interface Global : NSObject

+ (Global *)sharedInstance;

@property (strong, nonatomic, readwrite) NSArray *btnImageArray;
@property (strong, nonatomic, readwrite) NSArray *backImageArray;
@property (strong, nonatomic, readwrite) NSMutableArray *bottomItems;

@end
