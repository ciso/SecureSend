//
//  KeyChainStore.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 26.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "KeyChainStore.h"
#import "Base64.h"
#import "X509CertificateUtil.h"

//just temp
#import "Crypto.h"

@implementation KeyChainStore



/*
errSecSuccess                = 0,       * No error. *
errSecUnimplemented          = -4,      * Function or operation not implemented. *
errSecParam                  = -50,     * One or more parameters passed to a function where not valid. *
errSecAllocate               = -108,    * Failed to allocate memory. *
errSecNotAvailable           = -25291,	* No keychain is available. You may need to restart your computer. *
errSecDuplicateItem          = -25299,	* The specified item already exists in the keychain. *
errSecItemNotFound           = -25300,	* The specified item could not be found in the keychain. *
errSecInteractionNotAllowed  = -25308,	* User interaction is not allowed. *
errSecDecode                 = -26275,  * Unable to decode the provided data. *
errSecAuthFailed             = -25293,	* The user name or passphrase you entered is not correct. *
 */

+ (BOOL)removeItemForKey:(NSString*)key type:(KeyChainDataType)type
{
    BOOL ret = YES;
    if (type == kDataTypeCertificate)
    {
        //SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, (CFDataRef)data);
        
        NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
        [query setObject:(id)kSecClassCertificate forKey:kSecClass];
        [query setObject:(id)key forKey:(id)kSecAttrLabel];
        [query setObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
        //[query setObject:(id)cert forKey:(id)kSecValueRef];
        //[query setObject:(id)key forKey:(id)kSecAttrSerialNumber];
        
        //CFTypeRef certificateRef = NULL;
        
        OSStatus status = SecItemDelete((CFDictionaryRef) query);
        
        if(status)
        {
            NSLog(@"Keychain error occured: %ld (statuscode)", status);
            ret = NO;
        }
    }
    else if (type == kDataTypePrivateKey)
    {
        
        NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
        [query setObject:(id)kSecClassKey forKey:(id)kSecClass];
        [query setObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
        [query setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnData];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnRef];
        
        //adding access key
        [query setObject:(id)key forKey:(id)kSecAttrApplicationTag];
        
        OSStatus error = SecItemDelete((CFDictionaryRef)query);
        if(error != 0)
        {
            NSLog(@"OSStatus error: %ld", error);
            ret = NO;
        }
    }
    
    return ret;
}

+ (NSData*)dataForKey:(NSString*)key type:(KeyChainDataType)type
{
    NSData *ret = nil;
    
    if (type == kDataTypeCertificate)
    {
        NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
        [query setObject:kSecClassCertificate forKey:kSecClass];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnRef];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
        
        //test
        [query setObject:(id)kSecMatchLimitAll forKey:(id)kSecMatchLimit];
        
        //todo: add key
        //[query setObject:(id)key forKey:(id)kSecAttrLabel];
        [query setObject:(id)key forKey:kSecAttrLabel];
        
        NSArray *keychainItems = nil;
        OSStatus error = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&keychainItems);
        if(error != 0)
        {
            NSLog(@"OSStatus error: %ld", error);
            return nil;
        }
        
        
        if (keychainItems == nil || [keychainItems count] < 1 || [keychainItems count] > 1)
        {
            NSLog(@"Found %d items in keychain. Should be 1.", [keychainItems count]);
            return nil;
        }
        else if ([keychainItems count] == 1)
        {
            NSDictionary *certDict = [keychainItems objectAtIndex:0];
            NSData *cert = [certDict objectForKey:(id)kSecValueData];
            Crypto *crypto = [Crypto getInstance];
            NSDate *expirationDate = [crypto getExpirationDateOfCertificate:cert];
            NSLog(@"expires on...: %@", expirationDate);
            
            //valid
            for (NSDictionary *dict in keychainItems)
            {
                SecCertificateRef certificate = (SecCertificateRef)[dict objectForKey:(id)kSecValueRef];
                
                CFStringRef summary;
                summary = SecCertificateCopySubjectSummary(certificate);
                NSLog(@"Certificate\n");
                NSLog(@"-----------\n");
                NSLog(@"Summary: %@\n", (NSString *)summary);
                CFRelease(summary);
                NSLog(@"Entitlement Group: %@\n", [dict objectForKey:(id)kSecAttrAccessGroup]);
                NSLog(@"Label: %@\n", [dict objectForKey:(id)kSecAttrLabel]);
                NSLog(@"Serial Number: %@\n", [dict objectForKey:(id)kSecAttrSerialNumber]);
                NSLog(@"Subject Key ID: %@\n", [dict objectForKey:(id)kSecAttrSubjectKeyID]);
                NSLog(@"Subject Key Hash: %@\n\n", [dict objectForKey:(id)kSecAttrPublicKeyHash]);
            }
            
            ret = cert; //assuming cert as return value
        }
    }
    else if (type == kDataTypePrivateKey)
    {
        NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
        [query setObject:(id)kSecClassKey forKey:(id)kSecClass];
        [query setObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
        [query setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnData];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnRef];
        
        //adding access key
        [query setObject:(id)key forKey:(id)kSecAttrApplicationTag];
        
        NSDictionary *keychainItems = nil;
        OSStatus error = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&keychainItems);
        if(error != 0)
        {
            NSLog(@"OSStatus error: %ld", error);
            return nil;
        }
        
        
        if (keychainItems == nil)
        {
            NSLog(@"Found %d items in keychain. Should be 1.", [keychainItems count]);
            return nil;
        }
        else //found
        {
            NSData *privateKey = [keychainItems objectForKey:(id)kSecValueData];
           
            ret = privateKey; //assuming cert as return value
        }

    }
    
    return ret;
}

