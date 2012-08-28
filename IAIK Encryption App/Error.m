//
//  Error.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 28.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Error.h"
#import "TestFlight.h"

@implementation Error

+ (void)log:(NSError*)error {
    //beta
    [TestFlight passCheckpoint:[error localizedDescription]];
    
    NSLog(@"Error: %@", [error localizedDescription]);
}


@end
