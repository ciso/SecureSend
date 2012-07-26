//
//  KeyChainManager.h
//  bac_01
//
//  Created by Christoph Hechenblaikner on 29.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CERT_ID_USER @"IAIK_ME"
#define KEY_ID_USER @"IAIK_ME_KEY"

@interface KeyChainManager : NSObject

+(BOOL) addCertificate:(NSData*)data withOwner:(NSString*)name;
+(NSMutableDictionary*) createSearchDictionaryForOwner: (NSString*) name;
+(BOOL) deleteCertificatewithOwner:(NSString*) name;
+(NSData*) getCertificateofOwner:(NSString*) name;
+(BOOL) addUsersPrivateKey: (NSData*) privateKey;
+(NSMutableDictionary*) createKeySearchDirectory;
+(NSData*) getUsersPrivateKey;
+(BOOL) deleteUsersPrivateKey;
+(NSMutableDictionary*) createSearchDirectoryAttributesForOwner: (NSString*) name;
+(NSDictionary*) getAttributesOfCertificateWithOwner: (NSString*) name;

+(BOOL) addUsersPrivateKey: (NSData*) privateKey withOwner:(NSString*)owner;

@end
