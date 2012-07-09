//
//  KeyChainManager.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 29.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KeyChainManager.h"

@implementation KeyChainManager


/*
 Attributes for certificate in keychain: 
 kSecAttrAccessible
 kSecAttrAccessGroup
 kSecAttrCertificateType
 kSecAttrCertificateEncoding
 kSecAttrLabel
 kSecAttrSubject
 kSecAttrIssuer
 kSecAttrSerialNumber
 kSecAttrSubjectKeyID
 kSecAttrPublicKeyHash
 */

+(BOOL) addCertificate:(NSData*)data withOwner:(NSString*)name
{
    //generating certificate-entry for cert
    
    
    SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
    
    NSMutableDictionary* dict = [self createSearchDictionaryForOwner:name];
    
    CFDictionaryRef cfquery = (__bridge_retained CFDictionaryRef)dict;
    CFDictionaryRef cfresult = NULL;
    OSStatus status = SecItemCopyMatching(cfquery, (CFTypeRef*)&cfresult);
    CFRelease(cfquery);
    //NSDictionary *result = (__bridge_transfer NSDictionary*)cfresult;
    
    if (status != errSecItemNotFound)
    {
        SecItemDelete(cfquery);
    }
    
    [dict setObject:(__bridge id)cert forKey:(__bridge id)kSecValueRef];
    
    cfquery = (__bridge_retained CFDictionaryRef)dict;
    CFTypeRef certificateRef = NULL;
    OSStatus error = SecItemAdd(cfquery, (CFTypeRef*)&certificateRef);
    
    
    
    //OSStatus error = SecItemAdd((CFDictionaryRef)dict, &certificateRef);
    
    if(error != 0)
        return NO;
    
    return YES;
}

+(BOOL) deleteCertificatewithOwner:(NSString*) name
{
    NSMutableDictionary* dict = [self createSearchDictionaryForOwner:name];
    
    OSStatus error = SecItemDelete((__bridge CFDictionaryRef) dict);
    
    if(error != 0)
        return NO;
    
    return YES;
    
}

+(NSMutableDictionary*) createSearchDictionaryForOwner: (NSString*) name
{
    const char * namestring = [name UTF8String];
    
    
    CFStringRef labelstring = CFStringCreateWithCString(NULL, namestring, kCFStringEncodingUTF8);
    
    NSArray* keys = [NSArray arrayWithObjects:(__bridge id)kSecClass,kSecAttrLabel,kSecReturnData,kSecAttrAccessible,nil];
    NSArray* values = [NSArray arrayWithObjects:(__bridge id)kSecClassCertificate,labelstring,kCFBooleanTrue,kSecAttrAccessibleWhenUnlockedThisDeviceOnly,nil];
    NSMutableDictionary* searchdict = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    
    CFRelease(labelstring);
    
    return searchdict;
}

+(NSData*) getCertificateofOwner:(NSString*) name
{
    
    NSMutableDictionary* dict = [self createSearchDictionaryForOwner:name];
    
    CFTypeRef item = NULL;
    OSStatus error = SecItemCopyMatching((__bridge_retained CFDictionaryRef)dict, &item);
    
    if(error != 0)
    {
        NSLog(@"Certificat not found in keychain!!");
        return nil;
    }
    
    NSData* resultdict = (__bridge NSData*) item;
    return resultdict;
}

+(BOOL) addUsersPrivateKey: (NSData*) privateKey
{
    NSMutableDictionary* searchdict = [self createKeySearchDirectory];
    
    CFTypeRef item = NULL;
    OSStatus error = SecItemCopyMatching((__bridge_retained CFDictionaryRef) searchdict, &item);
    
    if(error != errSecItemNotFound)
    {
        SecItemDelete((__bridge_retained CFDictionaryRef) searchdict);
    }
    
    [searchdict setObject:(id)privateKey forKey:(__bridge id)kSecValueData];
    
    OSStatus adderror = SecItemAdd((__bridge_retained CFDictionaryRef) searchdict, &item);
    
    if(adderror != 0)
    {
        return NO;
    }
        
return YES;
}

+(NSMutableDictionary*) createKeySearchDirectory
{
    const char * namestring = [KEY_ID_USER UTF8String];
    
    CFStringRef labelstring = CFStringCreateWithCString(NULL, namestring, kCFStringEncodingUTF8);
    
    NSArray* keys = [NSArray arrayWithObjects:(__bridge id)kSecClass,kSecAttrLabel,kSecReturnData,kSecAttrAccessible,nil];
    NSArray* values = [NSArray arrayWithObjects:(__bridge id)kSecClassKey,labelstring,kCFBooleanTrue,kSecAttrAccessibleWhenUnlocked,nil];
    NSMutableDictionary* searchdict = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    
    CFRelease(labelstring);
    
    return searchdict;
}

+(NSData*) getUsersPrivateKey
{

    NSMutableDictionary* searchdict = [self createKeySearchDirectory];
    
    CFTypeRef item = NULL;
    OSStatus error = SecItemCopyMatching((__bridge_retained CFDictionaryRef) searchdict, &item);
    
    if(error != 0)
    {
        NSLog(@"FATAL!!: key not found in keychain!");
        return nil;
    }
    
    return (__bridge NSData*) item;
}

+(BOOL) deleteUsersPrivateKey
{
    NSMutableDictionary* searchdict = [self createKeySearchDirectory];
    
    OSStatus error = SecItemDelete((__bridge_retained CFDictionaryRef) searchdict);
    
    if(error != 0)
    {
        return NO;
    }

return YES;

}

+(NSDictionary*) getAttributesOfCertificateWithOwner: (NSString*) name
{
    NSMutableDictionary* dict = [self createSearchDirectoryAttributesForOwner:name];
    
    CFTypeRef item = NULL;
    OSStatus error = SecItemCopyMatching((__bridge_retained CFDictionaryRef)dict, &item);
    
    if(error != 0)
    {
        NSLog(@"Certificat not found in keychain!!");
        return nil;
    }
    
    NSDictionary* resultdict = (__bridge NSDictionary*) item;
    
    return resultdict;
}

+(NSMutableDictionary*) createSearchDirectoryAttributesForOwner: (NSString*) name
{ 
    const char * namestring = [name UTF8String];
    
    
    CFStringRef labelstring = CFStringCreateWithCString(NULL, namestring, kCFStringEncodingUTF8);
    
    NSArray* keys = [NSArray arrayWithObjects:(__bridge id)kSecClass,kSecAttrLabel,kSecReturnAttributes,kSecAttrAccessible,nil];
    NSArray* values = [NSArray arrayWithObjects:(__bridge id)kSecClassCertificate,labelstring,kCFBooleanTrue,kSecAttrAccessibleWhenUnlocked,nil];
    NSMutableDictionary* searchdict = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    
    CFRelease(labelstring);
    
    return searchdict;
}


@end
