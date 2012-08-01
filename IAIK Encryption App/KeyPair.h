//
//  KeyPair.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 01.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyPair : NSObject

@property (nonatomic, strong) NSDate *certificateDateCreated;
@property (nonatomic, strong) NSDate *privateKeyDateCreated;

- (id)initWithCertificate:(NSData*)certificate privateKey:(NSData*)privateKey;
- (NSData*)certificate;
- (NSData*)privateKey;

@end
