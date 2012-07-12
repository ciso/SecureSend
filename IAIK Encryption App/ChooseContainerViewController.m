//
//  ChooseContainerViewController.m
//  IAIK Encryption App
//
//  Created by Christoph Hechenblaikner on 17.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChooseContainerViewController.h"
#import "SecureContainer.h"
#import "ContainerDetailViewController.h"

@interface ChooseContainerViewController ()

@end

@implementation ChooseContainerViewController

@synthesize containers = _containers, delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.containers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SecureContainer* current = [self.containers objectAtIndex:indexPath.row];
    cell.textLabel.text = current.name;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate choosedContainer:indexPath.row];
}

-(IBAction)didCancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
