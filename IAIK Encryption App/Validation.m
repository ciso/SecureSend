//
//  Validation.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Validation.h"

#define DEFAULT_EMAIL @"max@mustermann.at"

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


@end
