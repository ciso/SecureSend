//
//  TextProvider.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "TextProvider.h"

@interface TextProvider()

+ (NSString*)getUserName;

@end

@implementation TextProvider

+ (NSString*)getEmailBodyForRecipient:(NSString*)recipient
{
    NSMutableString *body = [[NSMutableString alloc] init];
    [body appendFormat:NSLocalizedString(@"Dear %@!\n\n", nil), recipient];
    
    [body appendFormat:NSLocalizedString(@"You have received a certificate request from %@.\n", nil), [TextProvider getUserName]];
    [body appendFormat:NSLocalizedString(@"This request can be opened by the %@ app and sends your certificate back to the requester.", nil), @"SecureSend"];
    
    return  body;
}

+ (NSString*)getEmailSubject
{
    NSMutableString *subject = [[NSMutableString alloc] init];
    
    [subject appendFormat:NSLocalizedString(@"Certificate request from %@", nil), [TextProvider getUserName]];
    
    return subject;
}


+ (NSString*)getUserName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *email = [defaults objectForKey:@"default_email"];
    NSString *forename = [defaults objectForKey:@"default_forename"];
    NSString *surname = [defaults objectForKey:@"default_surname"];
    
    NSMutableString *name = [[NSMutableString alloc] init];
    if (forename != nil && ![forename isEqualToString:@""])
    {
        [name appendString:forename];
    }
    
    if (surname != nil && ![surname isEqualToString:@""])
    {
        if ([name length] > 0)
        {
            [name appendString:@" "];
        }
        [name appendString:surname];
    }
    
    if ([name length] == 0)
    {
        [name appendString:email];
    }
    
    return name;
}


@end
