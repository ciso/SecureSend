//
//  Base64.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 10.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Base64 : NSObject

//+ (NSString*)encode:(NSData*)data;
//+ (NSData*)decode:(NSString*)decode;
+ (NSData*)base64DataFromString: (NSString*)string;
+ (NSString *) base64StringFromData: (NSData *)data length: (int)length;

@end
