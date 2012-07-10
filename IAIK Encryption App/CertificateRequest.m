//
//  CertificateRequest.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 10.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CertificateRequest.h"

@implementation CertificateRequest

@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize emailAddress = _emailAddress;

- (void)dealloc
{
    self.firstName = nil;
    self.lastName = nil;
    self.emailAddress = nil;
}

- (NSString*) toXML
{
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    [ret appendString:@"<CertificateRequest>"];
    [ret appendFormat:@"<date>%@</date>", [NSDate date]];
    [ret appendFormat:@"<firstName>%@</firstName>", self.firstName];
    [ret appendFormat:@"<lastName>%@</lastName>", self.lastName];
    [ret appendFormat:@"<emailAddress>%@</emailAddress>", self.emailAddress];    
    [ret appendString:@"</CertificateRequest>"];
    
    return ret;
}

@end
