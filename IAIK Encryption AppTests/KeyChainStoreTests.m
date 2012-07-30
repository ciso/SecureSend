//
//  KeyChainStoreTests.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 27.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "KeyChainStoreTests.h"
#import "KeyChainStore.h"
#import "Util.h"
#import "Crypto.h"
#import "X509CertificateUtil.h"
#import "PersistentStore.h"
#import "AppDelegate.h"
#import "UserIdentity.h"
#import "UserCertificate.h"
#import "UserPrivateKey.h"

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
    NSString *accessKey = [X509CertificateUtil getSerialNumber:cert]; //[Util createNewUUID];
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


- (void)test002_storeTestEntryPersistent
{
    NSString *tempCertificateAccessKey = @"";
    Crypto *crypto = [Crypto getInstance];
    NSData *key = [crypto createRSAKeyWithKeyLength:2048];
    NSData* cert = [crypto createX509CertificateWithPrivateKey:key
                                                      withName:@"Max Mustermann"
                                                  emailAddress:@"max@mustermann.at"
                                                       country:@"AT"
                                                          city:@"Graz"
                                                  organization:@"Graz University of Technology"
                                              organizationUnit:@"IAIK"];

    //storing certificate into keychain and references into core data
    [PersistentStore storeForUserCertificate:cert privateKey:key];
    
    //app delegate
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //fetching entries from core data
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserCertificate"];
    NSSortDescriptor *sortById = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortById, nil];
    [request setSortDescriptors:sortDescriptors];
    request.fetchLimit = 1;
    
    //fetchiing identities
    NSArray *allIdentities = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    UserCertificate *certificate = [allIdentities objectAtIndex:0];
    tempCertificateAccessKey = certificate.accessKey;
    
    UserIdentity *identity = certificate.ref_identity;
    UserPrivateKey *privateKey = identity.ref_private_key;
    
    STAssertNotNil(certificate, @"Check core data manged object");
    STAssertNotNil(identity, @"Check core data manged object");
    STAssertNotNil(privateKey, @"Check core data manged object");
    
    NSLog(@"Certificate access key: %@", certificate.accessKey);
    NSLog(@"Certificate created: %@", certificate.dateCreated);
    NSLog(@"PrivateKey access key: %@", privateKey.accessKey);
    NSLog(@"PrivateKey created: %@", privateKey.dateCreated);
    
    //checking if access key in DB is valid
    STAssertTrue([certificate.accessKey isEqualToString:[X509CertificateUtil getSerialNumber:cert]], @"Checking if access key is valid and equal");
    
    
    //CERTIFICATE
    //------------------------------------------------------------------
    //retrieving cert from keychain
    NSData *item = [KeyChainStore dataForKey:certificate.accessKey type:kDataTypeCertificate];
    
    //check if cert is valid and equal
    STAssertNotNil(item, @"Checking if an item was found");
    STAssertTrue([cert isEqualToData:item], @"Checking if it is the same certificate");
    
    //now delete it again
    BOOL success = [KeyChainStore removeItemForKey:certificate.accessKey type:kDataTypeCertificate];
    STAssertTrue(success, @"Checking if deletion succeeded");
    
    
    //checking if cert is still there
    NSData *item2 = [KeyChainStore dataForKey:certificate.accessKey type:kDataTypeCertificate];
    
    //check if cert is valid and equal
    STAssertNil(item2, @"Checking if an item was found");

    
    //PRIVATE KEY
    //------------------------------------------------------------------
    //retrieving key from keychain
    NSData *keyItem = [KeyChainStore dataForKey:privateKey.accessKey type:kDataTypePrivateKey];
    
    //check if key is valid and equal
    STAssertNotNil(keyItem, @"Checking if an item was found");
    STAssertTrue([key isEqualToData:keyItem], @"Checking if it is the same key");
    
    //now delete it again
    BOOL keySuccess = [KeyChainStore removeItemForKey:privateKey.accessKey type:kDataTypePrivateKey];
    STAssertTrue(keySuccess, @"Checking if deletion succeeded");
    
    
    //checking if cert is still there
    NSData *keyItem2 = [KeyChainStore dataForKey:privateKey.accessKey type:kDataTypePrivateKey];
    
    //check if cert is valid and equal
    STAssertNil(keyItem2, @"Checking if an item was found");
    
    
    //REMOVE FROM CORE DATA
    //------------------------------------------------------------------
    //remove it from core data
    [appDelegate.managedObjectContext deleteObject:certificate];
    [appDelegate.managedObjectContext deleteObject:privateKey];
    [appDelegate.managedObjectContext deleteObject:identity];
    
    //saving context
    [appDelegate saveContext];
    
    
    //VERIFY CORE DATA
    //------------------------------------------------------------------
    NSError *error2;
    NSFetchRequest *request2 = [[NSFetchRequest alloc] initWithEntityName:@"UserCertificate"];
    [request2 setPredicate:[NSPredicate predicateWithFormat:@"accessKey == %@", tempCertificateAccessKey]];
    request2.fetchLimit = 1;
    
    //fetchiing identities
    NSArray *allIdentities2 = [appDelegate.managedObjectContext executeFetchRequest:request2 error:&error2];
    STAssertTrue([allIdentities2 count] == 0, @"Checking if certificate has been deleted in core data"); 
}


@end
