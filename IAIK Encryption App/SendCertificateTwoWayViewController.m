//
//  SendCertificateTwoWayViewController.m
//  IAIK Encryption App
//
//  Created by Christoph Hechenblaikner on 26.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendCertificateTwoWayViewController.h"
#import "NSData+CommonCrypto.h"
#import "Base64.h"
#import "PersistentStore.h"

#define NUMBER_SECTIONS 3
#define NUMBER_ROWS_STEP_1 1
#define NUMBER_ROWS_STEP_2 1
#define NUMBER_ROWS_STEP_3 1
#define SECTION_STEP_1 0
#define SECTION_STEP_2 1
#define SECTION_STEP_3 2


#define KEY_LENTH 4


@interface SendCertificateTwoWayViewController ()
{
    bool step1Completed;
    bool step2Completed;
    bool step3Completed;
    NSInteger rowSendMail;
    NSInteger rowSendSMS;
    
}
@end

@implementation SendCertificateTwoWayViewController

@synthesize name, phoneNumbers, emailAddresses, phoneNumber, emailAddress, key;

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        UIAlertView* alert = nil;
        
        if([MFMailComposeViewController canSendMail] == NO)
        {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Device cannot send Mail", @"Title of alert view in send certificate view") 
                                               message:NSLocalizedString(@"Your device is currently not configured to send mail, please configure it or send your certificate via bluetooth", @"Message of alert view in send certificate view") delegate:self cancelButtonTitle:NSLocalizedString(@"Back", @"Back button text") otherButtonTitles:nil, nil];
        }
        else if([MFMessageComposeViewController canSendText] == NO)
        {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Device cannot send text message", @"Title of alert view in send certificate view") 
                                               message:NSLocalizedString(@"Your device is currently not configured to send text message, please configure it or send your certificate via bluetooth", @"Message of alert view in send certificate view") delegate:self cancelButtonTitle:NSLocalizedString(@"Back", @"Back button text") otherButtonTitles:nil, nil];    
        }
        
        [alert show];
        
        step1Completed = NO;
        step2Completed = NO;
        step3Completed = NO;
    }
    
    return self;
}


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
    
//    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linenbg.png"]];
//    CGRect background_frame = self.tableView.frame;
//    background_frame.origin.x = 0;
//    background_frame.origin.y = 0;
//    background.frame = background_frame;
//    background.contentMode = UIViewContentModeTop;
//    self.tableView.backgroundView = background;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
}

