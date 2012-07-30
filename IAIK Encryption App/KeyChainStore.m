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
#import "KeyChainManager.h"
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
    NSMutableDictionary* dict = [KeyChainManager createSearchDictionaryForOwner:key];
    
    OSStatus error = SecItemDelete((CFDictionaryRef) dict);
    
    if(error)
    {
        ret = NO;
    }
    
    return ret;
}

+ (NSData*)dataForKey:(NSString*)key type:(KeyChainDataType)type
{
    NSData *ret = nil;
    
    if (type == kDataTypeCertificate)
    {
//        NSMutableDictionary* dict = [KeyChainManager createSearchDictionaryForOwner:key];
//        
//        CFTypeRef item = NULL;
//        OSStatus error = SecItemCopyMatching((CFDictionaryRef)dict, &item);
//        
//        if(error != 0)
//        {
//            NSLog(@"Certificat not found in keychain!!");
//            return nil;
//        }
//        
//        NSData* resultdict = (NSData*) item;
//        ret = resultdict;
        
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        [dict setObject:kSecClassCertificate forKey:kSecClass];
//        //[dict setObject:@"AA2CF1E6C4C5017B" forKey:kSecAttrSerialNumber];
//        
//        CFTypeRef item = NULL;
//        OSStatus error = SecItemCopyMatching((CFDictionaryRef)dict, &item);
//        
//        if(error != 0)
//        {
//            NSLog(@"OSStatus error: %ld", error);
//            return nil;
//        }
//        NSArray* resultdict = (NSArray*) item;
//        
//        NSLog(@"array: %@", resultdict);
        
        //ret = resultdict;
        //NSString *byteString = @"00a97a27 4cfd7479 0d";
        //NSString *temp = @"AA2CF1E6C4C5017B";
        //const char *temp2 = "AA2CF1E6C4C5017B";
//        const char temp2[] = {0x00a97a27, 0x4cfd7479, 0x0d};
//        NSData *serialBytes = [NSData dataWithBytes:(const void *)temp2 length:sizeof(temp2)];
//        
//        NSLog(@"data: %@", serialBytes);

        //test
            NSMutableDictionary *genericQuery = [[NSMutableDictionary alloc] init];
            
        //NSNumber *test = [NSNumber numberWithInt:10];
        ASN1_INTEGER *asnInteger = ASN1_INTEGER_new();
        ASN1_INTEGER_set(asnInteger, 10);
        
            [genericQuery setObject:(id)kSecClassCertificate forKey:(id)kSecClass];
        [genericQuery setObject:(id)asnInteger forKey:kSecAttrSerialNumber]; //serial number test
            [genericQuery setObject:(id)kSecMatchLimitAll forKey:(id)kSecMatchLimit];
            [genericQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
            [genericQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnRef];
            [genericQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
            
        NSArray *keychainItems = nil;
        OSStatus error = SecItemCopyMatching((CFDictionaryRef)genericQuery, (CFTypeRef *)&keychainItems);
        if(error != 0)
        {
            NSLog(@"OSStatus error: %ld", error);
            return nil;
        }

        //NSLog(@"Items: %@", keychainItems);
        for (NSDictionary *dict in keychainItems)
        {
            //NSLog(@"%@", dict);
//            CFDataRef slnr = (CFDataRef)[dict objectForKey:kSecAttrSerialNumber];
//            NSData *dup = (NSData*)slnr;
//            ASN1_INTEGER *sno = (ASN1_INTEGER*)[dup bytes];
//            
//            NSString *temp = [[NSString alloc] initWithBytes:[dup bytes] length:[dup length] encoding:NSUTF8StringEncoding];
//            NSLog(@"temp: %@", temp);
//            //NSLog(@"dup: %x", [dup bytes]);
//            
//            NSString *snoString = [X509CertificateUtil X509IntegerToNSString:sno];
//            
//            NSLog(@"SLNR: %@", snoString); //mh...
            
            
            //test
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
            
            NSData *sno = (NSData*)[dict objectForKey:(id)kSecAttrSerialNumber];
            NSLog(@"SNO: %@", sno);
            
            const unsigned char *bytes = [sno bytes];
            NSUInteger length = [sno length];
            
            NSMutableString *hexString = [[NSMutableString alloc] init];
            NSUInteger count = 0;
            for (; count < length; count++)
            {
                [hexString appendFormat:@"%02X", bytes[count]];
                //count++;
            }
            
            NSLog(@"hex string: %@", hexString);
            
            //NSString* pString = @"0xDEADBABE";
            NSScanner *pScanner = [NSScanner scannerWithString: hexString];
            
            unsigned long long iValue;
            [pScanner scanHexLongLong: &iValue];
            
            NSLog(@"long: %lld", iValue);
            
            
            
//            NSUInteger *intFromData;
//            [sno getBytes:&intFromData length:sizeof(intFromData)];
//            NSLog(@"SNO as int: %d", intFromData);
            
//            const unsigned char* bytes = (const unsigned char*)[sno bytes];
//            NSUInteger nbBytes = [sno length];
//            //If spaces is true, insert a space every this many input bytes (twice this many output characters).
//            static const NSUInteger spaceEveryThisManyBytes = 4UL;
//            //If spaces is true, insert a line-break instead of a space every this many spaces.
//            static const NSUInteger lineBreakEveryThisManySpaces = 4UL;
//            const NSUInteger lineBreakEveryThisManyBytes = spaceEveryThisManyBytes * lineBreakEveryThisManySpaces;
//            NSUInteger strLen = 2*nbBytes + (NO ? nbBytes/spaceEveryThisManyBytes : 0);
//            
//            NSMutableString* hex = [[NSMutableString alloc] initWithCapacity:strLen];
//            for(NSUInteger i=0; i<nbBytes; ) {
//                [hex appendFormat:@"%d", bytes[i]];
//                //We need to increment here so that the every-n-bytes computations are right.
//                ++i;
//            }
//            
//            NSLog(@"hex: %@", hex);
        
        }
    
        
    }
    
    
    return ret;
}

+ (BOOL)setData:(NSData*)data forKey:(NSString*)key type:(KeyChainDataType)type
{
    
    NSLog(@"%@", [Base64 encode:data]);
    NSLog(@"------------------------------------------------------------");
    
    if (type == kDataTypeCertificate)
    {
        NSMutableDictionary *query = [self createQueryForKey:key withType:type];
        
        NSString *temp = [X509CertificateUtil getSerialNumber:data];
        NSLog(@"Serial-string: %@", temp);
        
        //old
        /*
        NSArray *keys = [NSArray arrayWithObjects:( id)kSecClass, kSecAttrLabel, kSecReturnData, kSecAttrAccessible, nil];
        NSArray *values = nil;
        if (type == kDataTypeCertificate)
        {
            values = [NSArray arrayWithObjects:( id)kSecClassCertificate, labelString, kCFBooleanTrue, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, nil];
        }
        else if (type == kDataTypePrivateKey)
        {
            values = [NSArray arrayWithObjects:( id)kSecClassKey, labelString, kCFBooleanTrue, kSecAttrAccessibleWhenUnlocked, nil];
        }*/
        
        // -----------------
        
        /* pkey: 
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
         */
        
        
        
//        NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:[key length]];
//        NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
//        [query setObject:kSecClassKey forKey:kSecClass]; //security class
//        [query setObject:kSecAttrAccessibleWhenUnlocked forKey:kSecAttrAccessible]; //protection class
//        [query setObject:keyData forKey:kSecAttrApplicationTag]; //application tag
//
//        
        
        //CFDictionaryRef cfquery = (__bridge_retained CFDictionaryRef)query;
        CFDictionaryRef cfresult = NULL;
        OSStatus status = SecItemCopyMatching((CFDictionaryRef) query, (CFTypeRef*)&cfresult);
        //CFRelease(cfquery);
        //NSDictionary *result = (__bridge_transfer NSDictionary*)cfresult;
        
        if (status != errSecItemNotFound)
        {
            SecItemDelete((CFDictionaryRef) query);
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
            SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, ( CFDataRef)data);
            [query setObject:( id)cert forKey:( id)kSecValueRef];
        }
        else if (type == kDataTypePrivateKey)
        {
            [query setObject:(id)data forKey:( id)kSecValueData];
        }
        
        
        // cfquery = (__bridge_retained CFDictionaryRef)query;
        CFTypeRef certificateRef = NULL;
        status = SecItemAdd(( CFDictionaryRef) query, (CFTypeRef*)&certificateRef);
        
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
