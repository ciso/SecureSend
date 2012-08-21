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
@synthesize pageControlOutlet;
@synthesize scrollViewOutlet;

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
    
    self.scrollViewOutlet.delegate = self;
    
    
    NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor], nil];
    for (int i = 0; i < colors.count; i++) {
        CGRect frame;
        frame.origin.x = self.scrollViewOutlet.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollViewOutlet.frame.size;
        
        //UIView *subview = [[UIView alloc] initWithFrame:frame];
        //subview.backgroundColor = [colors objectAtIndex:i];
        UIImage *image = [UIImage imageNamed:@"tut1"];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:frame];
        imageview.image = image;
        
        [self.scrollViewOutlet addSubview:imageview];
    }
    
    self.scrollViewOutlet.contentSize = CGSizeMake(self.scrollViewOutlet.frame.size.width * colors.count, self.scrollViewOutlet.frame.size.height);
    
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

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollViewOutlet.frame.size.width;
    int page = floor((self.scrollViewOutlet.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControlOutlet.currentPage = page;
}


//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    pageControlBeingUsed = NO;
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    pageControlBeingUsed = NO;
//}

- (IBAction)nextButtonClicked:(UIBarButtonItem *)sender {
    CGRect frame;
    frame.origin.x = self.scrollViewOutlet.frame.size.width * (self.pageControlOutlet.currentPage + 1); //added +1
    frame.origin.y = 0;
    frame.size = self.scrollViewOutlet.frame.size;
    [self.scrollViewOutlet scrollRectToVisible:frame animated:YES];
}

- (IBAction)skipButtonClicked:(UIBarButtonItem *)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
