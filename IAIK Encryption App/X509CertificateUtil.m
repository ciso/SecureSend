//
//  X509CertificateUtil.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 27.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "X509CertificateUtil.h"
#include <openssl/x509.h>
#include <openssl/x509v3.h>
#include <openssl/pem.h>
#include <openssl/err.h>

@implementation X509CertificateUtil

+ (NSString*)getSerialNumber:(NSData*)cert
{
    //parsing nsdata to x.509 object
    BIO *inCert = BIO_new_mem_buf((void*)[cert bytes], [cert length]);
    if (!inCert) {
        NSLog(@"OpenSSL error: %s", ERR_reason_error_string((unsigned long)ERR_get_error()));
    }
    
    X509 *certificate = d2i_X509_bio(inCert, NULL);
    if (!certificate) {
        NSLog(@"OpenSSL error: %s", ERR_reason_error_string((unsigned long)ERR_get_error()));
    }

    NSString *serialNumber = nil;
    if (certificate != NULL)
    {
        ASN1_INTEGER *serialNumberASN1 = X509_get_serialNumber(certificate);
        serialNumber = [X509CertificateUtil X509IntegerToNSString:serialNumberASN1];
    }
    
    return serialNumber;
}

+ (NSString*)X509IntegerToNSString:(ASN1_INTEGER*)integer
{
	BIO *bio = BIO_new(BIO_s_mem());
	NSString *result = nil;
	char *data;
	int length;
	
	if(i2a_ASN1_INTEGER(bio, integer)) {
		length = BIO_get_mem_data(bio, &data);
		result = [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
	}
	
	BIO_free(bio);
	
	return result;
}

@end
