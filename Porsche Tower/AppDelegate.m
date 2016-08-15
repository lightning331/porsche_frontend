//
//  AppDelegate.m
//  Porsche Tower
//
//  Created by Daniel on 5/7/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginVC.h"
#import "HomeVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)logout
{
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    
    for (UIViewController *controller in navController.viewControllers){
        if ([controller isKindOfClass:[LoginVC class]]){
            [navController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"content---%@", token);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token forKey:@"DeviceToken"];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Failed to get token, error: %@", error);    
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    if ([userInfo[@"type"] isEqualToString:@"car_is_scheduled"]) {
////        if ([application applicationState] == UIApplicationStateActive) {
//            UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
//            NSArray *array = navigationController.viewControllers;
//            UIViewController *topViewController = (UIViewController *)array[array.count -1];
//            
//            if ([topViewController isKindOfClass:[LoginVC class]]) {
//                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//                [prefs setObject:[[NSNumber alloc] initWithBool:YES] forKey:@"IsCarScheduled"];
//                [prefs setObject:userInfo[@"owner_id"] forKey:@"ScheduleOwnerID"];
//            }
//            else if ([topViewController isKindOfClass:[HomeVC class]]) {
//                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                NSMutableArray *owners = [userDefaults objectForKey:@"CurrentUser"];
//                
//                for (int i = 0; i < owners.count; i++) {
//                    if ([userInfo[@"owner_id"] isEqualToString:owners[i][@"id"]]) {
//                        HomeVC *homeVC = (HomeVC *)topViewController;
//                        [homeVC gotoCarSelect];
//                        
//                        break;
//                    }
//                }
//            }
////        }
////        else {
////            
////        }
//    }
//}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    NSArray *array = navigationController.viewControllers;
    UIViewController *topViewController = (UIViewController *)array[array.count -1];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([topViewController isKindOfClass:[LoginVC class]]) {
        if ([userInfo[@"type"] isEqualToString:@"message"]) {
            [userDefaults setObject:[[NSNumber alloc] initWithBool:YES] forKey:@"IsGotMessage"];
        }
        else if ([userInfo[@"type"] isEqualToString:@"event"]) {
            [userDefaults setObject:[[NSNumber alloc] initWithBool:YES] forKey:@"IsGotEvent"];
        }
        else if ([userInfo[@"type"] isEqualToString:@"car_is_scheduled"]) {
            [userDefaults setObject:[[NSNumber alloc] initWithBool:YES] forKey:@"IsCarScheduled"];
            [userDefaults setObject:userInfo[@"owner_id"] forKey:@"ScheduleOwnerID"];
        }
    }
    else if ([topViewController isKindOfClass:[HomeVC class]]) {
        NSMutableArray *owners = [userDefaults objectForKey:@"CurrentUser"];
        
        if ([userInfo[@"type"] isEqualToString:@"message"]) {
            HomeVC *homeVC = (HomeVC *)topViewController;
            [homeVC gotoPersonalNotifications];
        }
        else if ([userInfo[@"type"] isEqualToString:@"event"]) {
            HomeVC *homeVC = (HomeVC *)topViewController;
            [homeVC gotoEventNotifications];
        }
        else if ([userInfo[@"type"] isEqualToString:@"car_is_scheduled"]) {
            for (int i = 0; i < owners.count; i++) {
                if ([userInfo[@"owner_id"] isEqualToString:owners[i][@"id"]]) {
                    HomeVC *homeVC = (HomeVC *)topViewController;
                    [homeVC gotoCarSelect];
                    
                    break;
                }
            }
        }
    }
    
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"*******************Inactive");
        completionHandler(UIBackgroundFetchResultNewData);
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    else if (application.applicationState == UIApplicationStateBackground) {
        NSLog(@"*******************Backround");
        completionHandler(UIBackgroundFetchResultNewData);
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    else {
        NSLog(@"*******************Activie");
        completionHandler(UIBackgroundFetchResultNewData);
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

@end
