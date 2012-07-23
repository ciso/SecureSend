//
//  RecipientDetailViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 23.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "RecipientDetailViewController.h"
#import "Recipient.h"
#import "KeyChainManager.h"

@interface RecipientDetailViewController ()

@end

@implementation RecipientDetailViewController

@synthesize recipient = _recipient;

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
    
    self.title = @"Info";
    
    
    //NSLog(@"details for: %@ %@", firstname, lastname);
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1; 
    }
    else if (section == 1)
    {
        return 2;
    }
    else if (section == 2)
    {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *title = @"";
    NSString *detail = @"";
    
    if (indexPath.section == 0 && indexPath.row == 0)
    { 
        NSString* firstname = (__bridge NSString*) ABRecordCopyValue(self.recipient.recordRef,kABPersonFirstNameProperty);
        NSString* lastname = (__bridge NSString*) ABRecordCopyValue(self.recipient.recordRef, kABPersonLastNameProperty);
        
        title = @"Name";
        detail = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
        
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(self.recipient.recordRef, kABPersonPhoneProperty);
        NSString *phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        
        title = @"Phone";
        detail = phone;
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        ABMultiValueRef mailAddresses = ABRecordCopyValue(self.recipient.recordRef, kABPersonEmailProperty);
        NSString *email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(mailAddresses, 0);

        title = @"Email";
        detail = email;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        title = @"Expires";
        
        NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        NSString *datestring = [NSString stringWithFormat:@"%@", [formatter stringFromDate:self.recipient.expirationDate]];
        
        detail = datestring;

        
    }
     
    // Configure the cell...
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    
    
    return cell;
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

@end
