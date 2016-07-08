//
//  WebConnector.m
//  Porsche Tower
//
//  Created by Povel Sanrov on 19/08/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import "WebConnector.h"

@implementation WebConnector

- (id)init {
    if (self = [super init]) {
//        baseUrl = @"http://localhost/CodeIgniter-3.0.0/index.php/mobile/Mobile/";
        baseUrl = @"http://192.168.1.87/porsche/index.php/mobile/Mobile/";
//        baseUrl = @"http://52.26.240.113/Porsche/index.php/mobile/Mobile/";
        NSURL *url = [NSURL URLWithString:baseUrl];
        
        httpManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];        
    }
    
    return self;
}

- (void)login:(NSString *)email password:(NSString *)password completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"email"];
    [parameters setObject:password forKey:@"password"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [prefs objectForKey:@"DeviceToken"];
//    [parameters setObject:deviceToken forKey:@"device_token"];
    [parameters setObject:@"1bfe0817206ea50c7e62cd66a89286ed39c09892133d26e841bf828c3aeb0b75" forKey:@"device_token"];
    
    [httpManager POST:@"login" parameters:parameters success:completed failure:errorBlock];
}

- (void)getDataList:(NSString *)type completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *owner = [prefs objectForKey:@"CurrentUser"][0];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if ([type isEqualToString:@"car_information"]) {
        [parameters setObject:owner[@"id"] forKey:@"owner_id"];
    } else {
        [parameters setObject:owner[@"index"] forKey:@"owner"];
    }
    
    [httpManager POST:[NSString stringWithFormat:@"get_%@", type] parameters:parameters success:completed failure:errorBlock];
}

- (void)getRestaurantMenu:(NSString *)restaurant completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:restaurant forKey:@"restaurant"];
    
    [httpManager POST:@"get_restaurant_menu" parameters:parameters success:completed failure:errorBlock];
}

- (void)sendScheduleRequest:(NSString *)type index:(NSString *)index datetime:(NSString *)datetime completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *owner = [prefs objectForKey:@"CurrentUser"][0];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:type forKey:@"type"];
    [parameters setObject:index forKey:@"index"];
    [parameters setObject:owner[@"index"] forKey:@"owner"];
    [parameters setObject:datetime forKey:@"date_time"];
    
    [httpManager POST:@"send_schedule_request" parameters:parameters success:completed failure:errorBlock];
}

- (void)sendScheduleRequestForPoolBeach:(NSString *)location datetime:(NSString *)datetime towels:(NSInteger)towels chairs:(NSInteger)chairs umbrella:(NSInteger)umbrella completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *owner = [prefs objectForKey:@"CurrentUser"][0];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:owner[@"index"] forKey:@"owner"];
    [parameters setObject:location forKey:@"location"];
    [parameters setObject:datetime forKey:@"date_time"];
    [parameters setObject:[NSNumber numberWithInteger:towels] forKey:@"towels"];
    [parameters setObject:[NSNumber numberWithInteger:chairs] forKey:@"chairs"];
    [parameters setObject:[NSNumber numberWithInteger:umbrella] forKey:@"umbrella"];
    
    [httpManager POST:@"send_schedule_request_for_pool_beach" parameters:parameters success:completed failure:errorBlock];
}

- (void)sendRestaurantRequest:(NSString *)type restaurant:(NSString *)restaurant datetime:(NSString *)datetime completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *owner = [prefs objectForKey:@"CurrentUser"][0];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:type forKey:@"type"];
    [parameters setObject:restaurant forKey:@"restaurant"];
    [parameters setObject:owner[@"index"] forKey:@"owner"];
    [parameters setObject:datetime forKey:@"date_time"];
    
    [httpManager POST:@"send_restaurant_request" parameters:parameters success:completed failure:errorBlock];
}

- (void)getPickup:(NSString *)car completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:car forKey:@"car"];
    
    [httpManager POST:@"get_pickup" parameters:parameters success:completed failure:errorBlock];
}

- (void)getQueueSize:(NSString *)elevator completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:elevator forKey:@"elevator"];
    
    [httpManager POST:@"get_elevator_queue_size" parameters:parameters success:completed failure:errorBlock];
}

- (void)requestCarElevator:(NSString *)car valet:(NSString *)valet elevator:(NSString *)elevator delay:(NSString *)delay completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:car forKey:@"car"];
    [parameters setObject:valet forKey:@"valet"];
    [parameters setObject:elevator forKey:@"elevator"];
    [parameters setObject:delay forKey:@"delay"];
    
    [httpManager POST:@"request_car_elevator" parameters:parameters success:completed failure:errorBlock];
}

- (void)cancelCarElevator:(NSString *)pickup completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:pickup forKey:@"pickup"];
    
    [httpManager POST:@"cancel_car_elevator" parameters:parameters success:completed failure:errorBlock];
}

- (void)getTimeIncrease:(NSString *)pickup completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:pickup forKey:@"pickup"];
    
    [httpManager POST:@"get_time_increase" parameters:parameters success:completed failure:errorBlock];
}

- (void)successCarElevator:(NSString *)pickup completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:pickup forKey:@"pickup"];
    
    [httpManager POST:@"success_car_elevator" parameters:parameters success:completed failure:errorBlock];
}

- (void)scheduleCarElevator:(NSString *)car valet:(NSString *)valet elevator:(NSString *)elevator requestTime:(NSString *)requestTime repeat:(NSString *)repeat completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:car forKey:@"car"];
    [parameters setObject:valet forKey:@"valet"];
    [parameters setObject:elevator forKey:@"elevator"];
    [parameters setObject:requestTime forKey:@"request_time"];
    [parameters setObject:repeat forKey:@"repeat"];
    
    [httpManager POST:@"schedule_car_elevator" parameters:parameters success:completed failure:errorBlock];
}

- (void)cancelScheduledCarElevator:(NSString *)pickup completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *owner = [prefs objectForKey:@"CurrentUser"][0];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:owner[@"index"] forKey:@"owner"];
    [parameters setObject:pickup forKey:@"pickup"];
    
    [httpManager POST:@"cancel_scheduled_car_elevator" parameters:parameters success:completed failure:errorBlock];
}

- (void)getWeatherInformation:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock {
    NSString *weatherAPIKey = @"e0d2184799fefb0c";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.wunderground.com/api/%@/conditions/q/", weatherAPIKey]];
    AFHTTPRequestOperationManager *httpManagerForWeather = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    [httpManagerForWeather GET:@"FL/Miami.json" parameters:nil success:completed failure:errorBlock];
}

@end