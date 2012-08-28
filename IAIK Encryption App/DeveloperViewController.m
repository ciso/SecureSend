//
//  DeveloperViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 21.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "DeveloperViewController.h"
#import "TestFlight.h"

@interface DeveloperViewController ()

@end

@implementation DeveloperViewController

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)resetUserDefaults:(UIButton *)sender {    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"prevStartupVersions"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)openFeedback:(UIButton *)sender {
    [TestFlight openFeedbackView];
}
@end