+ (BOOL)setData:(NSData*)data forKey:(NSString*)key type:(KeyChainDataType)type
{
    
//    NSLog(@"%@", [Base64 encode:data]);
//    NSLog(@"------------------------------------------------------------");
//    
    if (type == kDataTypeCertificate)
    {
        SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, (CFDataRef)data);
        
        NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
        [query setObject:(id)kSecClassCertificate forKey:kSecClass];
        [query setObject:(id)key forKey:(id)kSecAttrLabel];
        [query setObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
        //[query setObject:(id)key forKey:(id)kSecAttrSerialNumber];
        
        //CFTypeRef certificateRef = NULL;
        
        OSStatus status = SecItemDelete((CFDictionaryRef) query);
        
        if(status != 0 && status != errSecItemNotFound)
        {
            NSLog(@"Keychain error occured: %ld (statuscode)", status);
            
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"error: %@", [error localizedDescription]);
            
            return NO;
        }
        
        [query setObject:(id)cert forKey:(id)kSecValueRef];

        
        status = SecItemAdd(( CFDictionaryRef) query, NULL);
        
        if(status)
        {
            NSLog(@"Keychain error occured: %ld (statuscode)", status);
            
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"error: %@", [error localizedDescription]);
            
            return NO;
        }
        
        return YES;
        
    }
    else if (type == kDataTypePrivateKey)
    {
        NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
        [query setObject:(id)kSecClassKey forKey:(id)kSecClass];
        [query setObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
        [query setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnData];
        
        //adding access key
        [query setObject:(id)key forKey:(id)kSecAttrApplicationTag];
        
        //removing item if it exists
        SecItemDelete((CFDictionaryRef)query);
        
        
        //setting data (private key)
        [query setObject:(id)data forKey:(id)kSecValueData];
        
        CFTypeRef persistKey;
        OSStatus status = SecItemAdd((CFDictionaryRef)query, &persistKey);

        if(status)
        {
            NSLog(@"Keychain error occured: %ld (statuscode)", status);
            return NO;
        }
    }
    
    return YES;
}

+ (NSMutableDictionary*)createQueryForKey:(NSString*)key withType:(KeyChainDataType)type
{
    CFStringRef labelString = CFStringCreateWithCString(NULL, [key cStringUsingEncoding:NSUTF8StringEncoding], kCFStringEncodingUTF8);
    
    NSArray *keys = [NSArray arrayWithObjects:( id)kSecClass, kSecAttrLabel, kSecReturnData, kSecAttrAccessible, nil];
    NSArray *values = nil;
    if (type == kDataTypeCertificate)
    {
        values = [NSArray arrayWithObjects:( id)kSecClassCertificate, labelString, kCFBooleanTrue, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, nil];
    }
    else if (type == kDataTypePrivateKey)
    {
        values = [NSArray arrayWithObjects:( id)kSecClassKey, labelString, kCFBooleanTrue, kSecAttrAccessibleWhenUnlocked, nil];
    }
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    
    CFRelease(labelString);
    
    return query;
}

@end
