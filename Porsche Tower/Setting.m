//
//  Setting.m
//  P'0001
//
//  Created by Daniel Liu on 7/27/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import "Setting.h"
#import "Utility.h"

@implementation Setting

- (id)init{
    
    if (self = [super init]) {
        
        self.isEnglish = [Utility isEnglishUser]?YES:NO;
        self.isGerman = [Utility isGermanUser]?YES:NO;
        self.isSpanish = [Utility isSpanishUser]?YES:NO;
        self.isItalian = [Utility isItalianUser]?YES:NO;
    }
    return self;
}


static Setting *sharedInstance = nil;
+ (Setting *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil) {
            sharedInstance = [[Setting alloc] init];
        }
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if(self) {
        
        self.isEnglish = [decoder decodeBoolForKey:LANGUAGE];
        self.isGerman = [decoder decodeBoolForKey:LANGUAGE];
        self.isSpanish = [decoder decodeBoolForKey:LANGUAGE];
        self.isItalian = [decoder decodeBoolForKey:LANGUAGE];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeBool:self.isEnglish forKey:LANGUAGE];
    [encoder encodeBool:self.isGerman forKey:LANGUAGE];
    [encoder encodeBool:self.isSpanish forKey:LANGUAGE];
    [encoder encodeBool:self.isItalian forKey:LANGUAGE];
}

@end
