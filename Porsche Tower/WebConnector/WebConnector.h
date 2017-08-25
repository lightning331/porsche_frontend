//
//  WebConnector.h
//  Porsche Tower
//
//  Created by Povel Sanrov on 19/08/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface WebConnector : NSObject {
    AFHTTPRequestOperationManager *httpManager;
    NSString *baseUrl;
}

typedef void (^CompleteBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^ErrorBlock)(AFHTTPRequestOperation *operation, NSError *error);

- (void)login:(NSString *)email password:(NSString *)password completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)getDataList:(NSString *)type completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)getStaffList:(NSString *)name completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)getRestaurantMenu:(NSString *)restaurant completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)sendScheduleRequest:(NSString *)type index:(NSString *)index datetime:(NSString *)datetime completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)sendScheduleRequestForPoolBeach:(NSString *)location datetime:(NSString *)datetime towels:(NSInteger)towels chairs:(NSInteger)chairs umbrella:(NSInteger)umbrella completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)sendRestaurantRequest:(NSString *)type restaurant:(NSString *)restaurant datetime:(NSString *)datetime completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)getPickup:(NSString *)car completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)getQueueSize:(NSString *)elevator completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)requestCarElevator:(NSString *)car valet:(NSString *)valet elevator:(NSString *)elevator delay:(NSString *)countdown completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)cancelCarElevator:(NSString *)pickup completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)getTimeIncrease:(NSString *)pickup completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)successCarElevator:(NSString *)pickup completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)scheduleCarElevator:(NSString *)car valet:(NSString *)valet elevator:(NSString *)elevator requestTime:(NSString *)requestTime repeat:(NSString *)repeat completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)getWeatherInformation:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)cancelScheduledCarElevator:(NSString *)pickup completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)getAutoField:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)checkCarAvailability:(NSString*)car_index completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)resetBadgeCount:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
- (void)resetPassword:(NSString*)password completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

@end
