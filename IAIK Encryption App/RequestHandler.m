//
//  RequestHandler.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "RequestHandler.h"
#import "RootViewController.h"

@implementation RequestHandler

@synthesize request = _request;
@synthesize delegate = _delegate;

- (void)requestReceived
{
    
    //showing alert to enter code, setting rootviewcontroller as delegate
    NSString *title = NSLocalizedString(@"You have received a Certificate-Request from another user. This app will guide you through the certificate exchange process.\n\n"
    @"It opens the Mail and Message composer for you.\n\n"
    @"You must only click 'send' in the composers.\n", @"Title of alert view in request handler");
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button text in alert view") otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    alert.delegate = self;
    [alert show];
}


#pragma mark - UIAlertViewDelegateMethods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != 0)
    {
        //[self.delegate performSelectorOnMainThread:@selector(manageCertificateRequest:) withObject:self.request waitUntilDone:NO];
        [(RootViewController*)self.delegate manageCertificateRequest:self.request];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    
}


@end
