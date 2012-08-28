//
//  Error.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 28.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Error : NSObject

+ (void)log:(NSError*)error;

@end
