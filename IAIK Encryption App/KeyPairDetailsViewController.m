//
//  KeyPairDetailsViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 01.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "KeyPairDetailsViewController.h"
#import "KeyPair.h"
#import "X509CertificateUtil.h"

@interface KeyPairDetailsViewController ()

@end

@implementation KeyPairDetailsViewController

@synthesize keyPair = _keyPair;

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

    self.tableView.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSData *certificate = [self.keyPair certificate];
    NSData *privateKey = [self.keyPair privateKey];
    
    NSString *title = @"";
    NSString *detail = @"";
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        title = @"SNo";
        detail = [X509CertificateUtil getSerialNumber:certificate];
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        title = @"CN";
        detail = [];
    }
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Certificate";
    else if (section == 1)
        return @"Private Key";
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
