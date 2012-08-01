//
//  ChooseSendMethodViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ChooseSendMethodViewController.h"
#import "BluetoothConnectionHandler.h"
#import "PersistentStore.h"
#import "KeyChainStore.h"

@interface ChooseSendMethodViewController ()

@end

@implementation ChooseSendMethodViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    BluetoothConnectionHandler* tempbt = [[BluetoothConnectionHandler alloc] init];
    self.btConnectionHandler = tempbt;    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        //    [self performSegueWithIdentifier:SEGUE_TO_DETAIL sender:segueContainer];
    }
    else if (indexPath.row == 1)
    {
        NSData *sendData = [PersistentStore getActiveCertificateOfUser];
        
        [self.btConnectionHandler sendDataToAll:sendData];
    }
    else if (indexPath.row == 2)
    {
        [self.btConnectionHandler receiveDataWithHandlerDelegate:self];
    }
}


- (void) receivedBluetoothData: (NSData*) data
{
    
    self.receivedCertificateData = data;
    
    //showing people picker do identify owner of the certificate
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
}


- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    ABRecordID rec_id = ABRecordGetRecordID(person);
    
    NSString* id = [NSString stringWithFormat:@"%d",rec_id];
    
    [self dismissModalViewControllerAnimated:YES];
    
    UIAlertView* alert = nil;
    
    
    if([KeyChainStore setData:self.receivedCertificateData forKey:id type:kDataTypeCertificate])
    {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Certificate stored in Keychain", @"Title of alert view in choose send method view") 
                                           message:[NSString stringWithFormat: NSLocalizedString(@"The certificate of %@ has been received and stored in your keychain", @"Message of alert view in choose send method view"), 
                                                                                                 id] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Problem saving to keychain", @"Title of alert view in choose sendmethod view") 
                                           message:NSLocalizedString(@"Seems like you got the same certificate in your keychain associated with another person?!", @"Message of alert view in choosse send method view") 
                                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
