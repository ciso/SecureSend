//
//  KeyChainStore.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 26.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "KeyChainStore.h"
#import "Base64.h"

@implementation KeyChainStore

+ (BOOL)setData:(NSData*)data forKey:(NSString*)key type:(KeyChainDataType)type
{
    
    NSLog(@"%@", [Base64 encode:data]);
    NSLog(@"------------------------------------------------------------");
    
    if (type == kDataTypeCertificate)
    {
        NSMutableDictionary *query = [self createQueryForKey:key withType:type];
        
        //CFDictionaryRef cfquery = (__bridge_retained CFDictionaryRef)query;
        CFDictionaryRef cfresult = NULL;
        OSStatus status = SecItemCopyMatching((__bridge_retained CFDictionaryRef) query, (CFTypeRef*)&cfresult);
        //CFRelease(cfquery);
        //NSDictionary *result = (__bridge_transfer NSDictionary*)cfresult;
        
        if (status != errSecItemNotFound)
        {
            SecItemDelete((__bridge_retained CFDictionaryRef) query);
        }
        
        
        query = [self createQueryForKey:key withType:type];
        
        
        
        /*
         
         NSMutableDictionary* searchdict = [self createKeySearchDirectory];
         
         CFTypeRef item = NULL;
         OSStatus error = SecItemCopyMatching((__bridge_retained CFDictionaryRef) searchdict, &item);
         
         if(error != errSecItemNotFound)
         {
         SecItemDelete((__bridge_retained CFDictionaryRef) searchdict);
         }
         
         [searchdict setObject:(id)privateKey forKey:(__bridge id)kSecValueData];
         
         OSStatus adderror = SecItemAdd((__bridge_retained CFDictionaryRef) searchdict, &item);
         
         */
        
        
        
        if (type == kDataTypeCertificate)
        {
            SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
            [query setObject:(__bridge id)cert forKey:(__bridge id)kSecValueRef];
        }
        else if (type == kDataTypePrivateKey)
        {
            [query setObject:(id)data forKey:(__bridge id)kSecValueData];
        }
        
        
        // cfquery = (__bridge_retained CFDictionaryRef)query;
        CFTypeRef certificateRef = NULL;
        status = SecItemAdd((__bridge_retained CFDictionaryRef) query, (CFTypeRef*)&certificateRef);
        
        if(status)
        {
            NSLog(@"Keychain error occured: %ld (statuscode)", status);
            return NO;
        }
        
    }
    else if (type == kDataTypePrivateKey)
    {
        //NSMutableDictionary *query = //[self createQueryForKey:key withType:type];
        
//        CFStringRef labelstring = CFStringCreateWithCString(NULL, [key cStringUsingEncoding:NSUTF8StringEncoding], kCFStringEncodingUTF8);
//        
//        NSArray* keys = [NSArray arrayWithObjects:(__bridge id)kSecClass,kSecAttrLabel,kSecReturnData,kSecAttrAccessible,nil];
//        NSArray* values = [NSArray arrayWithObjects:(__bridge id)kSecClassKey,labelstring,kCFBooleanTrue,kSecAttrAccessibleWhenUnlocked,nil];
//        NSMutableDictionary* searchdict = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
//        
//        CFRelease(labelstring);
//        
//        NSMutableDictionary *query = searchdict;
//        
//        
//        CFTypeRef item = NULL;
//        OSStatus error = SecItemCopyMatching((__bridge_retained CFDictionaryRef) query, &item);
//        
//        if (error)
//        {
//            NSLog(@"Error: %ld (statuscode)", error);
//        }
//        
//        if(error != errSecItemNotFound)
//        {
//            SecItemDelete((__bridge_retained CFDictionaryRef) query);
//        }
//
//        
//        //simply remove everything...
//        SecItemDelete((__bridge_retained CFDictionaryRef) query);
//        
//        [query setObject:(id)data forKey:(__bridge id)kSecValueData];
//        
//        OSStatus status = SecItemAdd((__bridge_retained CFDictionaryRef) query, &item);

        NSData *d_tag = [NSData dataWithBytes:[key UTF8String] length:[key length]];
        
        // Delete any old lingering key with the same tag
        NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
        [publicKey setObject:(id) kSecClassKey forKey:(id)kSecClass];
        [publicKey setObject:kSecAttrAccessibleWhenUnlocked forKey:kSecAttrAccessible];
//        [publicKey setObject:(id) kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
        [publicKey setObject:d_tag forKey:(id)kSecAttrApplicationTag];
        [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)
         kSecReturnData];
        SecItemDelete((CFDictionaryRef)publicKey);
        
        NSLog(@"Key: %@", key);
        
        CFTypeRef persistKey = nil;
        
        // Add persistent version of the key to system keychain
        [publicKey setObject:data forKey:(id)kSecValueData];
//        [publicKey setObject:(id) kSecAttrKeyClassPrivate forKey:(id)
//         kSecAttrKeyClass];

        
        OSStatus status = SecItemAdd((CFDictionaryRef)publicKey, &persistKey);
        
        
        if(status)
        {
            NSLog(@"Keychain error occured: %ld (statuscode)", status);
            return NO;
        }
        
        
        
        
        //alright, lets retrieve it again...
        NSMutableDictionary *retrieve = [[NSMutableDictionary alloc] init];
        [retrieve setObject:(id) kSecClassKey forKey:(id)kSecClass];
        [retrieve setObject:kSecAttrAccessibleWhenUnlocked forKey:kSecAttrAccessible];
        [retrieve setObject:d_tag forKey:(id)kSecAttrApplicationTag];
        [retrieve setObject:[NSNumber numberWithBool:YES] forKey:(id)
         kSecReturnData];
        
        
        CFTypeRef item = NULL;
        OSStatus error = SecItemCopyMatching((CFDictionaryRef) retrieve, &item);
        
        if (error)
        {
            NSLog(@"ERROR: %ld", error);
        }
        
        NSLog(@"FROM KEYCHAIN:");
        NSLog(@"%@", [Base64 encode:(NSData*)item]);
        NSLog(@"------------------------------------------------------------");
    }

    
    return YES;
}

+ (NSMutableDictionary*)createQueryForKey:(NSString*)key withType:(KeyChainDataType)type
{
    CFStringRef labelString = CFStringCreateWithCString(NULL, [key cStringUsingEncoding:NSUTF8StringEncoding], kCFStringEncodingUTF8);
    
    NSArray *keys = [NSArray arrayWithObjects:(__bridge id)kSecClass, kSecAttrLabel, kSecReturnData, kSecAttrAccessible, nil];
    NSArray *values = nil;
    if (type == kDataTypeCertificate)
    {
        values = [NSArray arrayWithObjects:(__bridge id)kSecClassCertificate, labelString, kCFBooleanTrue, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, nil];
    }
    else if (type == kDataTypePrivateKey)
    {
        values = [NSArray arrayWithObjects:(__bridge id)kSecClassKey, labelString, kCFBooleanTrue, kSecAttrAccessibleWhenUnlocked, nil];
    }
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    
    CFRelease(labelString);
    
    return query;
}

@end
