//
//  TutorialViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 20.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController
@synthesize pageControlOutlet = _pageControlOutlet;
@synthesize scrollViewOutlet  = _scrollViewOutlet;
@synthesize root               = _root;

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
	// Do any additional setup after loading the view.
    
    self.pageControl = self.pageControlOutlet;
    self.scrollView = self.scrollViewOutlet;
    self.delegate = self;
    
    UIImage *tutImage1 = [UIImage imageNamed:@"tut1"];
    UIImage *tutImage2 = [UIImage imageNamed:@"tut2"];
    UIImage *tutImage3 = [UIImage imageNamed:@"tut3"];
    UIImage *tutImage4 = [UIImage imageNamed:@"tut4"];
    UIImage *tutImage5 = [UIImage imageNamed:@"tut5"];

    [self.pages addObject:tutImage1];
    [self.pages addObject:tutImage2];
    [self.pages addObject:tutImage3];
    [self.pages addObject:tutImage4];
    [self.pages addObject:tutImage5];

    [self initialized];
    
}

- (void)viewDidUnload
{
    [self setPageControlOutlet:nil];
    [self setScrollViewOutlet:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    pageControlBeingUsed = NO;
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    pageControlBeingUsed = NO;
//}

- (IBAction)nextButtonClicked:(UIBarButtonItem *)sender {
    if (!self.isOnLastPage) {
        [self next];
    }
    else {
        [self close];
    }
}

- (IBAction)skipButtonClicked:(UIBarButtonItem *)sender {
    [self close];
}

- (void)close {
    if ([self.root respondsToSelector:@selector(getStartedViewClosed)]) {
        [self dismissModalViewControllerAnimated:NO];
        [self.root performSelector:@selector(getStartedViewClosed)];
    }
    else {
      [self dismissModalViewControllerAnimated:YES];  
    }
}

- (void)userClickedNextOnLastPage {
    NSLog(@"last clicked...");
}

- (void)userEnteredLastPage {
    NSLog(@"user entered last page");
    
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;
    item.title = @"Start";
    [self.navigationItem setRightBarButtonItem:item animated:YES];}

- (void)userLeftLastPage {
    NSLog(@"user left last page");
    
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;
    item.title = @"Next";
    [self.navigationItem setRightBarButtonItem:item animated:YES];
}

@end
