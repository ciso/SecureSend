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
    
    [ret appendString:@"<?xml version=\"1.0\"?>\n"];
    [ret appendString:@"<CertificateRequest xmlns=\"http://iaik.tugraz.at/SecureSend\">\n"];
    [ret appendFormat:@"<date>%@</date>\n", self.date];
    [ret appendFormat:@"<emailAddress>%@</emailAddress>\n", self.emailAddress];   
    [ret appendFormat:@"<phoneNumber>%@</phoneNumber>\n", self.phoneNumber];    
    [ret appendString:@"</CertificateRequest>\n"];
    
    return ret;
}

#pragma mark - dealloc
- (void)dealloc
{
    self.emailAddress = nil;
}

@end
