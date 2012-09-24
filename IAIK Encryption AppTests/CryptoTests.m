//
//  CryptoTests.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 24.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CryptoTests.h"
#import "Crypto.h"
#import "X509CertificateUtil.h"

//sample values
#define SAMPLE_NAME @"Christof Stromberger"
#define SAMPLE_EMAIL @"stromberger@student.tugraz.at"
#define SAMPLE_COUNTRY @"AT"
#define SAMPLE_CITY @"Graz"
#define SAMPLE_ORGANIZATION @"Graz University of Technology"
#define SAMPLE_ORG_UNIT @"IAIK"


@interface CryptoTests()

@property (nonatomic, strong) Crypto *crypto;

@end

@implementation CryptoTests

- (void)setUp
{
    [super setUp];
    
    self.crypto = [Crypto getInstance];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (NSData*)newPrivateKey {
    return [self.crypto createRSAKey];
}
- (NSData*)newCertificate {
    
    return [self.crypto createX509CertificateWithPrivateKey:[self newPrivateKey] withName:SAMPLE_NAME emailAddress:SAMPLE_EMAIL country:SAMPLE_COUNTRY city:SAMPLE_CITY organization:SAMPLE_ORGANIZATION organizationUnit:SAMPLE_ORG_UNIT];
}

//private key creation test
- (void)test001_createNewPrivateKey {
    NSData *privateKey = [self newPrivateKey];
    STAssertNotNil(privateKey, @"checking private key");
}


- (void)test002_createNewCertificate {
    NSData *certificate = [self newCertificate];
    STAssertNotNil(certificate, @"checking certificate");
    
    STAssertEqualObjects([X509CertificateUtil getCommonName:certificate], SAMPLE_NAME, @"checking commong name");
    STAssertEqualObjects([X509CertificateUtil getEmail:certificate], SAMPLE_EMAIL, @"checking email");
    STAssertEqualObjects([X509CertificateUtil getCity:certificate], SAMPLE_CITY, @"checking city");
    STAssertEqualObjects([X509CertificateUtil getOrganization:certificate], SAMPLE_ORGANIZATION, @"checking organization");
    STAssertEqualObjects([X509CertificateUtil getOrganizationUnit:certificate], SAMPLE_ORG_UNIT, @"checking organization unit");
    
    
    
}

@end
