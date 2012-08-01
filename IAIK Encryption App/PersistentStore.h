//
//  PersistentStore.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 26.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersistentStore : NSObject

//+ (NSString*)storeNewCertificate:(NSString*)name;
//+ (NSString*)getKeyForCertificateUser;

+ (BOOL)storeForUserCertificate:(NSData*)certificate privateKey:(NSData*)privateKey;
+ (NSData*)getActiveCertificateOfUser;
+ (NSData*)getActivePrivateKeyOfUser;

//JUST FOR DEBUG PURPOSES
+ (NSArray*)getAllKeyPairsOfUser;

@end
