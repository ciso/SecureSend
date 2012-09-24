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
#import "Base64.h"

//sample values
#define SAMPLE_NAME @"Christof Stromberger"
#define SAMPLE_EMAIL @"stromberger@student.tugraz.at"
#define SAMPLE_COUNTRY @"AT"
#define SAMPLE_CITY @"Graz"
#define SAMPLE_ORGANIZATION @"Graz University of Technology"
#define SAMPLE_ORG_UNIT @"IAIK"
#define SAMPLE_CONTAINER @"Hello World! This is an encrypted container!"
#define SAMPLE_CONTAINER_ENCODED @"SGVsbG8gV29ybGQhIFRoaXMgaXMgYW4gZW5jcnlwdGVkIGNvbnRhaW5lciE="


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

- (NSData*)newCertificateWithPrivateKey:(NSData*)privateKey {
    
    return [self.crypto createX509CertificateWithPrivateKey:privateKey withName:SAMPLE_NAME emailAddress:SAMPLE_EMAIL country:SAMPLE_COUNTRY city:SAMPLE_CITY organization:SAMPLE_ORGANIZATION organizationUnit:SAMPLE_ORG_UNIT];}

- (NSData*)newCertificate {
    return [self newCertificateWithPrivateKey:[self newPrivateKey]];
}

//private key creation test
- (void)test001_createNewPrivateKey {
    NSData *privateKey = [self newPrivateKey];
    STAssertNotNil(privateKey, @"checking private key");
}


//certificate creation test case
- (void)test002_createNewCertificate {
    NSData *certificate = [self newCertificate];
    STAssertNotNil(certificate, @"checking certificate");
    
    STAssertEqualObjects([X509CertificateUtil getCommonName:certificate], SAMPLE_NAME, @"checking commong name");
    STAssertEqualObjects([X509CertificateUtil getEmail:certificate], SAMPLE_EMAIL, @"checking email");
    STAssertEqualObjects([X509CertificateUtil getCity:certificate], SAMPLE_CITY, @"checking city");
    STAssertEqualObjects([X509CertificateUtil getOrganization:certificate], SAMPLE_ORGANIZATION, @"checking organization");
    STAssertEqualObjects([X509CertificateUtil getOrganizationUnit:certificate], SAMPLE_ORG_UNIT, @"checking organization unit");
}

//encrypting data using a new certificate
- (void)test003_encryptData {
    NSData *privateKey = [self newPrivateKey];
    NSData *certificate = [self newCertificateWithPrivateKey:privateKey];
    
    STAssertNotNil(privateKey, @"checking private key");
    STAssertNotNil(certificate, @"checking certificate");
    
    NSString *testString = SAMPLE_CONTAINER;
    STAssertNotNil(testString, @"checking test string");
    NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    STAssertNotNil(testData, @"checking test data");
    
    
    NSData *encryptedContainer = [self.crypto encryptBinaryFile:testData withCertificate:certificate];
    STAssertNotNil(encryptedContainer, @"checking container");
    
    NSData *decryptedContainer = [self.crypto decryptBinaryFile:encryptedContainer withUserCertificate:certificate privateKey:privateKey];
    STAssertNotNil(decryptedContainer, @"checking decryption");
    
    NSString *decryptedTestString = [NSString stringWithUTF8String:[decryptedContainer bytes]];
    STAssertNotNil(decryptedTestString, @"checking decrypted test string");
    
    STAssertEqualObjects(decryptedTestString, SAMPLE_CONTAINER, @"checking contents of container");
}


//base64 encode and decode tests
- (void)test004_testBase64Encode {
    NSString *testString = SAMPLE_CONTAINER;
    STAssertNotNil(testString, @"checking test string");
    STAssertEqualObjects([Base64 encodeBase64WithString:testString], SAMPLE_CONTAINER_ENCODED, @"checking base64 encoding");
    
    NSData *testBytes = [testString dataUsingEncoding:NSUTF8StringEncoding];
    STAssertNotNil(testBytes, @"checking test bytes");
    STAssertEqualObjects([Base64 encodeBase64WithData:testBytes], SAMPLE_CONTAINER_ENCODED, @"checking base64 encoding");
}

- (void)test005_testBase64Decoce {
    NSString *testString = SAMPLE_CONTAINER_ENCODED;
    NSString *originalTestString = SAMPLE_CONTAINER;
    NSData *testBytes = [originalTestString dataUsingEncoding:NSUTF8StringEncoding];
    STAssertNotNil(testString, @"checking test string");
    STAssertNotNil(testBytes, @"checking test bytes");
    STAssertEqualObjects([Base64 decodeBase64WithString:testString], testBytes, @"checking base64 decoding");
}

@end
