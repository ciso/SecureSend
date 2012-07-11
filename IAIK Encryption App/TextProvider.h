//
//  TextProvider.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextProvider : NSObject

+ (NSString*)getEmailBodyForRecipient:(NSString*)recipient;

@end
