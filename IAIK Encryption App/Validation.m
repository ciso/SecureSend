//
//  Validation.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Validation.h"

#define DEFAULT_EMAIL @"max@mustermann.at"
#define DEFAULT_PHONE @"06641234567"

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
    if (phone == nil
        || [phone isEqualToString:@""]
        || [phone isEqualToString:DEFAULT_PHONE])
        {
            return NO;
        }
        
    return YES;
}

@end
