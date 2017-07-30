//
//  Global.h
//  Porsche Tower
//
//  Created by Daniel on 5/7/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalizationSystem.h"

//Porsh Design Font Name
#define NAME_OF_MAINFONT @"PorscheDesignFont"

//#define BASE_URL         @"http://192.168.0.82:8012/porsche/"
#define BASE_URL         @"http://pdtowerapp.com/"
//#define BASE_URL         @"http://softdevsolutions.net/porsche"

#define LANGUAGE         @"Language"


#define LocalizationSetLanguage(language) \
[[LocalizationSystem sharedLocalSystem] setLanguage:(language)]

#define LocalizationGetLanguage \
[[LocalizationSystem sharedLocalSystem] getLanguage]


#define CATEGORY_ARRAY @[NSLocalizedString(@"title_car_elevator", nil), NSLocalizedString(@"title_in_unit", nil), NSLocalizedString(@"title_car_concierge", nil), NSLocalizedString(@"title_pool_beach", nil), NSLocalizedString(@"title_wellness", nil), NSLocalizedString(@"title_activities", nil), NSLocalizedString(@"title_dining", nil), NSLocalizedString(@"title_documents", nil), NSLocalizedString(@"title_information_board", nil), NSLocalizedString(@"title_local_info", nil), NSLocalizedString(@"title_concierge", nil)]

#define CATEGORY_COUNT      CATEGORY_ARRAY.count

#define SUBCATEGORY_ARRAY @[@[NSLocalizedString(@"title_request_car_elevator", nil), NSLocalizedString(@"title_schedule_car_elevator", nil), NSLocalizedString(@"title_scheduled_pickups", nil)], \
                            @[NSLocalizedString(@"title_request_maintenance", nil), NSLocalizedString(@"title_request_front_desk_call_back", nil), NSLocalizedString(@"title_view_front_desk_camera", nil), NSLocalizedString(@"title_request_security", nil)], \
                            @[NSLocalizedString(@"title_detailing", nil), NSLocalizedString(@"title_service", nil), NSLocalizedString(@"title_storage", nil)], \
                            @[NSLocalizedString(@"title_pool", nil), NSLocalizedString(@"title_beach", nil)], \
                            @[NSLocalizedString(@"title_salon_spa", nil), NSLocalizedString(@"title_fitness", nil), NSLocalizedString(@"title_request_room", nil)], \
                            @[NSLocalizedString(@"title_golf_sim", nil), NSLocalizedString(@"title_racing_sim", nil), NSLocalizedString(@"title_theater", nil), NSLocalizedString(@"title_community_room", nil)], \
                            @[NSLocalizedString(@"title_in_house_dining", nil), NSLocalizedString(@"title_request_a_call", nil)], \
                            @[NSLocalizedString(@"title_documents", nil), NSLocalizedString(@"title_unit_manual", nil)], \
                            @[NSLocalizedString(@"title_directory", nil), NSLocalizedString(@"title_personal_notifications", nil), NSLocalizedString(@"title_building_maintenance", nil), NSLocalizedString(@"title_building_events", nil)], \
                            @[NSLocalizedString(@"title_weather", nil), NSLocalizedString(@"title_view_weather", nil), NSLocalizedString(@"title_view_beach", nil)], \
                            @[NSLocalizedString(@"title_request_housekeeping", nil), NSLocalizedString(@"title_request_transportation", nil), NSLocalizedString(@"title_dry_cleaning", nil)]]



@interface Global : NSObject

+ (Global *)sharedInstance;

@property (strong, nonatomic, readwrite) NSArray *btnImageArray;
@property (strong, nonatomic, readwrite) NSArray *backImageArray;
@property (strong, nonatomic, readwrite) NSMutableArray *bottomItems;

@end
