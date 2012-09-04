//
//  PersistentStore.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 26.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "PersistentStore.h"
#import "UserCertificate.h"
#import "AppDelegate.h"
#import "UserIdentity.h"
#import "UserPrivateKey.h"
#import "Util.h"
#import "KeyChainStore.h"
#import "X509CertificateUtil.h"
#import "Error.h"

//for debug
#import "KeyPair.h"

#define DB_USERCERTIFICATE @"UserCertificate"
#define DB_USERIDENTITY @"UserIdentity"
#define DB_USERPRIVATEKEY @"UserPrivateKey"

@implementation PersistentStore

+ (BOOL)storeForUserCertificate:(NSData*)certificate privateKey:(NSData*)privateKey
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //allocating entities
    NSEntityDescription *identityEntity = [NSEntityDescription entityForName:DB_USERIDENTITY inManagedObjectContext:appDelegate.managedObjectContext];
    UserIdentity *dbIdentity = [[UserIdentity alloc] initWithEntity:identityEntity insertIntoManagedObjectContext:appDelegate.managedObjectContext];
    
    NSEntityDescription *certificateEntity = [NSEntityDescription entityForName:DB_USERCERTIFICATE inManagedObjectContext:appDelegate.managedObjectContext];
    UserCertificate *dbCertificate = [[UserCertificate alloc] initWithEntity:certificateEntity insertIntoManagedObjectContext:appDelegate.managedObjectContext];
    
    NSEntityDescription *privateKeyEntity = [NSEntityDescription entityForName:DB_USERPRIVATEKEY inManagedObjectContext:appDelegate.managedObjectContext];
    UserPrivateKey *dbPrivateKey = [[UserPrivateKey alloc] initWithEntity:privateKeyEntity insertIntoManagedObjectContext:appDelegate.managedObjectContext];
    
    //assuming foreign keys
    dbIdentity.ref_certificate = dbCertificate;
    dbIdentity.ref_private_key = dbPrivateKey;
    dbCertificate.ref_identity = dbIdentity;
    dbPrivateKey.ref_identity = dbIdentity;
    
    //assuming creation date
    dbCertificate.dateCreated = [NSDate date];
    dbPrivateKey.dateCreated = [NSDate date];
    
    //creating access keys
//    NSString *certificateAccessKey = [Util createNewUUID];
    NSString *certificateAccessKey = [X509CertificateUtil getSerialNumber:certificate];
    NSString *privateKeyAccessKey = [Util createNewUUID];
    
    //assuming access keys
    dbCertificate.accessKey = certificateAccessKey;
    dbPrivateKey.accessKey = privateKeyAccessKey;
        
    BOOL success = [KeyChainStore setData:certificate forKey:certificateAccessKey type:kDataTypeCertificate];
    //success = [KeyChainStore setData:certificate forKey:privateKeyAccessKey type:kDataTypeCertificate];

    if (success)
    {
        success = [KeyChainStore setData:privateKey forKey:privateKeyAccessKey type:kDataTypePrivateKey];
    }

    NSLog(@"Success: %d", success);
    if (success)
    {
        [appDelegate saveContext];
    }
    else
    {
        [appDelegate.managedObjectContext rollback];
    }
    
    return YES;
}


//todo: test this!!!
+ (NSData*)getActiveCertificateOfUser
{
    NSData *ret = nil;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //fetching entries from core data
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserCertificate"];
    NSSortDescriptor *sortById = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortById, nil];
    [request setSortDescriptors:sortDescriptors];
    request.fetchLimit = 1;
    
    //fetchiing identities
    NSArray *allIdentities = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        [Error log:error];
    }
    
    if ([allIdentities count] > 0)
    {
        UserCertificate *certificate = [allIdentities objectAtIndex:0];
    
        NSData *certData = [KeyChainStore dataForKey:certificate.accessKey type:kDataTypeCertificate];
        ret = certData;
    }
    
    return ret;
}

//todo: test this!!!
+ (NSData*)getActivePrivateKeyOfUser
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //fetching entries from core data
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserCertificate"];
    NSSortDescriptor *sortById = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortById, nil];
    [request setSortDescriptors:sortDescriptors];
    request.fetchLimit = 1;
    
    //fetchiing identities
    NSArray *allIdentities = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        [Error log:error];
    }
    
    UserCertificate *certificate = [allIdentities objectAtIndex:0];
    UserIdentity *identity = certificate.ref_identity;
    UserPrivateKey *privateKey = identity.ref_private_key;
    
    NSData *certData = [KeyChainStore dataForKey:privateKey.accessKey type:kDataTypePrivateKey];
    
    return certData;
}

#pragma mark - DEBUG
+ (NSArray*)getAllKeyPairsOfUser
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //fetching entries from core data
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserCertificate"];
    NSSortDescriptor *sortById = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortById, nil];
    [request setSortDescriptors:sortDescriptors];
    
    //fetchiing identities
    NSArray *allIdentities = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        [Error log:error];
    }
    
    for (UserCertificate *certificate in allIdentities)
    {
        UserIdentity *identity = certificate.ref_identity;
        UserPrivateKey *privateKey = identity.ref_private_key;
        
        NSData *certData = [KeyChainStore dataForKey:certificate.accessKey type:kDataTypeCertificate];
        NSData *privateKeyData = [KeyChainStore dataForKey:privateKey.accessKey type:kDataTypePrivateKey];
        
        KeyPair *pair = [[KeyPair alloc] initWithCertificate:certData privateKey:privateKeyData];
        pair.certificateDateCreated = certificate.dateCreated;
        pair.privateKeyDateCreated = privateKey.dateCreated;
        
        [ret addObject:pair];
    }
    
    return ret;
}



@end
