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
@synthesize scrollViewOutlet = _scrollViewOutlet;

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
    
    UIImage *newImage = [UIImage imageNamed:@"tut1"];
    [self.pages addObject:newImage];
    [self.pages addObject:newImage];
    [self.pages addObject:newImage];
    [self.pages addObject:newImage];
    
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
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)skipButtonClicked:(UIBarButtonItem *)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)userClickedNextOnLastPage {
    NSLog(@"last clicked...");
}

- (void)userEnteredLastPage {
    NSLog(@"user entered last page");
    
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;
    item.title = @"Done";
    [self.navigationItem setRightBarButtonItem:item animated:YES];}

- (void)userLeftLastPage {
    NSLog(@"user left last page");
    
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;
    item.title = @"Next";
    [self.navigationItem setRightBarButtonItem:item animated:YES];
}

@end
