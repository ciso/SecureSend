//
//  RecipientsViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 23.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "RecipientsViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/ABAddressBook.h>
#import "Recipient.h"
#import "Crypto.h"
#import "RecipientDetailViewController.h"
#import "KeyChainStore.h"

#define SEGUE_TO_DETAIL @"segueToRecipientDetail"

@interface RecipientsViewController ()

@property (nonatomic, strong) NSMutableArray *recipients;

@end

@implementation RecipientsViewController

@synthesize recipients = _recipients;

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
    
    //self.tableView.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
    
    
}

- (void)loadRecipients {
    
    ABAddressBookRef addressbookref = ABAddressBookCreate();
    NSArray* allpeople = (__bridge NSArray*) ABAddressBookCopyArrayOfAllPeople(addressbookref);
    
    Crypto* crypto = [Crypto getInstance];
    
    self.recipients = [[NSMutableArray alloc] init];
    
    
    for(int i = 0; i < allpeople.count; i++)
    {
        ABRecordRef ref = (__bridge_retained  ABRecordRef)[allpeople objectAtIndex:i];
        
        NSString* identifier = [NSString stringWithFormat:@"%d", ABRecordGetRecordID(ref)];
        
        NSData *cert = [KeyChainStore dataForKey:identifier type:kDataTypeCertificate];
        
        if(cert != nil)
        {
            
            Recipient *recipient = [[Recipient alloc] init];
            recipient.recordRef = ref;
            recipient.expirationDate = [crypto getExpirationDateOfCertificate:cert];
            
            [self.recipients addObject:recipient];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadRecipients];
    [self.tableView reloadData];
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
    NSLog(@"Creating tableview section with %d rows", [self.recipients count]);
    return [self.recipients count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    Recipient *recipient = [self.recipients objectAtIndex:indexPath.row];
        
    NSString* firstname = (__bridge NSString*) ABRecordCopyValue(recipient.recordRef,kABPersonFirstNameProperty);
    NSString* lastname = (__bridge NSString*) ABRecordCopyValue(recipient.recordRef, kABPersonLastNameProperty);
    
    NSString* name = [firstname stringByAppendingFormat:@" %@",lastname];
    
    cell.textLabel.text = name;
    
    //creating formatter and displaying expiration date
//    NSDateFormatter* formatter= [[NSDateFormatter alloc] init];
//    
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    
//    NSString *datestring = [NSString stringWithFormat:@"Certificate expires on %@", [formatter stringFromDate:recipient.expirationDate]];
//    
   // cell.detailTextLabel.text = datestring;
    
    //NSLog(@"Recipient: %x, expiration date: %@", recipient.recordRef, recipient.expirationDate);
    
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
    [self performSegueWithIdentifier:SEGUE_TO_DETAIL sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_TO_DETAIL])
    {
        if ([segue.destinationViewController isMemberOfClass:[RecipientDetailViewController class]])
        {
            RecipientDetailViewController *view = segue.destinationViewController;
            view.recipient = [self.recipients objectAtIndex:((NSIndexPath*)sender).row];
        }
    }
}

@end
