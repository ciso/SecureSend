//
//  Crypto.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 29.02.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Crypto.h"

//openssl includes
#include <openssl/cms.h>
#include <openssl/x509.h>
#include <openssl/x509v3.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/bn.h>


@interface Crypto()

- (EVP_PKEY*)convertNSDataToPrivateKey:(NSData*)pkey
                            passphrase:(NSString*)passphrase;

- (void) createNewCertificate:(X509**)x509p
               withPrivateKey:(EVP_PKEY**)pkeyp
                 andExpiresIn:(int)days
                  andWithName:(NSString*)commonName
              andEmailAddress:(NSString*)emailAddress
                   andCountry:(NSString*)country
                      andCity:(NSString*)city
              andOrganization:(NSString*)organization
          andOrganizationUnit:(NSString*)organizationUnit;

@end

@implementation Crypto

static Crypto *instance = NULL;


static void callback(int p, int n, void *arg);

/* getInstance
 * Singleton pattern instance method
 */
+ (Crypto*) getInstance {
    @synchronized(self) {
        if (instance == NULL) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

/**
 * encryptFileUsingCMS
 */
- (void) encryptFileUsingCMS:(NSString*)pathToEncryptFile
        andPublicCertificate:(NSString*)pathToPublicCertificate
                  withFormat:(format)format
              andStoreFileTo:(NSString*)storagePathToEncryptedFile
            andUseBinaryMode:(BOOL)binary{
    
    //openssl variables
    BIO *in = NULL, *out = NULL, *tbio = NULL;
	X509 *rcert = NULL;
	STACK_OF(X509) *recips = NULL;
	CMS_ContentInfo *cms = NULL;
    int flags = CMS_STREAM;
    
    
    NSLog(@"Encrypting using CMS");
    
    char *certInmode = "r";
    if (format == PEM) {
        certInmode = "r";
    }
    else if (format == DER) {
        certInmode = "rb";
    }
    
    //checking if a binary container should be encrypted or an ascii file
    if (binary) {
        flags |= CMS_BINARY;
    }
    
    //openssl lib init
	OpenSSL_add_all_algorithms();
	ERR_load_crypto_strings();
    
	//loading certificate bio from user path
	tbio = BIO_new_file([pathToPublicCertificate cStringUsingEncoding:NSUTF8StringEncoding], certInmode);
	if (!tbio) {
        [self throwWithText:@"Certificate BIO check failed"];
    }    
    
    //creating certificate from loaded BIO
    
    if (format == DER) {
        rcert = d2i_X509_bio(tbio, NULL);
    }
    else if (format == PEM) {
        rcert = PEM_read_bio_X509(tbio, NULL, 0, NULL);
    }
    else {
        [self throwWithText:@"NO INPUT FORMAT SPECIFIED!!!"];
    }
    
	if (!rcert) {        
        [self throwWithText:@"Loading certificate from BIO failed"];
    }    
    
    //create recipient stack and add recipient cert to it
	recips = sk_X509_new_null();
	if (!recips || !sk_X509_push(recips, rcert)) {
        [self throwWithText:@"Adding cert to recipient stack failed"];
    }
    
	rcert = NULL;
    
    //setting inmode based on binary flag
    char *inmode = "r";
    if (binary) {
        inmode = "rb";
    }
    
    //opening file
    in = BIO_new_file([pathToEncryptFile cStringUsingEncoding:NSUTF8StringEncoding], inmode);
	if (!in) {
		[self throwWithText:@"Loading file BIO failed"];
    }    
	/* encrypt content */
    
    //creating symmetric cipher
    const EVP_CIPHER *symkey = EVP_aes_256_cbc(); //EVP_des_ede3_cbc();
    
    //encrypting file and creating a cms content info
	cms = CMS_encrypt(recips, in, symkey, flags);
	if (!cms) {
		[self throwWithText:@"CMS encrypt failed"];
    }    
    
    char *outmode = "w";
    if (binary) {
        outmode = "wb";
    }
    
    //creating encrypted output file
    out = BIO_new_file([storagePathToEncryptedFile cStringUsingEncoding:NSUTF8StringEncoding], "wb");
	if (!out) {
		[self throwWithText:@"Could not create a out BIO"];
    }    
    
    //write out the smime message
	if (!SMIME_write_CMS(out, cms, in, flags)) {
		[self throwWithText:@"Creating SMIME message from CMS failed"];
    }
    
	if (cms)
		CMS_ContentInfo_free(cms);
	if (rcert)
		X509_free(rcert);
	if (recips)
		sk_X509_pop_free(recips, X509_free);
    
	if (in)
		BIO_free(in);
	if (out)
		BIO_free(out);
	if (tbio)
		BIO_free(tbio);
    
    
    
    NSLog(@"Encryption succeeded!");
}


- (NSData*)convertX509CertToNSData:(X509*)certificate
{
    
    BIO *out = BIO_new(BIO_s_mem());

    PEM_write_bio_X509(out, certificate);
    
    char *outputBuffer;
    long outputLength = BIO_get_mem_data(out, &outputBuffer);
    NSData *temp = [NSData dataWithBytes:outputBuffer length:outputLength];
    
    return temp;
}

/*- (EVP_PKEY*)createRSAKey
{
    EVP_PKEY *pkey = EVP_PKEY_new();

    RSA *rsa=RSA_generate_key(2048, RSA_F4, callback, NULL);
    if (!EVP_PKEY_assign_RSA(pkey, rsa))
    {
        assert(false);
    }
    
    return pkey;
}*/

//creating a new RSA key using OpenSSL with 2048 bit length 
//and returning it as NSData* to the user
- (NSData*)createRSAKey
{
    return [self createRSAKeyWithKeyLength:2048];
}


//creating a new RSA key using OpenSSL with a particular length
- (NSData*)createRSAKeyWithKeyLength:(int)length
{
    NSData *key; 
    EVP_PKEY *pkey = EVP_PKEY_new();
    
    BIO *outKey = BIO_new(BIO_s_mem());
    
    RSA *rsa = RSA_generate_key(length, RSA_F4, callback, NULL);
    if (!EVP_PKEY_assign_RSA(pkey, rsa)) {
        [self throwWithText:@"RSA key creation failed"];
    }
    
    PEM_write_bio_PrivateKey(outKey, pkey, NULL, NULL, 0, NULL, NULL);
    
    char *outputBuffer;
    long outputLength = BIO_get_mem_data(outKey, &outputBuffer);
    key = [NSData dataWithBytes:outputBuffer length:outputLength];
    
    return key;
}

- (EVP_PKEY*)convertNSDataToPrivateKey:(NSData*)pkey
                            passphrase:(NSString*)passphrase
{
    EVP_PKEY *rkey;
    BIO *inKey = BIO_new_mem_buf((void*)[pkey bytes], [pkey length]);
    
    rkey = PEM_read_bio_PrivateKey(inKey, NULL, 0, NULL); //(void*)[passphrase cStringUsingEncoding:NSUTF8StringEncoding]);
    
    return rkey;
}


/**
 * encryptBinaryFile
 * This method provides a complete objective-c wrapper around OpenSSL's 
 * CMS encrypt functionality. The big advantage of this method is that the 
 * developer can work with NSData* files in the code and pass them into that 
 * method which encrypts it using the given X509* certificate and returns the 
 * encrypted file as NSData* to the developer. So it's not needed any more to 
 * store and load files directly from the "filesystem" but it's possible to 
 * work with NSData* objects in RAM.
 * This should significantly improv‚e the performance!
 */
- (NSData*) encryptBinaryFile:(NSData*)containerFile
             withCertificate:(NSData*)cert
{
    BIO *inCert = BIO_new_mem_buf((void*)[cert bytes], [cert length]);
    if (!inCert) {
        [self throwWithText:@"Could not load mem BIO for X509 NSData"];
    }
    
    X509 *certificate = d2i_X509_bio(inCert, NULL);
    if (!certificate) {
        [self throwWithText:@"Could not load X509 certificate from BIO"];
    }
        
    return [self encryptBinaryFile:containerFile usingCertificate:certificate];
}

#pragma mark - Get Expiration Date
- (NSDate*)getExpirationDateOfCertificate:(NSData*)cert
{
    //parsing nsdata to x.509 object
    BIO *inCert = BIO_new_mem_buf((void*)[cert bytes], [cert length]);
    if (!inCert) {
        [self throwWithText:@"Could not load mem BIO for X509 NSData"];
    }
    
    X509 *certificate = d2i_X509_bio(inCert, NULL);
    if (!certificate) {
        [self throwWithText:@"Could not load X509 certificate from BIO"];
    }
    
    /*X509_EXTENSION *ext = X509_get_ext(certificate, 0);
       
    ASN1_TIME *begin = X509_get_notBefore(certificate);
    ASN1_TIME *end = X509_get_notAfter(certificate);*/  
    
    
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



//OLD!!!
/**
 * encryptBinaryFile
 * This method provides a complete objective-c wrapper around OpenSSL's 
 * CMS encrypt functionality. The big advantage of this method is that the 
 * developer can work with NSData* files in the code and pass them into that 
 * method which encrypts it using the given X509* certificate and returns the 
 * encrypted file as NSData* to the developer. So it's not needed any more to 
 * store and load files directly from the "filesystem" but it's possible to 
 * work with NSData* objects in RAM.
 * This should significantly improve the performance!
 */
- (NSData*) encryptBinaryFile:(NSData*)containerFile
       usingCertificate:(X509*)cert {
    //openssl variables
    BIO *in = NULL, *out = NULL, *tbio = NULL;
	STACK_OF(X509) *recips = NULL;
	CMS_ContentInfo *cms = NULL;
    int flags = CMS_STREAM;
    
    
    NSLog(@"Encrypting (NSData) using CMS");
    
    flags |= CMS_BINARY;
    
    //openssl lib init
	OpenSSL_add_all_algorithms();
	ERR_load_crypto_strings();
    
    //create recipient stack and add recipient cert to it
	recips = sk_X509_new_null();
	if (!recips || !sk_X509_push(recips, cert)) {
        [self throwWithText:@"Adding cert to recipient stack failed"];
    }
    
	cert = NULL;
    
    in = BIO_new(BIO_s_mem());
    BIO_write(in, [containerFile bytes], [containerFile length]);
    //BIO_flush(in); //not sure?!
    
    if (!in) {
		[self throwWithText:@"Loading file BIO failed"];
    }    
    
    //creating symmetric cipher
    const EVP_CIPHER *symkey = EVP_aes_256_cbc(); //EVP_des_ede3_cbc();
    
    //encrypting file and creating a cms content info
	cms = CMS_encrypt(recips, in, symkey, flags);
	if (!cms) {
		[self throwWithText:@"CMS encrypt failed"];
    }    
    
    //creating output bio
    out = BIO_new(BIO_s_mem());
	if (!out) {
		[self throwWithText:@"Could not create a out BIO"];
    }    
    
    //write out the smime message
	if (!SMIME_write_CMS(out, cms, in, flags)) {
		[self throwWithText:@"Creating SMIME message from CMS failed"];
    }
    
    //load encrypted bio into char and then into nsdata
    char *outputBuffer;
    long outputLength = BIO_get_mem_data(out, &outputBuffer);
    NSData *temp = [NSData dataWithBytes:outputBuffer length:outputLength];
    
	if (cms)
		CMS_ContentInfo_free(cms);
	if (recips)
		sk_X509_pop_free(recips, X509_free);
    
	if (in)
		BIO_free(in);
	if (out)
		BIO_free(out);
	if (tbio)
		BIO_free(tbio);
    
    NSLog(@"Encryption (NSData) succeeded!");  
    
    //return encrypted data
    return temp;
}

- (X509*) loadCertificateFromFile:(NSString*)pathToCertificate {
    
    OpenSSL_add_all_algorithms();
	ERR_load_crypto_strings();
    
    BIO *certBio = BIO_new_file([pathToCertificate cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    if (!certBio) {
        [self throwWithText:@"Could not load certificate BIO"];
    }
    
    X509 *cert = d2i_X509_bio(certBio, NULL);
    if (!cert) {
        [self throwWithText:@"Could not load X509 certificate from BIO"];
    }
    
    return cert;
}


//new
- (NSData*) decryptBinaryFile:(NSData*)encryptedFile
          withUserCertificate:(NSData*)certificate
                   privateKey:(NSData*)privateKey
{
    BIO *inCert = BIO_new_mem_buf((void*)[certificate bytes], [certificate length]);
    if (!inCert) {
        [self throwWithText:@"Could not load mem BIO for X509 NSData"];
    }
    
    X509 *cert = d2i_X509_bio(inCert, NULL);
    if (!cert) {
        [self throwWithText:@"Could not load X509 certificate from BIO"];
    }

     EVP_PKEY *key = [self convertNSDataToPrivateKey:privateKey passphrase:@""]; //todo
    
    return [self decryptBinaryFile:encryptedFile andUserCertificate:cert andPrivateKey:key];
}


//old
- (NSData*) decryptBinaryFile:(NSData*)encryptedFile
           andUserCertificate:(X509*)certificate
                andPrivateKey:(EVP_PKEY*)rkey {
    //openssl vars
    BIO *in = NULL, *out = NULL, *tbio = NULL;
    //EVP_PKEY *rkey = NULL;
	PKCS7 *p7 = NULL;
    int flags = 0;
    
    
    NSLog(@"Decrypting (NSData) file using SMIME");
    
    flags |= CMS_BINARY;
    
	OpenSSL_add_all_algorithms();
	ERR_load_crypto_strings();    
    
    in = BIO_new_mem_buf((void*)[encryptedFile bytes], [encryptedFile length]);
	if (!in) {
		[self throwWithText:@"Could not load BIO of encrypted file"];
    }
    
	p7 = SMIME_read_PKCS7(in, NULL);
    
	if (!p7) {
		[self throwWithText:@"Extracting PKCS#7 content from SMIME message failed"];
    }

    //opening BIO for original file (decrypted one)
    //out = BIO_new_file([pathToStoreFile cStringUsingEncoding:NSUTF8StringEncoding], "wb");
    out = BIO_new(BIO_s_mem());
    if (!out) {
		[self throwWithText:@"Could not load out BIO"];
    }
    
    //decrypt using pkcs7
	if (!PKCS7_decrypt(p7, rkey, certificate, out, 0)) {
		[self throwWithText:@"PKCS#7 decrypt failed"];
    }
    
    char *outputBuffer;
    long outputLength = BIO_get_mem_data(out, &outputBuffer);
    NSData *temp = [NSData dataWithBytes:outputBuffer length:outputLength];
    
    if (p7)
		PKCS7_free(p7);
	if (in)
		BIO_free(in);
	if (out)
		BIO_free(out);
	if (tbio)
		BIO_free(tbio);
    
    NSLog(@"Decryption (NSData) succeeded!");
    
    return temp;
}


- (EVP_PKEY*) loadPrivateKeyFromFile:(NSString*)pathToPrivateKey
                      withPassphrase:(NSString*)passphrase {
    
    EVP_PKEY *rkey = NULL;
    
    OpenSSL_add_all_algorithms();
	ERR_load_crypto_strings();
    
    BIO *pkey = BIO_new_file([pathToPrivateKey cStringUsingEncoding:NSUTF8StringEncoding], "r");
    rkey = PEM_read_bio_PrivateKey(pkey, NULL, 0, (void*)[passphrase cStringUsingEncoding:NSUTF8StringEncoding]);
	if (!rkey) {
        [self throwWithText:@"Certificate or primary key was not valid"];
        
    }
    
    return rkey;
}





/**
 * decryptFileUsingSMIME
 */
- (void) decryptFileUsingSMIME:(NSString*)pathToEncryptedFile
            andUserCertificate:(NSString*)pathToUserCertificate
                    withFormat:(format)format
                 andPrivateKey:(NSString*)pathToPrivateKey
                withPassphrase:(NSString*)passphrase
                  andStoreItTo:(NSString*)pathToStoreFile
              andUseBinaryMode:(BOOL)binary {
    
    //openssl vars
    BIO *in = NULL, *out = NULL, *tbio = NULL;
	X509 *rcert = NULL;
	EVP_PKEY *rkey = NULL;
	PKCS7 *p7 = NULL;
    int flags = 0;
    
    
    NSLog(@"Decrypting file using SMIME");
    
    if (binary) {
        flags |= CMS_BINARY;
    }
    
	OpenSSL_add_all_algorithms();
	ERR_load_crypto_strings();
    
    char *certInmode = "r";
    if (format == DER) {
        certInmode = "rb";
    }
    
    //load users certificate
	tbio = BIO_new_file([pathToUserCertificate cStringUsingEncoding:NSUTF8StringEncoding], certInmode);
    
	if (!tbio) {
		[self throwWithText:@"Could not load certificate BIO"];
    }
    
    if (format == DER) {
        rcert = d2i_X509_bio(tbio, NULL);
    }
    else if (format == PEM) {
        rcert = PEM_read_bio_X509(tbio, NULL, 0, NULL);
    }
    
    
	//BIO_reset(tbio);
    
    
    //loading bio for private key and extract it from the BIO
    BIO *pkey = BIO_new_file([pathToPrivateKey cStringUsingEncoding:NSUTF8StringEncoding], "r");
    rkey = PEM_read_bio_PrivateKey(pkey, NULL, 0, (void*)[passphrase cStringUsingEncoding:NSUTF8StringEncoding]);
	if (!rcert || !rkey) {
        [self throwWithText:@"Certificate or primary key was not valid"];
        
    }
    
    //inmode for encrypted file based on binary flag
    char *inmode = "r";
    if (binary) {
        inmode = "rb";
    }
    
    //open content beeing decrypted
    in = BIO_new_file([pathToEncryptedFile cStringUsingEncoding:NSUTF8StringEncoding], "rb");
	if (!in) {
		[self throwWithText:@"Could not load BIO of encrypted file"];
    }
    
	p7 = SMIME_read_PKCS7(in, NULL);
    
	if (!p7) {
		[self throwWithText:@"Extracting PKCS#7 content from SMIME message failed"];
    }
    
    char *outmode = "w";
    if (binary) {
        outmode = "wb";
    }
    
    //opening BIO for original file (decrypted one)
    out = BIO_new_file([pathToStoreFile cStringUsingEncoding:NSUTF8StringEncoding], outmode);
	if (!out) {
		[self throwWithText:@"Could not load out BIO"];
    }
    
    //decrypt using pkcs7
	if (!PKCS7_decrypt(p7, rkey, rcert, out, 0)) {
		[self throwWithText:@"PKCS#7 decrypt failed"];
    }
    
    if (p7)
		PKCS7_free(p7);
	if (rcert)
		X509_free(rcert);
	if (rkey)
		EVP_PKEY_free(rkey);
    
	if (in)
		BIO_free(in);
	if (out)
		BIO_free(out);
	if (tbio)
		BIO_free(tbio);
    
    NSLog(@"Decryption succeeded!");
}


/**
 * createX509CertificateWith...
 * This method is a objective-c wrapper for creating certificates 
 * with a given private key as NSData*
 */
- (NSData*)createX509CertificateWithPrivateKey:(NSData*)pkey
                                      withName:(NSString*)commonName
                                  emailAddress:(NSString*)emailAddress
                                       country:(NSString*)country
                                          city:(NSString*)city
                                  organization:(NSString*)organization
                              organizationUnit:(NSString*)organizationUnit
{
    NSData *cert;
    BIO *outCert = BIO_new(BIO_s_mem());
    
    BIO *bio_err;
	X509 *x509=NULL;
    
	CRYPTO_mem_ctrl(CRYPTO_MEM_CHECK_ON);
    
	bio_err=BIO_new_fp(stderr, BIO_NOCLOSE);
    
    EVP_PKEY *key = [self convertNSDataToPrivateKey:pkey passphrase:@"dup..."]; //todo
    
    [self createNewCertificate:&x509 withPrivateKey:&key andExpiresIn:365
                   andWithName:commonName andEmailAddress:emailAddress 
                    andCountry:country andCity:city andOrganization:organization 
           andOrganizationUnit:organizationUnit];
    
	CRYPTO_cleanup_all_ex_data();
    
	CRYPTO_mem_leaks(bio_err);
	BIO_free(bio_err);
    
    i2d_X509_bio(outCert, x509);

    char *outputBuffer;
    long outputLength = BIO_get_mem_data(outCert, &outputBuffer);
    cert = [NSData dataWithBytes:outputBuffer length:outputLength];    
    
    BIO_free(outCert);
    X509_free(x509);
    
    return cert;
}


/**
 * createNewCertificate
 * This method creates a new certificate and sets the issuer and subject 
 * fields correctly. It sets both (issuer and subject) because of it's a 
 * self signed certificate. As parameters this method takes a reference to 
 * the certificate in which everything is stored, then a reference to the 
 * users private key (should be RSA) and a serial number and a expiration 
 * date. Furthermore it sets the users issuer and subject attributes such as 
 * common name, email address, country, city, organization and organization unit.
 */
- (void) createNewCertificate:(X509**)x509p
               withPrivateKey:(EVP_PKEY**)pkeyp
                 andExpiresIn:(int)days
                  andWithName:(NSString*)commonName
              andEmailAddress:(NSString*)emailAddress
                   andCountry:(NSString*)country
                      andCity:(NSString*)city
              andOrganization:(NSString*)organization
          andOrganizationUnit:(NSString*)organizationUnit {
	X509 *x;
	EVP_PKEY *pk;
	X509_NAME *name = NULL;
	
    //debug
    if (*pkeyp == NULL) {
        [self throwWithText:@"Private key was null. This should not happen! You have to initialize it before calling createNewCertificate"];
    }
    pk= *pkeyp;
    x = X509_new();
    
    //x509 stuff
	X509_set_version(x, 2);
    
    //creating new serial number (64 bit)
    ASN1_INTEGER *sno = ASN1_INTEGER_new();
    BIGNUM *b = BN_new();
    if (!BN_pseudo_rand(b, 64, 0, 0)) {
        [self throwWithText:@"Creating random serial number failed"];
    }
    BN_to_ASN1_INTEGER(b, sno);
    
    //setting serial number
    X509_set_serialNumber(x, sno); //todo use this for a random serial number
    //int serial = 123456789;
    //ASN1_INTEGER_set(X509_get_serialNumber(x), serial);
    
    
    //debug test!!!
//    BIO *stdoutput = BIO_new_fp(stdout, BIO_NOCLOSE);
//    BN_print(stdoutput, b); //todo
//    
	X509_gmtime_adj(X509_get_notBefore(x), 0);
	X509_gmtime_adj(X509_get_notAfter(x), (long)60*60*24*days);
	X509_set_pubkey(x, pk);
    
    //retrieving X509_name
	name = X509_get_subject_name(x);

    //adding basic information about issuer and subject to certificate
    if ([country length] != 0)
        [self addTextEntryToCert:&name forKey:@"C" withValue:country];
    if ([commonName length] != 0)
        [self addTextEntryToCert:&name forKey:@"CN" withValue:commonName];
    if ([city length] != 0)
        [self addTextEntryToCert:&name forKey:@"L" withValue:city];
    if ([organization length] != 0)
        [self addTextEntryToCert:&name forKey:@"O" withValue:organization];
    if ([organizationUnit length] != 0)
        [self addTextEntryToCert:&name forKey:@"OU" withValue:organizationUnit];
    if ([emailAddress length] != 0)
        [self addTextEntryToCert:&name forKey:@"emailAddress" withValue:emailAddress];

    
	//setting issuer and subject to the same cuz of its self signed
	X509_set_issuer_name(x, name);
    
    //adding certificate extensions
    [self addExtensionToCert:x withId:NID_basic_constraints andValue:@"critical,CA:TRUE"];
    [self addExtensionToCert:x withId:NID_subject_key_identifier andValue:@"hash"];

	if (!X509_sign(x, pk, EVP_sha1())) {
        [self throwWithText:@"X509 sign failed"];
    }
    
	*x509p=x;
	*pkeyp=pk;
}


/**
 * addTextEntryToCert
 * This method adds text extension to a given certificate.
 * It sets the issuer and subject values such as 'Common Name', 
 * 'Location', 'Country', 'Email Address' and so on...
 */
- (void) addTextEntryToCert:(X509_NAME**)name
                     forKey:(NSString*)key
                  withValue:(NSString*)value {
    //adding text entry to certificate
    X509_NAME_add_entry_by_txt(*name, [key cStringUsingEncoding:NSUTF8StringEncoding],
                               MBSTRING_ASC, (unsigned char*)[value cStringUsingEncoding:NSUTF8StringEncoding], 
                               -1, -1, 0);
}

/**
 * addExtensionToCert
 * This sets the cert extensions such as basic constraints, 
 * subject key identifiers and so on...
 */
- (void) addExtensionToCert:(X509*)cert
                     withId:(int)nid
                   andValue:(NSString*)value {
	X509_EXTENSION *ex;
	X509V3_CTX ctx;
	
    //setting extension context
	X509V3_set_ctx_nodb(&ctx);
	
    //issuer and subject cert is the same cuz of self signed
	X509V3_set_ctx(&ctx, cert, cert, NULL, NULL, 0);
	ex = X509V3_EXT_conf_nid(NULL, &ctx, nid, (char*)[value cStringUsingEncoding:NSUTF8StringEncoding]);
	if (!ex) {
        [self throwWithText:@"Adding extension to cert failed"];
    }
    
    //adding extension to cert
	X509_add_ext(cert, ex, -1);
	X509_EXTENSION_free(ex);
}

//openssl cert creationc allback method
static void callback(int p, int n, void *arg)
{
	char c='B';
    
	if (p == 0) c='.';
	if (p == 1) c='+';
	if (p == 2) c='*';
	if (p == 3) c='\n';
	fputc(c, stderr);
}


/* throwWithText
 * This method throws a objective c exception with the 
 * corresponding OpenSSL error and a user defined message.
 */
- (void) throwWithText:(NSString*)message {
    [NSException raise:@"Crypto error occured" 
                format:@"%@. OpenSSL Errorcode: %s", message, 
     ERR_reason_error_string((unsigned long)ERR_get_error())];
}

@end
