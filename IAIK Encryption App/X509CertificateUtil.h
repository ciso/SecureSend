//
//  X509CertificateUtil.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 27.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <openssl/pem.h>

@interface X509CertificateUtil : NSObject

+ (NSString*)getSerialNumber:(NSData*)cert;
+ (NSString*)X509IntegerToNSString:(ASN1_INTEGER*)integer;

@end
