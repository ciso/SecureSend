//
//  Base64.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 10.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Base64.h"
#include <openssl/bio.h>
#include <openssl/evp.h>

#define BUFFSIZE 256

@implementation Base64

+ (NSString*)encode:(NSData*)data
{
    //creating openssl context
    BIO *context = BIO_new(BIO_s_mem());
    
    //setting up context for base64 encoding
    BIO *command = BIO_new(BIO_f_base64());
    context = BIO_push(command, context);
    
    //prevent of new lines
    BIO_set_flags(context, BIO_FLAGS_BASE64_NO_NL);
    
    //encode
    BIO_write(context, [data bytes], [data length]);
    int temp __attribute__((unused)) =  BIO_flush(context);
    
    //adapt BIO into NSString
    char *outputBuffer = NULL;
    long outputLength __attribute__((unused)) = BIO_get_mem_data(context, &outputBuffer);
//    NSString *encodedString = [NSString
//                               stringWithCString:outputBuffer
//                               length:outputLength];
    
    NSString *encodedString = [NSString stringWithUTF8String:outputBuffer];//[NSString stringWithCString:outputBuffer encoding:NSUTF8StringEncoding];

    BIO_free_all(context);
    
    return encodedString;
}

+ (NSData*)decode:(NSString*)decode
{
    decode = [decode stringByAppendingString:@"\n"];
    NSData *data = [decode dataUsingEncoding:NSASCIIStringEncoding];
    
    //creating openssl context
    BIO *command = BIO_new(BIO_f_base64());
    BIO *context = BIO_new_mem_buf((void *)[data bytes], [data length]);
    
    context = BIO_push(command, context);
    
    //decode
    NSMutableData *outputData = [NSMutableData data];
    
    int len;
    char inbuf[BUFFSIZE];
    while ((len = BIO_read(context, inbuf, BUFFSIZE)) > 0)
    {
        [outputData appendBytes:inbuf length:len];
    }
    
    BIO_free_all(context);
    [data self]; // extend GC lifetime of data to here
    
    return outputData;
}


@end
