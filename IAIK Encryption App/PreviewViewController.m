//
//  PreviewViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 13.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "PreviewViewController.h"
#import "ContainerDetailViewController.h"
#import "CertificateXplorerViewController.h"
#import "FilePathFactory.h"
#import "ChooseContainerViewController.h"
#import "ChoosedContainerDelegate.h"
#import "CustomTabBarController.h"

#define SEGUE_TO_ENCRYPT @"toEncryptAndSend"
#define SEGUE_TO_CHOOSE_CONTROLLER @"toChooseContainer"


@interface PreviewViewController ()

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation PreviewViewController
@synthesize toolbar            = _toolbar;
@synthesize webview            = _webview;
@synthesize popoverController  = _myPopoverController;
@synthesize path               = _path;
@synthesize image              = _image;
@synthesize documentController = _documentController;


#pragma mark - lifecycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    if(self.path)
    {
        [self refreshPreview];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.webview removeFromSuperview];
    [self.image removeFromSuperview];
    
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CustomTabBarController *tabBar = (CustomTabBarController*)self.tabBarController;
    tabBar.landscapeAllowed = YES;
    
    [self hideTabBar:self.tabBarController];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    CustomTabBarController *tabBar = (CustomTabBarController*)self.tabBarController;
    tabBar.landscapeAllowed = NO;
    
    [self showTabBar:self.tabBarController];
}

- (void) hideTabBar:(UITabBarController *) tabbarcontroller 
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
        } 
        else 
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
        }
        
    }
    
    [UIView commitAnimations];
}

- (void) showTabBar:(UITabBarController *) tabbarcontroller {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        NSLog(@"%@", view);
        
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];
            
        } 
        else 
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
        }
        
        
    }
    
    [UIView commitAnimations]; 
}



- (void)viewDidUnload
{
    [self setToolbar:nil];
    [super viewDidUnload];
}


#pragma mark - Orientation methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark - methods for updating preview

-(void) refreshPreview
{
    if(self.image)
    {
        [self.image removeFromSuperview];
    }
    if(self.webview)
    {
        [self.webview removeFromSuperview];
    }
    
    NSString* pathextension = [self.path pathExtension];
    
    CGRect frame = self.view.frame;
    
    CGPoint center = CGPointMake(0, 0);
    
    frame.origin = center;
    
    if([pathextension isEqualToString:EXTENSION_JPG])
    {
        self.image = [[UIImageView alloc] initWithFrame:frame];
        
        self.image.contentMode = UIViewContentModeScaleAspectFit;
        
        self.image.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.image.backgroundColor = [UIColor blackColor]; 
        
        [self.view addSubview:self.image];
        
        [self.view sendSubviewToBack:self.image];
        
        UIImage* im = [UIImage imageWithContentsOfFile:self.path];
        [self.image setImage:im];
    }
    else if([pathextension isEqualToString:EXTENSION_PDF])
    {
        self.webview = [[UIWebView alloc] initWithFrame:frame];
        
        self.webview.backgroundColor = [UIColor blackColor];
        
        self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:self.webview];
        
        [self.view sendSubviewToBack:self.webview];
        
        NSURL* url = [NSURL fileURLWithPath:self.path];
        
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        
        [self.webview loadRequest:request];
    }
    self.navigationItem.title = [self.path lastPathComponent];
}



#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"modal"])
    {
   /*     
        if ([segue.destinationViewController isKindOfClass:[PageViewController class]])
        {
            SplitViewController *split = (SplitViewController*)self.splitViewController;
            
            ((PageViewController*)segue.destinationViewController).detail = split.detail;
        }
        
        if ([self.splitViewController isKindOfClass:[SplitViewController class]])
        {
            SplitViewController *split = (SplitViewController*)self.splitViewController;
            split.controller = segue.destinationViewController;
        }*/
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_ENCRYPT])
    {       
        //CertificateXplorerViewController *xplorer = segue.destinationViewController;
        //todo !!!!!
        /*UIViewController *detail = ((SplitViewController*)self.splitViewController).detail;
        if ([detail isKindOfClass:[ContainerDetailViewController class]])
        {
            xplorer.delegate = (ContainerDetailViewController*)detail;
        }*/
    } 
    else if([segue.identifier isEqualToString:SEGUE_TO_CHOOSE_CONTROLLER])
    {
       // self.receivedFileURL = (NSURL*)sender;
        
        //UINavigationController* nav = (UINavigationController*) segue.destinationViewController;
        
        /*ChooseContainerViewController* choose = (ChooseContainerViewController*) [nav.viewControllers objectAtIndex:0];*/
       /* 
        ChooseContainerViewController *choose = (ChooseContainerViewController*)segue.destinationViewController;
        
        choose.containers = self.secureContainers;
        choose.delegate = self;*/
    }

}


- (IBAction)buttonEncryptAndSend:(id)sender 
{
    NSLog(@"ENCRYPT AND SEND");
    
}

-(void) choosedContainer:(NSInteger) index
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)exportButtonClicked:(UIBarButtonItem *)sender {
    
    //showing alert to enter code, setting rootviewcontroller as delegate
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"You are leaving this application"
                                                    message:@"This document will be copied into the new application's document folder.\nTherefore it might be insecure!"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    
    [alert show];
    
    //[self export];
}

- (void)export {
    self.documentController =
    [UIDocumentInteractionController
     interactionControllerWithURL:[NSURL fileURLWithPath:self.path]];
    
    self.documentController.delegate = self;
    
    self.documentController.UTI = @"com.adobe.pdf";
    [self.documentController presentOpenInMenuFromRect:CGRectZero
                                                inView:self.view
                                              animated:YES];
}

#pragma mark - Document Interaction Delegates
-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    
}

-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    
}


#pragma mark - Alert View Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:0 animated:NO];
    if(buttonIndex != 0)
    {
        [self export];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    
}

@end
