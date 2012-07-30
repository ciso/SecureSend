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
    
    /*X509_EXTENSION *ext = X509_get_ext(certificate, 0);
     
     ASN1_TIME *begin = X509_get_notBefore(certificate);
     ASN1_TIME *end = X509_get_notAfter(certificate);*/
    
    
    NSString *serialNumber = nil;
    if (certificate != NULL)
    {
        ASN1_INTEGER *serialNumberASN1 = X509_get_serialNumber(certificate);
        
        printf("test: %s", serialNumberASN1->data);
        NSString *dup = [X509CertificateUtil X509IntegerToNSString:serialNumberASN1];
        NSLog(@"serial...: %@", dup);
        
        return dup;
        
        if(serialNumberASN1)
        {
            unsigned char *data = NULL;
            int length = ASN1_STRING_to_UTF8(&data, serialNumberASN1);
            
            if(length >= 0)
            {
                serialNumber = [[NSString alloc] initWithBytes:data
                                                         length:length
                                                       encoding:NSUTF8StringEncoding];
            }
            
            OPENSSL_free(data);
        }
        
    }
    
    /*NSDate *expiryDate = nil;
    
    if (certificate != NULL) {
        ASN1_TIME *certificateExpiryASN1 = X509_get_notAfter(certificate);
        if (certificateExpiryASN1 != NULL) {
            ASN1_GENERALIZEDTIME *certificateExpiryASN1Generalized = ASN1_TIME_to_generalizedtime(certificateExpiryASN1, NULL);
            if (certificateExpiryASN1Generalized != NULL) {
                unsigned char *certificateExpiryData = ASN1_STRING_data(certificateExpiryASN1Generalized);
                
                NSString *expiryTimeStr = [NSString stringWithUTF8String:(char *)certificateExpiryData];
                NSDateComponents *expiryDateComponents = [[NSDateComponents alloc] init];
                
                expiryDateComponents.year   = [[expiryTimeStr substringWithRange:NSMakeRange(0, 4)] intValue];
                expiryDateComponents.month  = [[expiryTimeStr substringWithRange:NSMakeRange(4, 2)] intValue];
                expiryDateComponents.day    = [[expiryTimeStr substringWithRange:NSMakeRange(6, 2)] intValue];
                expiryDateComponents.hour   = [[expiryTimeStr substringWithRange:NSMakeRange(8, 2)] intValue];
                expiryDateComponents.minute = [[expiryTimeStr substringWithRange:NSMakeRange(10, 2)] intValue];
                expiryDateComponents.second = [[expiryTimeStr substringWithRange:NSMakeRange(12, 2)] intValue];
                
                NSCalendar *calendar = [NSCalendar currentCalendar];
                expiryDate = [calendar dateFromComponents:expiryDateComponents];
            }
        }
    }*/
    
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
