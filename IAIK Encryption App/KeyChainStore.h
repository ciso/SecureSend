//
//  KeyChainStore.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 26.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kDataTypeCertificate,
    kDataTypePrivateKey
} KeyChainDataType;

@interface KeyChainStore : NSObject

+ (BOOL)setData:(NSData*)data forKey:(NSString*)key type:(KeyChainDataType)type;
+ (NSData*)dataForKey:(NSString*)key type:(KeyChainDataType)type;
+ (BOOL)removeItemForKey:(NSString*)key type:(KeyChainDataType)type;

@end
