//
//  KeyChainStoreTests.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 27.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "KeyChainStoreTests.h"
#import "KeyChainStore.h"
#import "Util.h"
#import "Crypto.h"

@implementation KeyChainStoreTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)test001_storeTestEntryIntoKeyChain
{
    //NSString *tempString = @"Hello World!";
    //NSData *tempData = [tempString dataUsingEncoding:NSUTF8StringEncoding];
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    NSData *tempData = [NSData dataWithContentsOfFile:[bundle pathForResource:@"client" ofType:@"der"]];
    
    Crypto *crypto = [Crypto getInstance];
    NSData *key = [crypto createRSAKeyWithKeyLength:2048];
    NSData* cert = [crypto createX509CertificateWithPrivateKey:key
                                                      withName:@"Max Mustermann"
                                                  emailAddress:@"max@mustermann.at"
                                                       country:@"AT"
                                                          city:@"Graz"
                                                  organization:@"Graz University of Technology"
                                              organizationUnit:@"IAIK"];
    
    //creating new temp access key
    NSString *accessKey = [Util createNewUUID];
    NSString *keyAccessKey = [Util createNewUUID];
    
    //CERTIFICATE TEST
    // -----------------------------------------------------------------------
    //storing cert info keychain
    [KeyChainStore setData:cert forKey:accessKey type:kDataTypeCertificate];
    
    //retrieving cert from keychain
    NSData *item = [KeyChainStore dataForKey:accessKey type:kDataTypeCertificate];
    
    //check if cert is valid and equal
    STAssertNotNil(item, @"Checking if an item was found");
    STAssertTrue([cert isEqualToData:item], @"Checking if it is the same certificate");
    
    //now delete it again
    BOOL success = [KeyChainStore removeItemForKey:accessKey type:kDataTypeCertificate];
    STAssertTrue(success, @"Checking if deletion succeeded");
    
    
    //checking if cert is still there
    NSData *item2 = [KeyChainStore dataForKey:accessKey type:kDataTypeCertificate];
    
    //check if cert is valid and equal
    STAssertNil(item2, @"Checking if an item was found");
    
    
    //PRIVATE KEY TEST
    // -----------------------------------------------------------------------
    //storing key into keychain
    [KeyChainStore setData:key forKey:keyAccessKey type:kDataTypePrivateKey];
    
    //retrieving key from keychain
    NSData *keyItem = [KeyChainStore dataForKey:keyAccessKey type:kDataTypePrivateKey];
    
    //check if key is valid and equal
    STAssertNotNil(keyItem, @"Checking if an item was found");
    STAssertTrue([key isEqualToData:keyItem], @"Checking if it is the same key");
    
    //now delete it again
    BOOL keySuccess = [KeyChainStore removeItemForKey:keyAccessKey type:kDataTypePrivateKey];
    STAssertTrue(keySuccess, @"Checking if deletion succeeded");
    
    
    //checking if cert is still there
    NSData *keyItem2 = [KeyChainStore dataForKey:keyAccessKey type:kDataTypePrivateKey];
    
    //check if cert is valid and equal
    STAssertNil(keyItem2, @"Checking if an item was found");
    

    
}

@end
