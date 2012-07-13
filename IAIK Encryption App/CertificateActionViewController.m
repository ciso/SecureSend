//
//  CertificateActionViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 13.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CertificateActionViewController.h"
#import "KeyChainManager.h"

#define SEGUE_TO_CERT_ASS @"toCertSendAssist"


@interface CertificateActionViewController ()

@end

@implementation CertificateActionViewController

@synthesize btConnectionHandler = _btConnectionHandler;
@synthesize receivedCertificateData = _receivedCertificateData;

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
    
    //setting background color to gray
    self.tableView.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
    
    //disabling scrolling
    self.tableView.scrollEnabled = NO;
    
    //allocating bluetooth connection handler
    self.btConnectionHandler = [[BluetoothConnectionHandler alloc] init];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //generics
    cell.textLabel.textColor = [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:51.0/255.0 alpha:1.0];

    //cell specific
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = @"Send Certificate via Bluetooth";
        cell.detailTextLabel.text = @"Send your certificate to another person via a Bluetooth connection";
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell.textLabel.text = @"Receive Certificate via BT";
        cell.detailTextLabel.text = @"Receive a certificate from another person via a Bluetooth connection";
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        cell.textLabel.text = @"Send Certificate via Email/SMS";
        cell.detailTextLabel.numberOfLines = 4;
        cell.detailTextLabel.text = @"Send your certificate to another person via a two-way exchange using Email for sending your certificate and SMS for an unique verification checksum";
    }    
    else if (indexPath.section == 0 && indexPath.row == 3)
    {
        cell.textLabel.text = @"Send a Certificate Request";
        cell.detailTextLabel.text = @"Send a certificate request to another person to obtain his/her certificate";
    }
    
    
      
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    //NSLog(@"width: %f", cell.detailTextLabel.frame.size.width);
    
    float padding = 10.0;
    
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    float descriptionHeight = labelSize.height;
    NSLog(@"DescriptionHeight: %f", descriptionHeight);
    
    labelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeClip];
    
    float titleHeight = labelSize.height;
    NSLog(@"TitleHeight: %f", titleHeight);
    
    
    return descriptionHeight + titleHeight + (2*padding);
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
       [self sendCertificateBluetooth];
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        [self.btConnectionHandler receiveDataWithHandlerDelegate:self];
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        [self performSegueWithIdentifier:SEGUE_TO_CERT_ASS sender:nil]; 
    }
    
}

#pragma mark - methods to send certificate

-(void) sendCertificateBluetooth
{
    NSData* sendData = [KeyChainManager getCertificateofOwner:CERT_ID_USER];
    
    [self.btConnectionHandler sendDataToAll:sendData];
}

#pragma mark - BluetoothConnectionHandlerDelegate methods

- (void) receivedBluetoothData: (NSData*) data
{
    self.receivedCertificateData = data;
    
    //showing people picker do identify owner of the certificate
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
}

#pragma mark - ABPeoplePickerDelegate methods

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{   
    
    //todo: add support for cert-request
        ABRecordID rec_id = ABRecordGetRecordID(person);
        NSString *name = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString* id = [NSString stringWithFormat:@"%d",rec_id];
        
        [self dismissModalViewControllerAnimated:NO];
        
        UIAlertView* alert = nil;
        
        if([KeyChainManager addCertificate:self.receivedCertificateData withOwner:id] == YES)
        {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Certificate stored in Keychain", nil) message:[NSString stringWithFormat: NSLocalizedString(@"The certificate of %@ %@ has been received and stored in your keychain", nil), name, lastname] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        }
        else
        {
            alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Problem saving to keychain", @"Title of alert message when the certificate could not be saved") message:NSLocalizedString(@"Seems like you got the same certificate in your keychain associated with another person?!", "Body of alert message when the certificate could not be saved") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        }
            
    [alert show];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    
    return NO;
}



@end
