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
    return 4;
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
    else if (section == 3) {
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
    
    
    if (indexPath.section == 3 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DeleteCell"];

        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        UIButton *button = (UIButton*)[cell viewWithTag:300];
        
        //setting up button
        button.layer.cornerRadius = 5.0;
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = button.layer.bounds;
        
        NSLog(@"%f, %f", button.layer.bounds.size.width, button.layer.bounds.size.height);
        
        gradientLayer.colors = [NSArray arrayWithObjects:
                                (id)[UIColor colorWithRed:240/255.0f green:124/255.0f blue:132/255.0f alpha:1.0f].CGColor,
                                (id)[UIColor colorWithRed:237/255.0f green:19/255.0f blue:19/255.0f alpha:1.0f].CGColor,
                                nil];
        
        gradientLayer.locations = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0.0f],
                                   [NSNumber numberWithFloat:1.0f],
                                   nil];
        
        gradientLayer.cornerRadius = button.layer.cornerRadius;
        [button.layer insertSublayer:gradientLayer atIndex:0];
        
        button.layer.masksToBounds = YES;
        button.titleLabel.textColor = [UIColor whiteColor];
        
        //text shadow
        button.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        button.titleLabel.layer.shadowOpacity = 0.3f;
        button.titleLabel.layer.shadowRadius = 1;
        button.titleLabel.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        
        //border
        button.layer.borderColor = [UIColor colorWithRed:237/255.0f green:19/255.0f blue:19/255.0f alpha:0.5f].CGColor;
        button.layer.borderWidth = 1.0f;


    }
    
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

- (IBAction)deleteButtonClicked:(UIButton *)sender {
    ABRecordRef ref = self.recipient.recordRef;
    
    NSString* identifier = [NSString stringWithFormat:@"%d",ABRecordGetRecordID(ref)];
    
    
    if (![KeyChainStore removeItemForKey:identifier type:kDataTypeCertificate])
    {
        NSLog(@"Could not delete certificate in keychain");
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
