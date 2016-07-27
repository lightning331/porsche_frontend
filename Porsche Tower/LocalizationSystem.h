//
//  LocalizationSystem.h
//  P'0001
//
//  Created by Daniel Liu on 7/27/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//
#import <Foundation/Foundation.h>

#define NSLocalizedString(key, comment) \
[[LocalizationSystem sharedLocalSystem] localizedStringForKey:(key) value:(comment)]


#define LocalizationSetLanguage(language) \
[[LocalizationSystem sharedLocalSystem] setLanguage:(language)]

#define LocalizationGetLanguage \
[[LocalizationSystem sharedLocalSystem] getLanguage]

#define LocalizationReset \
[[LocalizationSystem sharedLocalSystem] resetLocalization]

@interface LocalizationSystem : NSObject {
    
}

@property (strong, nonatomic) NSString *language;

// you really shouldn't care about this functions and use the MACROS
+ (LocalizationSystem *)sharedLocalSystem;

//gets the string localized
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment;

//sets the language
- (void) setLanguage:(NSString*) language;

//gets the current language
- (NSString*) getLanguage;

//resets this system.
- (void) resetLocalization;

@end