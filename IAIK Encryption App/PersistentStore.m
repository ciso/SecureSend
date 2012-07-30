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
#import "KeyChainManager.h"
#import "UserIdentity.h"
#import "UserPrivateKey.h"
#import "Util.h"
#import "KeyChainStore.h"
#import "X509CertificateUtil.h"

#define DB_USERCERTIFICATE @"UserCertificate"
#define DB_USERIDENTITY @"UserIdentity"
#define DB_USERPRIVATEKEY @"UserPrivateKey"

@implementation PersistentStore

+ (NSString*)storeNewCertificate:(NSString*)name
{
    //check if certificate belongs to iPhone user
    if ([name isEqualToString:CERT_ID_USER])
    {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:DB_USERCERTIFICATE inManagedObjectContext:appDelegate.managedObjectContext];
        UserCertificate *dbCertificate = [[UserCertificate alloc] initWithEntity:entity insertIntoManagedObjectContext:appDelegate.managedObjectContext];
        
        //creating new UUID for key/value keychain store
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuidString = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
        CFRelease(uuid);
        
        dbCertificate.accessKey = uuidString;
        dbCertificate.dateCreated = [NSDate date];
        
        //storing into db
        NSError *error;
        
        [appDelegate saveContext];
        //[appDelegate.managedObjectContext save:&error];
        if (error)
        {
            NSLog(@"An Error occured: %@", [error localizedDescription]);
        }
        
        return uuidString;
    }
    else
    {
        return name; //nothing changed
    } 
}

+ (NSString*)getKeyForCertificateUser
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:DB_USERCERTIFICATE];
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByDate, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    fetchRequest.fetchLimit = 1;
    
    NSError *error;
    NSArray *fetchedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        NSLog(@"An error occured: %@", [error localizedDescription]);
    }
    
    NSLog(@"Items found: %d", [fetchedObjects count]);
    
    if ([fetchedObjects count] > 0)
    {
        UserCertificate *dbCertificate = [fetchedObjects objectAtIndex:0];
        return dbCertificate.accessKey;
    }
    else
    {
        return @"";
    }

}

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

@end
