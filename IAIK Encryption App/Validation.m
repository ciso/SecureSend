//
//  Validation.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Validation.h"
#import "Error.h"

#define DEFAULT_EMAIL @"max@mustermann.at"
#define DEFAULT_PHONE @"06641234567890"

@implementation Validation

+ (BOOL)emailIsValid:(NSString*)email
{
    //basic email check
    if (email == nil 
        || [email isEqualToString:@""]
        || [email isEqualToString:DEFAULT_EMAIL])
    {
        return NO;
    }
    
    //regex email check
    NSString* pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    if ([predicate evaluateWithObject:email] == YES) 
    {
        return YES;
    } 
    else 
    {
        return NO;
    }
    
    return YES;
}

+ (BOOL)phoneNumberIsValid:(NSString*)phone
{
    //basic checks
    if (phone == nil
        || [phone isEqualToString:@""]
        || [phone isEqualToString:DEFAULT_PHONE])
        {
            return NO;
        }
    
    //complex phone number check
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
    
    if (error) {
        [Error log:error];
    }
    
    NSRange inputRange = NSMakeRange(0, [phone length]);
    NSArray *matches = [detector matchesInString:phone options:0 range:inputRange];
    
    // no match at all
    if ([matches count] == 0) {
        return NO;
    }
    
    // found match but we need to check if it matched the whole string
    NSTextCheckingResult *result = (NSTextCheckingResult *)[matches objectAtIndex:0];
    
    if ([result resultType] == NSTextCheckingTypePhoneNumber && result.range.location == inputRange.location && result.range.length == inputRange.length) {
        // it matched the whole string
        return YES;
    }
    else {
        // it only matched partial string
        return NO;
    }
    
    
    return YES;
}

@end
