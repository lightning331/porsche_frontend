//
//  LocalizationSystem.m
//  P'0001
//
//  Created by Daniel Liu on 7/27/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import "LocalizationSystem.h"

@implementation LocalizationSystem

//Singleton instance
static LocalizationSystem *_sharedLocalSystem = nil;

//Current application bungle to get the languages.
static NSBundle *bundle = nil;

+ (LocalizationSystem *)sharedLocalSystem
{
    @synchronized([LocalizationSystem class])
    {
        if (!_sharedLocalSystem){
            _sharedLocalSystem = [[self alloc] init];
        }
        return _sharedLocalSystem;
    }
    // to avoid compiler warning
    return nil;
}

+(id)alloc
{
    @synchronized([LocalizationSystem class])
    {
        NSAssert(_sharedLocalSystem == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedLocalSystem = [super alloc];
        return _sharedLocalSystem;
    }
    // to avoid compiler warning
    return nil;
}


- (id)init
{
    if ((self = [super init]))
    {
        //empty.
        bundle = [NSBundle mainBundle];
    }
    return self;
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment
{
    
    return [bundle localizedStringForKey:key value:comment table:nil];
}


- (void) setLanguage:(NSString*) l{
    
    _language = l;
    
    // path to this languages bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:l ofType:@"lproj" ];
    if (path == nil) {
        // there is no bundle for that language
        // use main bundle instead
        bundle = [NSBundle mainBundle];
    } else {
        
        // use this bundle as my bundle from now on:
        bundle = [NSBundle bundleWithPath:path];
        
        // to be absolutely shure (this is probably unnecessary):
        if (bundle == nil) {
            bundle = [NSBundle mainBundle];
        }
    }
}


- (NSString*) getLanguage{
    
    return self.language;
}

- (void) resetLocalization
{
    bundle = [NSBundle mainBundle];
}


@end