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

//+ (NSString*)encode:(NSData*)data
//{
//    //creating openssl context
//    BIO *context = BIO_new(BIO_s_mem());
//    
//    //setting up context for base64 encoding
//    BIO *command = BIO_new(BIO_f_base64());
//    context = BIO_push(command, context);
//    
//    //prevent of new lines
//    //BIO_set_flags(context, BIO_FLAGS_BASE64_NO_NL);
//    
//    //encode
//    BIO_write(context, [data bytes], [data length]);
//    int temp __attribute__((unused)) =  BIO_flush(context);
//    
//    //adapt BIO into NSString
//    char *outputBuffer = NULL;
//    long outputLength __attribute__((unused)) = BIO_get_mem_data(context, &outputBuffer);
////    NSString *encodedString = [NSString
////                               stringWithCString:outputBuffer
////                               length:outputLength];
//    
//    NSString *encodedString = [NSString stringWithUTF8String:outputBuffer];//[NSString stringWithCString:outputBuffer encoding:NSUTF8StringEncoding];
//
//    BIO_free_all(context);
//    
//    return encodedString;
//}
//
//+ (NSData*)decode:(NSString*)decode
//{
//    decode = [decode stringByAppendingString:@"\n"];
//    NSData *data = [decode dataUsingEncoding:NSASCIIStringEncoding];
//    
//    //creating openssl context
//    BIO *command = BIO_new(BIO_f_base64());
//    BIO *context = BIO_new_mem_buf((void *)[data bytes], [data length]);
//    
//    context = BIO_push(command, context);
//    
//    //decode
//    NSMutableData *outputData = [NSMutableData data];
//    
//    int len;
//    char inbuf[BUFFSIZE];
//    while ((len = BIO_read(context, inbuf, BUFFSIZE)) > 0)
//    {
//        [outputData appendBytes:inbuf length:len];
//    }
//    
//    BIO_free_all(context);
//    [data self]; // extend GC lifetime of data to here
//    
//    return outputData;
//}


static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};


+ (NSString *)encodeBase64WithString:(NSString *)strData {
    return [Base64 encodeBase64WithData:[strData dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)encodeBase64WithData:(NSData *)objData {
    const unsigned char * objRawData = [objData bytes];
    char * objPointer;
    char * strResult;
    
    // Get the Raw Data length and ensure we actually have data
    int intLength = [objData length];
    if (intLength == 0) return nil;
    
    // Setup the String-based Result placeholder and pointer within that placeholder
    strResult = (char *)calloc((((intLength + 2) / 3) * 4) + 1, sizeof(char));
    objPointer = strResult;
    
    // Iterate through everything
    while (intLength > 2) { // keep going until we have less than 24 bits
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
        *objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
        *objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];
        
        // we just handled 3 octets (24 bits) of data
        objRawData += 3;
        intLength -= 3;
    }
    
    // now deal with the tail end of things
    if (intLength != 0) {
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        if (intLength > 1) {
            *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
            *objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
            *objPointer++ = '=';
        } else {
            *objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
            *objPointer++ = '=';
            *objPointer++ = '=';
        }
    }
    
    // Terminate the string-based result
    *objPointer = '\0';
    
    // Return the results as an NSString object
    return [NSString stringWithCString:strResult encoding:NSASCIIStringEncoding];
}


+ (NSData *)decodeBase64WithString:(NSString *)strBase64 {
    const char *objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
    size_t intLength = strlen(objPointer);
    int intCurrent;
    int i = 0, j = 0, k;
    
    unsigned char *objResult = calloc(intLength, sizeof(unsigned char));
    
    // Run through the whole string, converting as we go
    while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
        if (intCurrent == '=') {
            if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
                // the padding character is invalid at this point -- so this entire string is invalid
                free(objResult);
                return nil;
            }
            continue;
        }
        
        intCurrent = _base64DecodingTable[intCurrent];
        if (intCurrent == -1) {
            // we're at a whitespace -- simply skip over
            continue;
        } else if (intCurrent == -2) {
            // we're at an invalid character
            free(objResult);
            return nil;
        }
        
        switch (i % 4) {
            case 0:
                objResult[j] = intCurrent << 2;
                break;
                
            case 1:
                objResult[j++] |= intCurrent >> 4;
                objResult[j] = (intCurrent & 0x0f) << 4;
                break;
                
            case 2:
                objResult[j++] |= intCurrent >>2;
                objResult[j] = (intCurrent & 0x03) << 6;
                break;
                
            case 3:
                objResult[j++] |= intCurrent;
                break;
        }
        i++;
    }
    
    // mop things up if we ended on a boundary
    k = j;
    if (intCurrent == '=') {
        switch (i % 4) {
            case 1:
                // Invalid state
                free(objResult);
                return nil;
                
            case 2:
                k++;
                // flow through
            case 3:
                objResult[k] = 0;
        }
    }
    
    // Cleanup and setup the return NSData
    NSData * objData = [[NSData alloc] initWithBytes:objResult length:j];
    free(objResult);
    return objData;
}




