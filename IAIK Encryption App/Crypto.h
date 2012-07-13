//
//  Crypto.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 29.02.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"
#import <openssl/x509.h>


@interface Crypto : NSObject

+ (Crypto*) getInstance;

- (void) encryptFileUsingCMS:(NSString*)pathToEncryptFile
        andPublicCertificate:(NSString*)pathToPublicCertificate
                  withFormat:(format)format
              andStoreFileTo:(NSString*)storagePathToEncryptedFile
            andUseBinaryMode:(BOOL)binary;

//old
- (NSData*) encryptBinaryFile:(NSData*)containerFile
       usingCertificate:(X509*)cert;
//new
- (NSData*) encryptBinaryFile:(NSData*)containerFile
              withCertificate:(NSData*)cert;

- (X509*) loadCertificateFromFile:(NSString*)pathToCertificate;

- (NSData*)convertX509CertToNSData:(X509*)certificate;
//- (EVP_PKEY*)createRSAKey;

- (NSData*)createRSAKey;
- (NSData*)createRSAKeyWithKeyLength:(int)length;


- (EVP_PKEY*) loadPrivateKeyFromFile:(NSString*)pathToPrivateKey
                      withPassphrase:(NSString*)passphrase;

//new
- (NSData*) decryptBinaryFile:(NSData*)encryptedFile
           withUserCertificate:(NSData*)certificate
                privateKey:(NSData*)privateKey;

//old
- (NSData*) decryptBinaryFile:(NSData*)encryptedFile
           andUserCertificate:(X509*)certificate
                andPrivateKey:(EVP_PKEY*)privateKey;


- (void) decryptFileUsingSMIME:(NSString*)pathToEncryptedFile
            andUserCertificate:(NSString*)pathToUserCertificate
                    withFormat:(format)format
                 andPrivateKey:(NSString*)pathToPrivateKey
                withPassphrase:(NSString*)passphrase
                  andStoreItTo:(NSString*)pathToStoreFile
              andUseBinaryMode:(BOOL)binary;

//- (void) createX509Certificate;

- (NSDate*)getExpirationDateOfCertificate:(NSData*)cert;

//new
- (NSData*)createX509CertificateWithPrivateKey:(NSData*)pkey
                                      withName:(NSString*)commonName
                                  emailAddress:(NSString*)emailAddress
                                       country:(NSString*)country
                                          city:(NSString*)city
                                  organization:(NSString*)organization
                              organizationUnit:(NSString*)organizationUnit;


//old
/*- (X509*) createX509CertificateWithPrivateKey:(EVP_PKEY*)pkey
                                  andWithName:(NSString*)commonName
                              andEmailAddress:(NSString*)emailAddress
                                   andCountry:(NSString*)country
                                      andCity:(NSString*)city
                              andOrganization:(NSString*)organization
                          andOrganizationUnit:(NSString*)organizationUnit;*/



- (void) addExtensionToCert:(X509*)cert
                     withId:(int)nid
                   andValue:(NSString*)value;

- (void) addTextEntryToCert:(X509_NAME**)name
                     forKey:(NSString*)key
                  withValue:(NSString*)value;

//- (X509) createX509CertificateForUser:(NSString*)username

- (void) throwWithText:(NSString*)message;

@end
