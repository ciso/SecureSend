//
//  ContainerEditAlertViewHandler.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 31.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ContainerEditAlertViewHandler.h"

@implementation ContainerEditAlertViewHandler

@synthesize caller = _caller;
@synthesize cell = _cell;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0) {
        NSLog(@"Clicked");
        
        NSString *name = [alertView textFieldAtIndex:0].text;
        
        [self.caller performSelector:@selector(userRenamedContainer:inCell:) withObject:name withObject:self.cell];
    }
    
    self.caller = nil;
    self.cell = nil;
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    NSLog(@"cancel");
}

@end
