//
//  CertificateRequest.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 10.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CertificateRequest.h"

@implementation CertificateRequest

@synthesize date = _date;
@synthesize emailAddress = _emailAddress;
@synthesize phoneNumber = _phoneNumber;

- (NSString*) toXML
{
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    [ret appendString:@"<CertificateRequest>"];
    [ret appendFormat:@"<date>%@</date>", self.date];
    [ret appendFormat:@"<emailAddress>%@</emailAddress>", self.emailAddress];   
    [ret appendFormat:@"<phoneNumber>%@</phoneNumber>", self.phoneNumber];    
    [ret appendString:@"</CertificateRequest>"];
    
    return ret;
}

#pragma mark - dealloc
- (void)dealloc
{
    self.emailAddress = nil;
}

@end
