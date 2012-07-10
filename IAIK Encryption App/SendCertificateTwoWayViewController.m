//
//  SendCertificateTwoWayViewController.m
//  IAIK Encryption App
//
//  Created by Christoph Hechenblaikner on 26.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendCertificateTwoWayViewController.h"
#import "NSData+CommonCrypto.h"
#import "KeyChainManager.h"
#import "Base64.h"

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
            alert = [[UIAlertView alloc] initWithTitle:@"Device cannot send Mail" message:@"Your device is currently not configured to send mail, please configure it or send your certificate via bluetooth" delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil, nil];
        }
        else if([MFMessageComposeViewController canSendText] == NO)
        {
            alert = [[UIAlertView alloc] initWithTitle:@"Device cannot send text message" message:@"Your device is currently not configured to send text message, please configure it or send your certificate via bluetooth" delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil, nil];    
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
    
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linenbg.png"]];
    CGRect background_frame = self.tableView.frame;
    background_frame.origin.x = 0;
    background_frame.origin.y = 0;
    background.frame = background_frame;
    background.contentMode = UIViewContentModeTop;
    self.tableView.backgroundView = background;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
            cell.textLabel.text = @"Choose recipient";
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
            cell.textLabel.text = @"Send cert via mail";
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
            cell.textLabel.text = @"Send PIN via sms";
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
            return @"Step 1: Choose a recipient";
            break;
        case SECTION_STEP_2:
            return @"Step 2: Send Cert via mail";
            break;
        case SECTION_STEP_3:
            return @"Step 3: Send checksum via text message";
            break;
        default:
            return @"ERROR!!";
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *hView = [[UIView alloc] initWithFrame:CGRectZero];
    hView.backgroundColor=[UIColor clearColor];
    
    UILabel *hLabel=[[UILabel alloc] initWithFrame:CGRectMake(19,10,301,21)];
    
    hLabel.backgroundColor=[UIColor clearColor];
    hLabel.shadowColor = [UIColor blackColor];
    hLabel.shadowOffset = CGSizeMake(0.5,1);
    hLabel.textColor = [UIColor whiteColor];
    hLabel.font = [UIFont boldSystemFontOfSize:17];
    hLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    [hView addSubview:hLabel];
        
    return hView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

#pragma mark - KeyGeneration

-(void) generateCertificateKey
{
    NSMutableString* newkey = [[NSMutableString alloc] init];
    
    for(NSInteger i = 0;i<KEY_LENTH;i++)
    {
        int keyelement = arc4random_uniform(10);
        [newkey appendFormat:@"%d",keyelement];
    }
    NSLog(@"Decryption key: %@", key);
    
    
    //test
    //NSData *dataIn = [@"Now is the time for all good computers to come to the aid of their masters." dataUsingEncoding:NSASCIIStringEncoding];
    NSData *dataIn = [KeyChainManager getCertificateofOwner:CERT_ID_USER];
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH]; //CC_SHA256_DIGEST_LENGTH];
    
    //CC_SHA256(dataIn.bytes, dataIn.length,  macOut.mutableBytes);
    CC_SHA1(dataIn.bytes, dataIn.length, macOut.mutableBytes);
    
    
    NSLog(@"dataIn: %@", dataIn);
    NSLog(@"macOut: %@", macOut);
    
    NSString *encoded =  [Base64 encode:macOut];  //[self base64encode:macOut];
    NSLog(@"base64: %@", encoded);
    NSLog(@"decoded: %@", [Base64 decode:encoded]);
    
    //end of test
    
    //self.key = newkey;
    self.key = encoded;
    
}

#pragma mark - CertificateEncryption

-(NSData*) getOwnEncryptedCertificate
{
    [self generateCertificateKey];
    
    NSData* cert = [KeyChainManager getCertificateofOwner:CERT_ID_USER];
    
    NSError* encryptionerror = nil;
    
    //NSData* encryptedcert = [cert AES256EncryptedDataUsingKey:self.key error:&encryptionerror];
    
    /*if(encryptedcert == nil)
    {
        //TODO check error
        NSLog(@"Error encrypting certificate!");
    }*/
    
    return cert;
    //return encryptedcert;
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
            [composer setSubject:@"My Certificate"];
            [composer setMessageBody:@"You will receive the chechsum for my certificate shortly via SMS or iMessage" isHTML:NO];
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
            composer.body = [NSString stringWithFormat:@"The checksum for my certificate is: %@",self.key];
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
        alert = [[UIAlertView alloc] initWithTitle:@"Few contact data" message:@"To send the certificate an email-address and a mobile phone number of the person is required, please add required information to the contact" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
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
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Problem sending text message" message:@"A Problem occured when trying to send text message, please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
