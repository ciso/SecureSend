//
//  InfoViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 31.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "InfoViewController.h"
#import "TestFlight.h"

@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    NSString *path = [[NSBundle mainBundle] bundlePath];
//    NSURL *baseURL = [NSURL fileURLWithPath:path];
//    NSString *pathToFile = [[NSBundle mainBundle] pathForResource:@"info" ofType:@"html"];
//    NSString* htmlString = [NSString stringWithContentsOfFile:pathToFile encoding:NSUTF8StringEncoding error:nil];
//    [webView loadHTMLString:htmlString baseURL:baseURL];
//    
    NSString *urlAddress = @"http://cstromberger.at/securesend/info.html";
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [self.webView loadRequest:requestObj];
    
    self.webView.delegate = self;
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)closeButtonClicked:(UIBarButtonItem *)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)feedbackButtonClicked:(UIBarButtonItem *)sender {
    [TestFlight openFeedbackView];
}

- (BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {    
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end
