//
//  Setting.h
//  P'0001
//
//  Created by Daniel Liu on 7/27/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"

@interface Setting : NSObject

@property (assign, nonatomic) BOOL isEnglish;
@property (assign, nonatomic) BOOL isSpanish;
@property (assign, nonatomic) BOOL isGerman;
@property (assign, nonatomic) BOOL isItalian;

+ (Setting *)sharedInstance;
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end