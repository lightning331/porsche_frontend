//
//  Utility.m
//  P'0001
//
//  Created by Daniel Liu on 7/25/16.
//  Copyright © 2016 Daniel Liu. All rights reserved.
//

#import "Utility.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Utility

+ (NSString *)createEditableCopyOfFileIfNeeded:(NSString *)filename
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableFilePath = [documentsDirectory stringByAppendingPathComponent: filename ];
    
    success = [fileManager fileExistsAtPath:writableFilePath];
    if (success) return writableFilePath;
    
    // The writable file does not exist, so copy the default to the appropriate location.
    NSString *defaultFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: filename ];
    success = [fileManager copyItemAtPath:defaultFilePath toPath:writableFilePath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
    
    return writableFilePath;
}

+ (NSString *)getDocumentsDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

+ (NSString *) getDBPath
{
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    //NSLog(@"dbpath : %@",documentsDir);
    return [documentsDir stringByAppendingPathComponent:@"location.sqlite"];
}

+ (NSString *)getDocumentsSubDir:(NSString*)subDirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *projectsDir = [Utility getDocumentsDir];
    NSString *newDir = [projectsDir stringByAppendingPathComponent:subDirName];
    
    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:newDir isDirectory:&isDir] || !isDir) {
        [fileManager createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return newDir;
}


+(NSString*) genUUID;
{
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    NSString *guid = (__bridge NSString *)newUniqueIDString;
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    return([guid lowercaseString]);
}

+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(BOOL) isArabicUser{
    
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    countryCode = [countryCode lowercaseString];
    if ([countryCode isEqualToString:@"ar"]) {
        return YES;
    }
    
    return NO;
}
+(NSDictionary *)getUserInformation{
    
    NSString *url = [NSString stringWithFormat:@"http://ip-api.com/json"];
    
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]] //1
                          
                          options:kNilOptions
                          error:&error];
    
    
    return json;
    
}

#pragma mark Ip- address Fectch & Location

+(NSString *)getExternalIPAddress{
    
    NSString *externalIP = @"";
    NSURL *iPURL = [NSURL URLWithString:@"http://www.dyndns.org/cgi-bin/check_ip.cgi"];
    if (iPURL) {
        NSError *error = nil;
        NSString *theIpHtml = [NSString stringWithContentsOfURL:iPURL
                                                       encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
            NSScanner *theScanner;
            NSString *text = nil;
            theScanner = [NSScanner scannerWithString:theIpHtml];
            while ([theScanner isAtEnd] == NO) {
                // find start of tag
                [theScanner scanUpToString:@"<" intoString:NULL] ;
                // find end of tag
                [theScanner scanUpToString:@">" intoString:&text] ;
                // replace the found tag with a space
                //(you can filter multi-spaces out later if you wish)
                theIpHtml = [theIpHtml stringByReplacingOccurrencesOfString:
                             [NSString stringWithFormat:@"%@>", text] withString:@" "] ;
                NSArray *ipItemsArray = [theIpHtml componentsSeparatedByString:@" "];
                NSInteger an_Integer=[ipItemsArray indexOfObject:@"Address:"];
                externalIP =[ipItemsArray objectAtIndex: ++an_Integer];
            }
            NSLog(@"%@",externalIP);
        } else {
            NSLog(@"Oops... g %ld, %@",
                  (long)[error code],
                  [error localizedDescription]);
        }
    }
    return externalIP;
}
@end
