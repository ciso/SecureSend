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

#define SEGUE_TO_ENCRYPT @"toEncryptAndSend"
#define SEGUE_TO_CHOOSE_CONTROLLER @"toChooseContainer"


@interface PreviewViewController ()

@property (nonatomic, retain) UIPopoverController *popoverController;

@end

@implementation PreviewViewController
@synthesize toolbar = _toolbar;
@synthesize webview = _webview;
@synthesize receivedFileURL = _receivedFileURL;
@synthesize secureContainers = _secureContainers;
@synthesize popoverController = _myPopoverController;
@synthesize displayContainerView = _displayContainerView;
@synthesize path = _path;
@synthesize image = _image;


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
        self.receivedFileURL = (NSURL*)sender;
        
        //UINavigationController* nav = (UINavigationController*) segue.destinationViewController;
        
        /*ChooseContainerViewController* choose = (ChooseContainerViewController*) [nav.viewControllers objectAtIndex:0];*/
        
        ChooseContainerViewController *choose = (ChooseContainerViewController*)segue.destinationViewController;
        
        choose.containers = self.secureContainers;
        choose.delegate = self;
    }

}


- (IBAction)buttonEncryptAndSend:(id)sender 
{
    NSLog(@"ENCRYPT AND SEND");
    
}

- (void)showContainerView
{
    /*SplitViewController *split = (SplitViewController*)self.splitViewController;
    
    [split.controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:split.controller animated:YES];*/
}


-(void) choosedContainer:(NSInteger) index
{
    
    [self dismissModalViewControllerAnimated:YES];
    
    //[self performSegueWithIdentifier:SEGUE_TO_DETAIL sender:[self.containers objectAtIndex:index]];
    
    
    //ContainerDetailViewController* detail = (ContainerDetailViewController*) [segue destinationViewController];
    /*
    ContainerDetailViewController *detail;// = ((SplitViewController*)self.splitViewController).detail;
    
    if (((SplitViewController*)self.splitViewController).detail == nil)
    {
        detail = [[ContainerDetailViewController alloc] init];
        
        SplitViewController *split = (SplitViewController*)self.splitViewController;
        
        split.detail = detail;
    }
    else
    {
        detail = ((SplitViewController*)self.splitViewController).detail;
    }
    
    SecureContainer* container = (SecureContainer*) [self.secureContainers objectAtIndex:index];
    
    [detail setContainer:container];
    
    if(self.receivedFileURL != nil)
    {
        NSString* filename = [[self.receivedFileURL lastPathComponent] stringByDeletingPathExtension];
        
        NSString* path = [FilePathFactory getUniquePathInFolder:container.basePath forFileExtension:[self.receivedFileURL pathExtension] andFileName:filename];
        
        NSData* recfile = [NSData dataWithContentsOfURL:self.receivedFileURL];
        
        BOOL success = [recfile writeToFile:path options:NSDataWritingFileProtectionComplete error:nil];
        
        if(success == NO)
        {
            NSLog(@"error saving file");
        }
        
        [detail addFilesToContainer:[NSArray arrayWithObject:path]];
        
        [detail.tableView reloadData]; //test
        
        [[NSFileManager defaultManager] removeItemAtURL:self.receivedFileURL error:nil];
    }
    
    self.receivedFileURL = nil;*/
    
    
}


- (void)dealloc {

}
@end
