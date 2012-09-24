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

+ (NSDate*)getExpirationDate:(NSData*)cert
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
    
    NSDate *expiryDate = nil;
    
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
    }
    
    return expiryDate;
}

+ (NSString*)getCommonName:(NSData*)cert
{
    return [self getField:@"CN" ofCert:cert];
}

+ (NSString*)getOrganization:(NSData*)cert
{
    return [self getField:@"O" ofCert:cert];
}

+ (NSString*)getEmail:(NSData*)cert
{
    return [self getField:@"emailAddress" ofCert:cert];
}

+ (NSString*)getOrganizationUnit:(NSData*)cert
{
    return [self getField:@"OU" ofCert:cert];
}
+ (NSString*)getCity:(NSData*)cert
{
    return [self getField:@"L" ofCert:cert];
    //C is for country, L = city
}

+ (NSString*)getField:(NSString*)field ofCert:(NSData*)cert
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
    
    NSString *commonName = nil;
    
    if (certificate != NULL) {
        X509_NAME *issuerName = X509_get_issuer_name(certificate);
        if (issuerName != NULL) {
            int nid = OBJ_txt2nid([field cStringUsingEncoding:NSUTF8StringEncoding]); //field specifier
            int index = X509_NAME_get_index_by_NID(issuerName, nid, -1);
            
            X509_NAME_ENTRY *issuerNameEntry = X509_NAME_get_entry(issuerName, index);
            
            if (issuerNameEntry) {
                ASN1_STRING *issuerNameASN1 = X509_NAME_ENTRY_get_data(issuerNameEntry);
                
                if (issuerNameASN1 != NULL) {
                    unsigned char *issuerName = ASN1_STRING_data(issuerNameASN1);
                    commonName = [NSString stringWithUTF8String:(char *)issuerName];
                }
            }
        }
        
    }
    
    return commonName;

}

@end
