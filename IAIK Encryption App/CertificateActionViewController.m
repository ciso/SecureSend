//
//  CertificateActionViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 13.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CertificateActionViewController.h"
#import "KeyChainManager.h"
#import "Validation.h"
#import "TextProvider.h"
#import "CertificateRequest.h"
#import "UserSettingsViewController.h"

#define SEGUE_TO_CERT_ASS @"toCertSendAssist"
#define SEGUE_TO_DEFAULT_EMAIL @"toDefaultEmail"

@interface CertificateActionViewController ()

@property (nonatomic, assign) BOOL sendRequest;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, assign) BOOL certMailSent;
@property (nonatomic, strong) NSString *hash;

@end

@implementation CertificateActionViewController

@synthesize btConnectionHandler = _btConnectionHandler;
@synthesize receivedCertificateData = _receivedCertificateData;
@synthesize sendRequest = _sendRequest;
@synthesize name = _name;
@synthesize email = _email;
@synthesize phoneNumber = _phoneNumber;
@synthesize certMailSent = _certMailSent;
@synthesize hash = _hash;

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

    
    //temp init
    self.sendRequest = NO;
    self.certMailSent = NO;
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
    if (indexPath.section == 0 && indexPath.row == 0) //send cert via BT
    {
        [self sendCertificateBluetooth];
    }
    else if (indexPath.section == 0 && indexPath.row == 1) //receive cert via BT
    {
        [self.btConnectionHandler receiveDataWithHandlerDelegate:self];
    }
    else if (indexPath.section == 0 && indexPath.row == 2) //send cert via two-way exchange
    {
        [self performSegueWithIdentifier:SEGUE_TO_CERT_ASS sender:nil]; 
    }
    else if (indexPath.section == 0 && indexPath.row == 3) //send cert-request
    {
        [self sendCertificateRequest]; 
    }
    
    //deselecting clicked row
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_DEFAULT_EMAIL])
    {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        UserSettingsViewController *settings = (UserSettingsViewController*)[nav.viewControllers objectAtIndex:0];
        settings.sender = self;
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
    self.sendRequest = NO;
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{   
    if (!self.sendRequest)
    {    
        ABRecordID rec_id = ABRecordGetRecordID(person);
        NSString *name = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString* id = [NSString stringWithFormat:@"%d",rec_id];
        
        [self dismissModalViewControllerAnimated:YES];
        
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
    }
    else 
    {
        [self dismissModalViewControllerAnimated:NO];
        
        self.sendRequest = NO;
        
        //ABRecordID rec_id = ABRecordGetRecordID(person);
        NSString *name = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        ABMultiValueRef emails  = ABRecordCopyValue(person, kABPersonEmailProperty);
        //NSString* id = [NSString stringWithFormat:@"%d",rec_id];
        
        NSMutableArray *emailArray = [[NSMutableArray alloc] init];
        
        if(ABMultiValueGetCount(emails) != 0){
            for(int i=0;i<ABMultiValueGetCount(emails);i++)
            {
                CFStringRef em = ABMultiValueCopyValueAtIndex(emails, i);
                [emailArray addObject:[NSString stringWithFormat:@"%@",em]];
                CFRelease(em);
            }
        }
        
        self.email = [emailArray objectAtIndex:0];
        self.name = [NSString stringWithFormat:@"%@ %@", name, lastname];
        
        //obtain email address from the user
        NSString *defaultEmail = [[NSUserDefaults standardUserDefaults] stringForKey:@"default_email"];
        NSString *defaultPhone = [[NSUserDefaults standardUserDefaults] stringForKey:@"default_phone"];
        
        if (![Validation emailIsValid:defaultEmail] || ![Validation phoneNumberIsValid:defaultPhone])
        {
            
            [self performSegueWithIdentifier:SEGUE_TO_DEFAULT_EMAIL sender:self];            
        }
        else 
        {
            [self openMailComposer];
        }
    }
    
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

#pragma mark - certificate request
- (void)sendCertificateRequest
{
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    self.sendRequest = YES;
    [self presentModalViewController:picker animated:YES];
}

#pragma mark - mail composer

//openMailComposer
//this method is used to invoke the mail composer for sending a certificate request
- (void)openMailComposer
{
    MFMailComposeViewController* composer = [[MFMailComposeViewController alloc] init];
    [composer setToRecipients:[NSArray arrayWithObject:self.email]];
    [composer setSubject:[TextProvider getEmailSubject]];
    NSString *body = [TextProvider getEmailBodyForRecipient:self.name];
    [composer setMessageBody:body isHTML:NO];
    composer.mailComposeDelegate = self;
    
    //todo: create real certrequest object here
    CertificateRequest *certRequest = [[CertificateRequest alloc] init];
    certRequest.date = [NSDate date];
    certRequest.emailAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"default_email"];
    certRequest.phoneNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"default_phone"];
    NSString *xml = [certRequest toXML];
    
    NSData *attachment = [xml dataUsingEncoding:NSUTF8StringEncoding];
    
    [composer addAttachmentData:attachment mimeType:@"application/iaikencryption" fileName:@"CertificateRequest.iaikreq"];
    
    [self presentModalViewController:composer animated:YES];
}

#pragma mark - MFMailComposerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if(result == MFMailComposeResultFailed)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Problem sending mail", @"Title of alert view in root view. The mail could not be sent") 
                                                        message:NSLocalizedString(@"A problem occured while trying to send mail, please try again", @"Message of alert view in root view. The mail could not be sent. The user is told to try it again.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    else if(result == MFMailComposeResultSent)
    {
        if (self.certMailSent == YES)
        {
            self.certMailSent = NO;
            
            [self dismissModalViewControllerAnimated:NO];
            
            MFMessageComposeViewController* composer = [[MFMessageComposeViewController alloc] init];
            composer.recipients = [NSArray arrayWithObject:self.phoneNumber];
            composer.body = [NSString stringWithFormat:NSLocalizedString(@"The checksum for my certificate is: %@", @"Text for body of hash message. The user is told the checksum (hash)of the certificate"), self.hash];
            composer.messageComposeDelegate = self;
            
            [self presentModalViewController:composer animated:YES];
            
            self.hash = nil;
            self.phoneNumber = nil;
            return;
            
        }
    }
    
    [self.tableView reloadData];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - MFMessageComposerViewControllerDelegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{  
    if(result == MessageComposeResultFailed)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Problem sending text message", @"Title of alert view in root view. There was a problem with sending the hash message") message:NSLocalizedString(@"A Problem occured when trying to send text message, please try again", @"Message of alert view in root view. There was a problem with sending the hash message") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if(result == MessageComposeResultSent)
    {
        
    }
    [self dismissModalViewControllerAnimated:YES]; 
}



@end
