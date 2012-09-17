//
//  InfoViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 31.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "InfoViewController.h"
#import "TestFlight.h"
#import "LoadingView.h"

@interface InfoViewController ()

@property (nonatomic, strong) UIView *loadingView;

@end

@implementation InfoViewController

@synthesize webView;
@synthesize loadingView = _loadingView;

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

- (void)showLoadingView {
    UIView *load = [LoadingView showLoadingViewInView:self.view.window withMessage:@"Loading ..."];
    self.loadingView = load;
}

- (void)hideLoadingView {
    [self.loadingView removeFromSuperview];
}


# pragma mark - WebView Delegates
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self showLoadingView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideLoadingView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideLoadingView];
    
    //showing alert to enter code, setting rootviewcontroller as delegate
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not load from server" delegate:nil cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
