//
//  KeyPair.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 01.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "KeyPair.h"

@interface KeyPair()

@property (nonatomic, strong) NSData *certificate;
@property (nonatomic, strong) NSData *privateKey;

@end

@implementation KeyPair

@synthesize certificate = _certificate;
@synthesize privateKey = _privateKey;
@synthesize certificateDateCreated = _certificateDateCreated;
@synthesize privateKeyDateCreated = _privateKeyDateCreated;

- (id)initWithCertificate:(NSData*)certificate privateKey:(NSData*)privateKey
{
    if (self = [super init])
    {
        _certificate = certificate;
        _privateKey = privateKey;
    }
    
    return self;
}

- (NSData*)certificate
{
    return _certificate;
}

- (NSData*)privateKey
{
    return _privateKey;
}

@end
