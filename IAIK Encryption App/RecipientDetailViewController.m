//
//  RecipientDetailViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 23.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <QuartzCore/QuartzCore.h>
#import "RecipientDetailViewController.h"
#import "Recipient.h"
#import "KeyChainStore.h"
#import "X509CertificateUtil.h"

@interface RecipientDetailViewController ()

@property (nonatomic, strong) NSData *certificate;

@end

@implementation RecipientDetailViewController

@synthesize recipient = _recipient;
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
    
    self.title = @"Info";
    NSString* identifier = [NSString stringWithFormat:@"%d", ABRecordGetRecordID(self.recipient.recordRef)];
    self.certificate = [KeyChainStore dataForKey:identifier type:kDataTypeCertificate];
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
        return 7;
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
        UITableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
        newCell.backgroundColor = [UIColor clearColor];
        newCell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        NSString *firstname = (__bridge NSString*) ABRecordCopyValue(self.recipient.recordRef,kABPersonFirstNameProperty);
        NSString *lastname = (__bridge NSString*) ABRecordCopyValue(self.recipient.recordRef, kABPersonLastNameProperty);
        //ABPersonCopyImageDataWithFormat
        NSData *profileImage = (__bridge NSData*)ABPersonCopyImageDataWithFormat(self.recipient.recordRef, kABPersonImageFormatThumbnail);
        
        UIImage *image = [UIImage imageWithData:profileImage];
        
        UIImageView *imageView = (UIImageView*)[newCell viewWithTag:100];
        UILabel *detailLabel = (UILabel*)[newCell viewWithTag:101];
                
        imageView.layer.masksToBounds = YES;
        imageView.layer.borderColor = [UIColor blackColor].CGColor;
        imageView.layer.borderWidth = 1;
        imageView.layer.cornerRadius = 5.0;

        
        //title = @"Name";
        //detail = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
        
        imageView.image = image;
        detailLabel.text = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
        
        cell = newCell;
        
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
        title = @"Name";

        detail = [X509CertificateUtil getCommonName:self.certificate];
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        title = @"Email";
        
        detail = [X509CertificateUtil getEmail:self.certificate];
    }
    else if (indexPath.section == 2 && indexPath.row == 2)
    {
        title = @"Expires";
        
        NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        NSString *datestring = [NSString stringWithFormat:@"%@", [formatter stringFromDate:self.recipient.expirationDate]];
        
        detail = datestring;
    }
    else if (indexPath.section == 2 && indexPath.row == 3)
    {
        title = @"Serial";
        
        detail = [X509CertificateUtil getSerialNumber:self.certificate];
    }
    else if (indexPath.section == 2 && indexPath.row == 4)
    {
        title = @"Org.";
        
        detail = [X509CertificateUtil getOrganization:self.certificate];
    }
    else if (indexPath.section == 2 && indexPath.row == 5)
    {
        title = @"Org. Unit";
        
        detail = [X509CertificateUtil getOrganizationUnit:self.certificate];
    }
    else if (indexPath.section == 2 && indexPath.row == 6)
    {
        title = @"City";
        
        detail = [X509CertificateUtil getCity:self.certificate];
    }
     
    // Configure the cell...
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *ret = nil;
    
    if (section == 1) {
        ret = @"General";
    }
    else if (section == 2) {
        ret = @"Certificate";
    }
    
    return ret;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 70.0;
    }
    else {
        return 44.0;
    }
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
