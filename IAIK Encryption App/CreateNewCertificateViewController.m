//
//  CreateNewCertificateViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 24.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CreateNewCertificateViewController.h"
#import "KeyChainManager.h"

@interface CreateNewCertificateViewController ()

@end

@implementation CreateNewCertificateViewController

@synthesize certificate = _certificate;

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
    
    //check if the user is obtaining his first certificate
    //or renewing an old one
    self.certificate = [KeyChainManager getCertificateofOwner:CERT_ID_USER];
    
    if (self.certificate != nil)
    {
        NSLog(@"The user does already have a certificate!");
    }

    
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = 0;
    if (section == 0)
    {
        ret = 3;
    }
    else if (section == 1)
    {
        ret = 4;
    }
    
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:100];
    UITextField *textfield = (UITextField*)[cell viewWithTag:101];
    
    NSString *title = @"";
    NSString *detail = @"";
    NSString *placeholder = @"";
    
    //section 1
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        title = @"Firstname";
        detail = @"";
        placeholder = @"Max";
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        title = @"Lastname";
        detail = @"";
        placeholder = @"Mustermann";
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        title = @"Email";
        detail = @"";
        placeholder = @"max@mustermann.at";
    }
    //section 2
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        title = @"Country";
        detail = @"";
        placeholder = @"AT";
        //country, city, organization, organization unit
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        title = @"City";
        detail = @"";
        placeholder = @"Graz";
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        title = @"Organization";
        detail = @"";
        placeholder = @"Graz University of Technology";
    }
    else if (indexPath.section == 1 && indexPath.row == 3)
    {
        title = @"Org. Unit";
        detail = @"";
        placeholder = @"IAIK";
    }
    
    titleLabel.text = title;
    textfield.text = detail;
    textfield.placeholder = placeholder;
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *ret = nil;
    if (section == 0)
    {
        ret = @"Mandatory Fields";
    }
    else if (section == 1)
    {
        ret = @"Optional Fields";
    }
    
    return ret;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *ret = nil;
    if (section == 0)
    {
        ret = @"Maecenas sed diam eget risus varius blandit sit amet non magna. Integer posuere erat a ante venenatis dapibus posuere velit aliquet.";
    }
    else if (section == 1)
    {
        ret = @"Etiam porta sem malesuada magna mollis euismod.";
    }
    
    return ret;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveButtonClicked:(UIBarButtonItem *)sender {
}

@end
