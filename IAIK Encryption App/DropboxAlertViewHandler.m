//
//  DropboxAlertViewHandler.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 29.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "DropboxAlertViewHandler.h"
#import "Email.h"

@implementation DropboxAlertViewHandler

@synthesize fileUrl  = _fileUrl;
@synthesize delegate = _delegate;

#pragma mark - UIAlertViewDelegateMethods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        Email *mail = [[Email alloc] init];
        mail.recipients = nil;
        mail.subject = @"I want to share my secure container with you";
        mail.body = [NSString stringWithFormat:@"I want to share my secure container with you using Dropbox.\n\nThe link is: %@", self.fileUrl];
        
        [self.delegate performSelectorOnMainThread:@selector(showEmailMessageComposer:) withObject:mail waitUntilDone:NO];
    }
    else if (buttonIndex == 2) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.fileUrl;
        self.fileUrl = nil;
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    NSLog(@"cancel");
}


@end