-(void) viewWillAppear:(BOOL)animated
{
    //[UIApplication sharedApplication].statusBarOrientation = self.interfaceOrientation;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(step1Completed)
    {
        if(step2Completed)
        {
            return NUMBER_SECTIONS;
        }
        
        return 2 ;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_STEP_1:
        {
            return NUMBER_ROWS_STEP_1;
        }
        case SECTION_STEP_2:
        {
            rowSendMail = [self.emailAddresses count];
            return NUMBER_ROWS_STEP_2 + rowSendMail;
        }
            
        case SECTION_STEP_3:
        {
            rowSendSMS = [self.phoneNumbers count];
            return NUMBER_ROWS_STEP_3 + rowSendSMS;
        }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = nil;
    
    if(indexPath.section == SECTION_STEP_1)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if(step1Completed == NO)
        {
            cell.textLabel.text = NSLocalizedString(@"Choose recipient", @"Text of label in send certificate view");
        }
        else 
        {
            cell.textLabel.text = self.name;
            cell.imageView.image = [UIImage imageNamed:@"checkmark"];
        }
        
    }
    else if(indexPath.section == SECTION_STEP_2)
    {
        if(indexPath.row == rowSendMail)
        {
            cell.textLabel.text = NSLocalizedString(@"Send cert via mail", @"Text of label in send certificate view");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if(step2Completed == YES)
            {
                cell.imageView.image = [UIImage imageNamed:@"checkmark"];
            }
        }
        else 
        {
            cell.textLabel.text = [self.emailAddresses objectAtIndex:indexPath.row];
            
            if([cell.textLabel.text isEqualToString:self.emailAddress])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    else if(indexPath.section == SECTION_STEP_3)
    {
        if(indexPath.row == rowSendSMS)
        {
            cell.textLabel.text = NSLocalizedString(@"Send PIN via sms", @"Text of label in send certificate view");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if(step3Completed == YES)
            {
                cell.imageView.image = [UIImage imageNamed:@"checkmark"];
            }
        }
        else 
        {
            cell.textLabel.text = [self.phoneNumbers objectAtIndex:indexPath.row];
            
            if([cell.textLabel.text isEqualToString:self.phoneNumber])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_STEP_1:
            return NSLocalizedString(@"Step 1: Choose a recipient", @"Text in send certificate view for choosing a recipient");
            break;
        case SECTION_STEP_2:
            return NSLocalizedString(@"Step 2: Send Cert via mail", @"Text in send certificate view for sending a certificate via email");
            break;
        case SECTION_STEP_3:
            return NSLocalizedString(@"Step 3: Send checksum via text message", @"Text in send certificate view for sending the checksum via SMS");
            break;
        default:
            return NSLocalizedString(@"ERROR!!", @"Showing error label if the section index was out of bound");
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

#pragma mark - CertificateEncryption

-(NSData*) getOwnEncryptedCertificate
{
    
    NSData *cert = [PersistentStore getActiveCertificateOfUser];
    
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH]; //CC_SHA256_DIGEST_LENGTH];
    
    //CC_SHA256(dataIn.bytes, dataIn.length,  macOut.mutableBytes);
    CC_SHA1(cert.bytes, cert.length, macOut.mutableBytes);
    
    NSLog(@"macOut: %@", macOut);
    NSString *encoded =  [Base64 encode:macOut];
    NSLog(@"base64: %@", encoded);
    
    //self.key = newkey;
    self.key = encoded;
    
    return cert;
}


#pragma mark - modalViewController methods

-(IBAction)didCancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_STEP_1)
    {
        ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        [self presentModalViewController:picker animated:YES];
    }
    else if(indexPath.section == SECTION_STEP_2)
    {
        if(indexPath.row == rowSendMail)
        {
            MFMailComposeViewController* composer = [[MFMailComposeViewController alloc] init];
            [composer setToRecipients:[NSArray arrayWithObject:self.emailAddress]];
            [composer setSubject:NSLocalizedString(@"My Certificate", @"Subject for mail in send certificate view")];
            [composer setMessageBody:NSLocalizedString(@"You will receive the checksum for my certificate shortly via SMS or iMessage", @"Body for mail in send certificate view") isHTML:NO];
            composer.mailComposeDelegate = self;
            
            //Getting certificate and encrypting it
            NSData* encryptedcert = [self getOwnEncryptedCertificate];
            [composer addAttachmentData:encryptedcert mimeType:@"application/iaikencryption" fileName:@"cert.iaikcert"];
            
            [self presentModalViewController:composer animated:YES];
        }
        else 
        {
            self.emailAddress = [self.emailAddresses objectAtIndex:indexPath.row];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_STEP_2] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
    else if(indexPath.section == SECTION_STEP_3)
    {
        if(indexPath.row == rowSendSMS)
        {
            MFMessageComposeViewController* composer = [[MFMessageComposeViewController alloc] init];
            composer.recipients = [NSArray arrayWithObject:self.phoneNumber];
            
            if (self.key == nil) {
                
                NSData *cert = [PersistentStore getActiveCertificateOfUser];
                
                NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH]; //CC_SHA256_DIGEST_LENGTH];
                
                //CC_SHA256(dataIn.bytes, dataIn.length,  macOut.mutableBytes);
                CC_SHA1(cert.bytes, cert.length, macOut.mutableBytes);
                
                NSLog(@"macOut: %@", macOut);
                NSString *encoded =  [Base64 encode:macOut];
                NSLog(@"base64: %@", encoded);
                
                //self.key = newkey;
                self.key = encoded;
            }
            
            composer.body = [NSString stringWithFormat:@"I have sent you my certificate via email. This is the checksum for verification: %@", self.key];
            composer.messageComposeDelegate = self;
            
            [self presentModalViewController:composer animated:YES];
        }
        else 
        {
            self.phoneNumber = [self.phoneNumbers objectAtIndex:indexPath.row];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_STEP_3] withRowAnimation:(UITableViewRowAnimationFade)];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    step1Completed = NO;
    step2Completed = NO;
    step3Completed = NO;
    
    NSString* firstname = (__bridge NSString*) ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* lastname = (__bridge NSString*) ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    self.name = [firstname stringByAppendingFormat:@" %@",lastname];
    
    self.phoneNumbers = (__bridge NSArray*) ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonPhoneProperty));
    self.emailAddresses = (__bridge NSArray*) ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty));
    
    NSLog(@"phone: %@; email: %@",self.phoneNumbers.description, self.emailAddresses.description);
    
    NSLog(@"phone count %d",self.phoneNumbers.count);
    
    UIAlertView* alert = nil;
    
    if([self.phoneNumbers count] == 0 || [self.emailAddresses count] == 0)
    {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No contact data", @"Title for alert view in send certificate view") 
                                           message:NSLocalizedString(@"To send the certificate an email-address and a mobile phone number of the person is required, please add required information to the contact", @"Message for alert view in send certificate view") 
                                          delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    else 
    {
        self.phoneNumber = [self.phoneNumbers objectAtIndex:0];
        self.emailAddress = [self.emailAddresses objectAtIndex:0];
        
        step1Completed = YES;
        
        [self.tableView reloadData];
        
        [self dismissModalViewControllerAnimated:YES];
        
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

#pragma mark - UIAlerViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - MFMailComposerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if(result == MFMailComposeResultFailed)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Problem sending mail" message:@"A problem occured while trying to send mail, please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    else if(result == MFMailComposeResultSent)
    {
        step2Completed = YES;
    }
    
    [self.tableView reloadData];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - MFMessageComposerViewControllerDelegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{  
    if(result == MessageComposeResultFailed)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Problem sending text message", @"Title for alert view in send certificate view") 
                                                        message:NSLocalizedString(@"A Problem occured when trying to send text message, please try again", @"Message for alert view in send certificate view") 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if(result == MessageComposeResultSent)
    {
        step3Completed = YES;
        UIBarButtonItem* donebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
        
        [self.navigationItem setRightBarButtonItem:donebutton animated:YES];
        
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_STEP_3] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    [self dismissModalViewControllerAnimated:YES]; 
}

-(void) dismiss
{
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

-(void) dealloc
{
    self.name = nil;
    self.emailAddress = nil;
    self.phoneNumber = nil;
    self.phoneNumbers = nil;
    self.emailAddresses = nil;
    self.key = nil;
    
}

@end
