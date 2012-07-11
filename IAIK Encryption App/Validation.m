//
//  Validation.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Validation.h"

#define DEFAULT_EMAIL @"max@mustermann.at"
#define DEFAULT_PHONE @"06641234567890"

@implementation Validation

+ (BOOL)emailIsValid:(NSString*)email
{
    if (email == nil 
        || [email isEqualToString:@""]
        || [email isEqualToString:DEFAULT_EMAIL])
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
    
    //regex check
   /* NSString *phoneRegex = @"[235689][0-9]{6}([0-9]{3})?"; 
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex]; 
    BOOL matches = [test evaluateWithObject:phone];
    if (!matches)
    {
        return NO;
    }*/
    
//    NSRange range = NSMakeRange (0, [phone length]);    
//    NSTextCheckingResult *match = [NSTextCheckingResult phoneNumberCheckingResultWithRange:range phoneNumber:phone];
//    if ([match resultType] == NSTextCheckingTypePhoneNumber)
//    {
//        return YES;
//    }
//    else {
//        return NO;
//    }
    
    
    
    return YES;
}

@end