//static char base64EncodingTable[64] = {
//    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
//    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
//    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
//    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
//};
//
//
//+ (NSString *) base64StringFromData: (NSData *)data length: (int)length {
//    unsigned long ixtext, lentext;
//    long ctremaining;
//    unsigned char input[3], output[4];
//    short i, charsonline = 0, ctcopy;
//    const unsigned char *raw;
//    NSMutableString *result;
//    
//    lentext = [data length];
//    if (lentext < 1)
//        return @"";
//    result = [NSMutableString stringWithCapacity: lentext];
//    raw = [data bytes];
//    ixtext = 0;
//    
//    while (true) {
//        ctremaining = lentext - ixtext;
//        if (ctremaining <= 0)
//            break;
//        for (i = 0; i < 3; i++) {
//            unsigned long ix = ixtext + i;
//            if (ix < lentext)
//                input[i] = raw[ix];
//            else
//                input[i] = 0;
//        }
//        output[0] = (input[0] & 0xFC) >> 2;
//        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
//        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
//        output[3] = input[2] & 0x3F;
//        ctcopy = 4;
//        switch (ctremaining) {
//            case 1:
//                ctcopy = 2;
//                break;
//            case 2:
//                ctcopy = 3;
//                break;
//        }
//        
//        for (i = 0; i < ctcopy; i++)
//            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
//        
//        for (i = ctcopy; i < 4; i++)
//            [result appendString: @"="];
//        
//        ixtext += 3;
//        charsonline += 4;
//        
//        if ((length > 0) && (charsonline >= length))
//            charsonline = 0;
//    }     
//    return result;
//}
//
//
//+ (NSData *)base64DataFromString: (NSString *)string
//{
//    unsigned long ixtext, lentext;
//    unsigned char ch, inbuf[4], outbuf[3];
//    short i, ixinbuf;
//    Boolean flignore, flendtext = false;
//    const unsigned char *tempcstring;
//    NSMutableData *theData;
//    
//    if (string == nil)
//    {
//        return [NSData data];
//    }
//    
//    ixtext = 0;
//    
//    tempcstring = (const unsigned char *)[string UTF8String];
//    
//    lentext = [string length];
//    
//    theData = [NSMutableData dataWithCapacity: lentext];
//    
//    ixinbuf = 0;
//    
//    while (true)
//    {
//        if (ixtext >= lentext)
//        {
//            break;
//        }
//        
//        ch = tempcstring [ixtext++];
//        
//        flignore = false;
//        
//        if ((ch >= 'A') && (ch <= 'Z'))
//        {
//            ch = ch - 'A';
//        }
//        else if ((ch >= 'a') && (ch <= 'z'))
//        {
//            ch = ch - 'a' + 26;
//        }
//        else if ((ch >= '0') && (ch <= '9'))
//        {
//            ch = ch - '0' + 52;
//        }
//        else if (ch == '+')
//        {
//            ch = 62;
//        }
//        else if (ch == '=')
//        {
//            flendtext = true;
//        }
//        else if (ch == '/')
//        {
//            ch = 63;
//        }
//        else
//        {
//            flignore = true;
//        }
//        
//        if (!flignore)
//        {
//            short ctcharsinbuf = 3;
//            Boolean flbreak = false;
//            
//            if (flendtext)
//            {
//                if (ixinbuf == 0)
//                {
//                    break;
//                }
//                
//                if ((ixinbuf == 1) || (ixinbuf == 2))
//                {
//                    ctcharsinbuf = 1;
//                }
//                else
//                {
//                    ctcharsinbuf = 2;
//                }
//                
//                ixinbuf = 3;
//                
//                flbreak = true;
//            }
//            
//            inbuf [ixinbuf++] = ch;
//            
//            if (ixinbuf == 4)
//            {
//                ixinbuf = 0;
//                
//                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
//                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
//                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
//                
//                for (i = 0; i < ctcharsinbuf; i++)
//                {
//                    [theData appendBytes: &outbuf[i] length: 1];
//                }
//            }
//            
//            if (flbreak)
//            {
//                break;
//            }
//        }
//    }
//    
//    return theData;
//}


@end
