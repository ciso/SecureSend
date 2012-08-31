//
//  RootViewController.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>
#import "RootViewController.h"
#import "SecureContainer.h"
#import "ContainerDetailViewController.h"
#import "BluetoothConnectionHandler.h"
#import <Security/Security.h>
#import "FilePathFactory.h"
#import "NSData+CommonCrypto.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <GameKit/GameKit.h>
#import "Crypto.h"
#import "ZipArchive.h"
#import "ChooseContainerViewController.h"
#import "Base64.h"
#import "Validation.h"
#import "UserSettingsViewController.h"
#import "TextProvider.h"
#import "XMLParser.h"
#import "CertificateRequest.h"
#import "PersistentStore.h"
#import "KeyChainStore.h"
#import "NotificationViewController.h"
#import "TutorialViewController.h"
#import "Error.h"
#import "DropboxAlertViewHandler.h"
#import "Email.h"
#import "ContainerEditAlertViewHandler.h"
#import "RecipientsViewController.h"

#define SECTION_CONTAINERS 0
#define SECTION_ACTIONS 1
#define NUMBER_SECTIONS 2
#define ROW_ACTION_SEND_BT 0
#define ROW_ACTION_RECEIVE_BT 1
#define ROW_ACTION_SEND_MAIL 2
#define ROW_ACTION_SEND_REQUEST 3
#define NUMBER_ROWS_CREATE 1
#define NUMBER_ROWS_ACTIONS 4
#define TEST_CERTIFICAT_OWNER @"Christof"
#define USERS_DEFAULT_EMAIL @"default_email_property"


@interface RootViewController() {
@private
    NSInteger rowAddContainer;
}

@property (nonatomic, strong) UITextField *activeInput;
@property (nonatomic, strong) DropboxAlertViewHandler *handler;
@property (nonatomic, strong) ContainerEditAlertViewHandler *editHandler;
@property (nonatomic, strong) SecureContainer *currentActiveContainer;


@end


@implementation RootViewController

@synthesize btConnectionHandler     = _btConnectionHandler;
@synthesize receivedCertificateData = _receivedCertificateData;
@synthesize containers              = _containers;
@synthesize certData                = _certData;
@synthesize receivedFileURL         = _receivedFileURL;
@synthesize sendRequest             = _sendRequest;
@synthesize email                   = _email;
@synthesize name                    = _name;
@synthesize certMailSent            = _certMailSent;
@synthesize phoneNumber             = _phoneNumber;
@synthesize hash                    = _hash;
@synthesize editable                = _editable;
@synthesize activeInput             = _activeInput;
@synthesize restClient              = _restClient;
@synthesize navBar = _navBar;
@synthesize handler                 = _handler;
@synthesize editHandler             = _editHandler;
@synthesize currentActiveContainer  = _currentActiveContainer;

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        self.containers = [FilePathFactory getContainersOfFileStructure];
        
        //[KeyChainManager deleteCertificatewithOwner:CERT_ID_USER];
        
        //[KeyChainManager deleteUsersPrivateKey];

        
        //creating Handler for Bluetooth-Connection
        BluetoothConnectionHandler* tempbt = [[BluetoothConnectionHandler alloc] init];
        self.btConnectionHandler = tempbt;
    }
    
    return self;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.handler = [[DropboxAlertViewHandler alloc] init];

    
    //info button
    UIButton* info = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [info addTarget:self action:@selector(openInfoScreen) forControlEvents:UIControlEventAllEvents];
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:info];
    
    UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 5.0;
    
    self.navBar.leftBarButtonItems = [[NSArray alloc] initWithObjects:space, infoButton, nil];
    
    //background color
    self.tableView.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];

    //open data protection warning
    [self showDataProtectionNotification];
    
    //should never be needed... but who knows...
    [self openCreateCertificateView];
    
    self.sendRequest = NO;
    self.certMailSent = NO;
    self.editable = NO;
}

- (void)notificationViewClosed {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"getstarted"] == 1) {
        [self openGetStartedView];
    }
    else {
        [self openCreateCertificateView];
    }
}

- (void)openInfoScreen {
    [self performSegueWithIdentifier:@"toInfoView" sender:self];
}

- (void)openCreateCertificateView {
    //checking if a certificate has to be created
    if([PersistentStore getActiveCertificateOfUser] == nil)
    {
        [self performSegueWithIdentifier:SEGUE_TO_CREATE_CERT sender:nil];
    }
}

- (void)openGetStartedView {
    [self performSegueWithIdentifier:@"toGetStartedView" sender:nil];
}

- (void)getStartedViewClosed {
    [self openCreateCertificateView];
}

- (void)showDataProtectionNotification {
    BOOL shownotification = NO;
    
    
    // Get current version ("Bundle Version") from the default Info.plist file
    NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSArray *prevStartupVersions = [[NSUserDefaults standardUserDefaults] arrayForKey:@"prevStartupVersions"];
    if (prevStartupVersions == nil)
    {
        //Fresh install!!
        shownotification = YES;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:currentVersion] forKey:@"prevStartupVersions"];
    }
    else
    {
        if (![prevStartupVersions containsObject:currentVersion])
        {
            
            //first start of this version
            shownotification = YES;
            
            NSMutableArray *updatedPrevStartVersions = [NSMutableArray arrayWithArray:prevStartupVersions];
            [updatedPrevStartVersions addObject:currentVersion];
            [[NSUserDefaults standardUserDefaults] setObject:updatedPrevStartVersions forKey:@"prevStartupVersions"];
        }
    }
    
    // Save changes to disk
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (shownotification) {
        [self performSegueWithIdentifier:@"toDataProtectionNotification" sender:self];
    }
    
//    if(shownotification)
//    {
//        UIAlertView* enableDP = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Data Protection", nil) message:NSLocalizedString(@"If you currently don't have a passphrase set for your device do it now! This application can not be considered secure without this feature turned on", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        
//        [enableDP show];
//    }
}

- (void)viewDidUnload
{
    [self setNavBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self showEditBarButtonItem];
    
    if (self.containers.count == 0) {
        [self showHelpView];
    }
    else {
        [self removeHelpView];
    }
    
    [self.tableView reloadData];
}



// help view begin
- (void)showHelpView {
    if ([self.view viewWithTag:200] == nil) {
        UIImage *image = [UIImage imageNamed:@"containerhelp"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = 200;
        
        [self.view addSubview:imageView];
    }
}

- (void)removeHelpView {
    UIView *view = [self.view viewWithTag:200];
    if (view != nil) {
        view.hidden = YES;
        [self.view bringSubviewToFront:view];
        [view removeFromSuperview];
        [self.view setNeedsLayout];
        [self.view setNeedsDisplay];
    }
}
//end of help view



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_SECTIONS-1; //-1 because I removed the action section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == SECTION_CONTAINERS)
    {
        rowAddContainer = [self.containers count];
        return rowAddContainer;//+1; //removed +1 cuz of "create container" cell
    }
    /*else if(section == SECTION_ACTIONS)
        return NUMBER_ROWS_ACTIONS;*/
    
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_CONTAINERS && indexPath.row != rowAddContainer)
        return NO; //was YES
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.containers removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    
    if([self.containers count] == 0)
    {
        [self endEditTableView];
        [self showHelpView];
    }
    
}

// textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.activeInput = textField;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.activeInput = nil;
    return [self textFieldShouldReturn:textField];
    
    //return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (self.editable)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"EditCell"];
        UITextField *nameTextField = (UITextField*)[cell viewWithTag:100];
        nameTextField.text = [[self.containers objectAtIndex:indexPath.row] name];
        cell.contentView.tag = indexPath.row;
        nameTextField.clearButtonMode = UITextFieldViewModeAlways;
        nameTextField.delegate = self;

        
    }
    else
    {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell = [[SwipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];

        ((SwipeCell*)cell).delegate = self;
        
        UITextField *nameTextField = (UITextField*)[cell viewWithTag:100];
        UILabel *detailLabel = (UILabel*)[cell viewWithTag:101];
        UILabel *lastModifiedLabel = (UILabel*)[cell viewWithTag:102];

        //nameTextField.tag = indexPath.row;
        cell.contentView.tag = indexPath.row;
        nameTextField.text = [[self.containers objectAtIndex:indexPath.row] name];
        
        //test
        nameTextField.userInteractionEnabled = self.editable;
        if (self.editable)
        {
            nameTextField.clearButtonMode = UITextFieldViewModeAlways;
        }
        else
        {
            nameTextField.clearButtonMode = UITextFieldViewModeNever;
        }
        
        
        //obtaining secure container
        SecureContainer *container = [self.containers objectAtIndex:indexPath.row];
        
        //setting last modified date
        NSDictionary *attributes;
        NSError *error;
        attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:container.basePath  error:nil];
        
        if (error) {
            [Error log:error];
        }
        
        NSDate *lastModifiedDate = (NSDate*)[attributes objectForKey:NSFileModificationDate];
        NSDate *today = [NSDate date];

        NSDate *date1 = lastModifiedDate;
        NSDate *date2 = today;
        
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
        
        NSDateComponents *components = [gregorian components:unitFlags
                                                    fromDate:date1
                                                      toDate:date2 options:0];
        
        NSInteger days = [components day];
        
        if (days == 0) {
            lastModifiedLabel.text = [NSString stringWithFormat:@"Last modified today"];
        }
        else {
            lastModifiedLabel.text = [NSString stringWithFormat:@"Last modified %d days ago", days];
        }
        

        if (error)
        {
            NSLog(@"Error occured by receiving file attributes");
        }
        
        //date created
        NSDate *dateCreated = [attributes objectForKey:NSFileCreationDate]; //vs. NSFileModificationDate
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        //NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:118800];
        NSString *formattedDateString = [dateFormatter stringFromDate:dateCreated];
        //NSLog(@"formattedDateString for locale %@: %@", [[dateFormatter locale] localeIdentifier], formattedDateString);
        
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
        detailLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
        
    }
    
    
    return cell;
}


#pragma mark - Swipe Cell Delegate
- (void)share:(UITableViewCell*)cell {
    NSLog(@"Share pressed");

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self performSegueWithIdentifier:@"toDetailAndExport" sender:[self.containers objectAtIndex:indexPath.row]];
    
}

- (void)remove:(UITableViewCell*)cell {
    NSLog(@"Remove pressed");

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
}

- (void)edit:(UITableViewCell*)cell {
    NSLog(@"Edit pressed");
    
    self.editHandler = [[ContainerEditAlertViewHandler alloc] init];
    
    UIAlertView* alert = nil;
    NSString *message = @"Please enter a new name.";
    alert = [[UIAlertView alloc] initWithTitle:@"Rename" message:message delegate:self.editHandler cancelButtonTitle:@"CANCEL" otherButtonTitles:@"SAVE", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.editHandler.caller = self;
    self.editHandler.cell = cell;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    self.currentActiveContainer = [self.containers objectAtIndex:indexPath.row];
    
    [alert show];
    
    //[self editTableView];
}

- (void)userRenamedContainer:(NSString*)name inCell:(UITableViewCell*)cell {
    NSLog(@"New name: %@", name);
   
    SecureContainer *container = self.currentActiveContainer;
    self.currentActiveContainer = nil;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    //creating new path
    NSString* newpath = [[FilePathFactory applicationDocumentsDirectory] stringByAppendingPathComponent:name];
    
    //check if the filename is allready present, checking if name is not an emtpy string
    if([[NSFileManager defaultManager] fileExistsAtPath:newpath] == YES && ![container.name isEqualToString:name])
    {
        UIAlertView* alert;
        
        if([name isEqualToString:@""])
        {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter a name", @"Title for alert in container detail view")
                                               message:NSLocalizedString(@"Please enter a name for the container", @"Message for alert in container detail view")
                                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        }
        else {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Container allready exists", @"Title for alert in container detail view")
                                               message:NSLocalizedString(@"There seems to exist another container with the same namne, please choose a different one", @"Message for alert in container detail view")
                                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        }
        
        [alert show];
        
        name = container.name;
        
    }
    else if([container.name isEqualToString:name] == NO)
    {
        //assigning container properties and renamind directory
        container.name = name;
        
        NSError* err = 0;
        [[NSFileManager defaultManager] moveItemAtPath:container.basePath toPath:newpath error:&err];
        if (err) {
            [Error log:err];
        }
        
        container.basePath = newpath;
        
        //changing paths of the existing files
        NSMutableArray* newfileurls = [[NSMutableArray alloc] init];
        
        for(NSString __strong *file in container.fileUrls)
        {
            file = [container.basePath stringByAppendingPathComponent:[file lastPathComponent]];
            [newfileurls addObject:file];
        }
        
        container.fileUrls = newfileurls;
    }
    
    [((SwipeCell*)cell) hide];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

}

- (void)cellSwiped:(UITableViewCell*)cell {
    for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        SwipeCell *currentCell = (SwipeCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        
        if (cell != currentCell) {
            [currentCell hide];
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_CONTAINERS)
    {
        {
            [self performSegueWithIdentifier:SEGUE_TO_DETAIL sender:[self.containers objectAtIndex:indexPath.row]];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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
    self.sendRequest = NO;
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    if (!self.sendRequest)
    {    
        ABRecordID rec_id = ABRecordGetRecordID(person);
        NSString *name = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString* id = [NSString stringWithFormat:@"%d",rec_id];
        
        [self dismissModalViewControllerAnimated:YES];
        
        UIAlertView* alert = nil;
        
        if([KeyChainStore setData:self.receivedCertificateData forKey:id type:kDataTypeCertificate])
        {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Certificate stored in Keychain", nil) message:[NSString stringWithFormat: NSLocalizedString(@"The certificate of %@ %@ has been received and stored in your keychain", nil), name, lastname] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            UITabBarController *tab = self.tabBarController;
            UINavigationController *nav = [tab.viewControllers objectAtIndex:2];
            UIViewController *view = [nav.viewControllers objectAtIndex:0];
            if ([view isKindOfClass:[RecipientsViewController class]]) {
                
                [view performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:NO];
            }
            
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

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    
    return NO;
}

#pragma mark - methods to send certificate

-(void) sendCertificateBluetooth
{
    NSData *sendData = [PersistentStore getActiveCertificateOfUser];
    
    [self.btConnectionHandler sendDataToAll:sendData];
}

-(void) sendCertificateMailTextMessage
{
    [self performSegueWithIdentifier:SEGUE_TO_CERT_ASS sender:nil];
}

#pragma mark - methods for provide editing BarButtonItem
-(void) editTableView
{
    self.editable = YES;
    
    [self.tableView setEditing:YES animated:YES];
    [self showDoneBarButtonItem];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
    
}

-(void) endEditTableView
{
    self.editable = NO;
    //[self.tableView reloadData];
    
    [self.tableView setEditing:NO animated:YES];
    [self showEditBarButtonItem];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];

}

-(void) showEditBarButtonItem
{
    
    [self.navigationItem setLeftBarButtonItem:nil];
    
    if([self.containers count] > 0)
    {
        UIBarButtonItem* editbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTableView)];
        [self.navigationItem setLeftBarButtonItem:editbutton animated:YES];
    }
}

-(void) showDoneBarButtonItem
{
    
    UIBarButtonItem* donebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endEditTableView)];
    [self.navigationItem setLeftBarButtonItem:donebutton animated:YES];    
}


#pragma mark - segue control methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_DETAIL])
    {
        ContainerDetailViewController* detail = (ContainerDetailViewController*) [segue destinationViewController];
        
        SecureContainer* container = (SecureContainer*) sender;
        
        [detail setContainer:container];
        
        if(self.receivedFileURL != nil)
        {
            NSString* filename = [[self.receivedFileURL lastPathComponent] stringByDeletingPathExtension];
            
            NSString* path = [FilePathFactory getUniquePathInFolder:container.basePath forFileExtension:[self.receivedFileURL pathExtension] andFileName:filename];
            
            NSData* recfile = [NSData dataWithContentsOfURL:self.receivedFileURL];
            
            BOOL success = [recfile writeToFile:path options:NSDataWritingFileProtectionComplete error:nil];
            
            if(success == NO)
            {
                NSLog(@"error saving file");
            }
            
            [detail addFilesToContainer:[NSArray arrayWithObject:path]];
            
            [[NSFileManager defaultManager] removeItemAtURL:self.receivedFileURL error:nil];
        }
        
        self.receivedFileURL = nil;
    }
    else if ([segue.identifier isEqualToString:@"toDetailAndExport"]) {
        ContainerDetailViewController* detail = (ContainerDetailViewController*) [segue destinationViewController];
        SecureContainer* container = (SecureContainer*) sender;
        detail.isQuickForward = YES;
        [detail setContainer:container];
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_CHOOSE_CONTROLLER])
    {
        self.receivedFileURL = (NSURL*)sender;
        
        UINavigationController* nav = (UINavigationController*) segue.destinationViewController;
        
        ChooseContainerViewController* choose = (ChooseContainerViewController*) [nav.viewControllers objectAtIndex:0];
        
        choose.containers = self.containers;
        
        choose.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_DEFAULT_EMAIL])
    {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        UserSettingsViewController *settings = (UserSettingsViewController*)[nav.viewControllers objectAtIndex:0];
        settings.sender = self;
    }
    else if ([segue.identifier isEqualToString:@"toDataProtectionNotification"]) {
        
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        NotificationViewController *view = (NotificationViewController*)[nav.viewControllers objectAtIndex:0];
        view.delegate = self;
        
    }
    else if ([segue.identifier isEqualToString:@"toGetStartedView"]) {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        TutorialViewController *view = (TutorialViewController*)[nav.viewControllers objectAtIndex:0];
        view.root = self;
    }
}

#pragma mark - methods for decrypting container

-(void) decryptContainer:(NSData*) encryptedContainer
{
    NSData *usercert = [PersistentStore getActiveCertificateOfUser];

    NSData *userprivateKey = [PersistentStore getActivePrivateKeyOfUser];
        
    if(usercert == nil || userprivateKey == nil)
    {
        NSLog(@"Could not decrypt container because of missing key / certificate");
        return;
    }
    
    NSData* zippedcontainer;
    
    @try 
    {
        zippedcontainer = [[Crypto getInstance] decryptBinaryFile:encryptedContainer withUserCertificate:usercert privateKey:userprivateKey];
    }
    @catch (NSException *exception) 
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not decrypt", @"Title of alert in root view. The container could not be decrypted") 
                                                        message:NSLocalizedString(@"The container was not encrypted using your certificate", @"Message of alert in root view. The container could not be decrypted") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    @finally 
    {
        
    }
    
    NSFileManager* filemanager = [NSFileManager defaultManager];
    
    //creating incoming directory
    NSString* incoming = [[FilePathFactory applicationDocumentsDirectory] stringByAppendingPathComponent:NAME_INCOMING_DIRECTORY];
    [filemanager createDirectoryAtPath:incoming withIntermediateDirectories:NO attributes:nil error:nil];
    
    //creating path for zip-file
    NSString* zippath = [[incoming stringByAppendingPathComponent:NAME_TEMP_INCOMING_ZIP] stringByAppendingPathExtension:@"zip"];
    
    //writing zipfile
    [zippedcontainer writeToFile:zippath atomically:YES];
    
    //creating zipper and extracting zip
    ZipArchive* archive = [[ZipArchive alloc] init];
    
    if([archive UnzipOpenFile:zippath])
    {        
        [archive UnzipFileTo:incoming overWrite:YES];
    }
    
    [archive UnzipCloseFile];
        
    NSLog(@"documents: %@",[filemanager contentsOfDirectoryAtPath:[FilePathFactory applicationDocumentsDirectory] error:nil]);
    
    //deleting zip-file
    BOOL successdeletion = [filemanager removeItemAtPath:zippath error:nil];
    
    if(successdeletion == NO)
    {
        NSLog(@"error deleting zip-file!!");
    }
    
    //listing contents if incoming
    NSArray* incomingcontent = [filemanager contentsOfDirectoryAtPath:incoming error:nil];
    
    NSLog(@"incoming: %@",incomingcontent.description);
    
    //generating new unique name for folder
    NSString* pathindoc = [FilePathFactory getUniquePathInFolder:[FilePathFactory applicationDocumentsDirectory] forFileExtension:nil];
    
    [filemanager createDirectoryAtPath:pathindoc withIntermediateDirectories:NO attributes:nil error:nil];
    
    //moving files to new folder and determining container name
    NSString* newcontainername = nil;
    for(NSString* subpath in incomingcontent)
    {
        NSString* fullpath = [incoming stringByAppendingPathComponent:subpath];
        if([[subpath pathExtension] isEqualToString:DIRECTORY_EXTENSION])
        {
            newcontainername = [subpath stringByDeletingPathExtension];
        }
        else
        {
            BOOL successmove = [filemanager moveItemAtPath:fullpath toPath:[pathindoc stringByAppendingPathComponent:subpath] error:nil];
            if(successmove == NO)
            {
                NSLog(@"problem moving file into new directory!!");
            }
        }
    }
    
    //defining new containerpath (with correct name)
    NSString* newcontainerpath = [[FilePathFactory applicationDocumentsDirectory] stringByAppendingPathComponent:newcontainername];
    
    //ensuring unique name
    newcontainerpath = [FilePathFactory getUniquePathInFolder:[FilePathFactory applicationDocumentsDirectory] forFileExtension:nil andFileName:newcontainername];
    
    //renaming directory
    [filemanager moveItemAtPath:pathindoc toPath:newcontainerpath error:nil];
    
    NSLog(@"content of new folder %@",newcontainerpath);
    
    
    //parsing new container in container-structure
    SecureContainer* newcontainer = [FilePathFactory parseContainerAtPath:newcontainerpath];
    
    [self.containers addObject:newcontainer];
    
    //reloading tableview
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_CONTAINERS] withRowAnimation:UITableViewRowAnimationRight];
    
    //deleting incoming
    [filemanager removeItemAtPath:incoming error:nil];
    
    [self removeHelpView];
    
}


#pragma mark - UIAlertViewDelegateMethods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != 0)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"checksum_verification"] == 1)
        {
            NSString *sms = [alertView textFieldAtIndex:0].text;
            NSArray *hashArray = [sms componentsSeparatedByString:@"is: "];
            if ([hashArray count] <= 1)
            {
                hashArray = [sms componentsSeparatedByString:@"ist: "];
            }
            NSString *hash = [hashArray lastObject];
            hash = [hash stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //stripping whitespaces
            
            //hash from sms
            NSLog(@"base64 hash: %@", hash);
            NSData *decoded = [Base64 decode:hash];
            NSLog(@"decoded: %@", decoded);
            
            
            //hash from received cert
            NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH]; //CC_SHA256_DIGEST_LENGTH];
            
            //CC_SHA256(dataIn.bytes, dataIn.length,  macOut.mutableBytes);
            CC_SHA1(self.certData.bytes, self.certData.length, macOut.mutableBytes);
            
            NSLog(@"orig hash: %@", macOut);
            
            NSLog(@"hash from sms: %@", [Base64 encode:decoded]);
            NSLog(@"hash from cert: %@", [Base64 encode:macOut]);
            
            if ([[Base64 encode:decoded] isEqualToString:[Base64 encode:macOut]])
            {
                
            }
            else {
                self.certData = nil;
            }
        }
        
        if (self.certData == nil)
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error opening certificate", @"Title of alert view in root view. The certificate could not be opened") message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        else 
        {
            self.receivedCertificateData = self.certData;
            
            ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
            picker.peoplePickerDelegate = self;
            
            [self presentModalViewController:picker animated:YES];
        }
        
        self.certData = nil;   
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    
}

#pragma mark - ChoosedContainerDelegate methods

-(void) choosedContainer:(NSInteger) index
{
    
    [self dismissModalViewControllerAnimated:YES];
    
    [self performSegueWithIdentifier:SEGUE_TO_DETAIL sender:[self.containers objectAtIndex:index]];
}



// -------------------------------------
// CURRENTLY NOT IN USE?????????????????
// -------------------------------------
-(BOOL) isDataProtectionEnabled
{
    
    NSString *testFilePath = [[[FilePathFactory applicationDocumentsDirectory] stringByAppendingPathComponent:@"dptest"] stringByAppendingPathExtension:@"txt"];
    
    NSData* testdata = [[NSData alloc] initWithData:[@"testtest" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError* savingerror = [[NSError alloc] init];
    
    if([testdata writeToFile:testFilePath options:NSDataWritingFileProtectionComplete error:&savingerror])
    {
            [Error log:savingerror];
    }// obviously, do better error handling
    
    NSArray* doccontentes = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[FilePathFactory applicationDocumentsDirectory] error:nil];
    
    NSLog(@"%@",doccontentes.description);
    
    NSDictionary *testFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:testFilePath error:NULL];
    
    NSLog(@"testfileattr: %@",testFileAttributes.description);
    
    BOOL fileProtectionEnabled = [NSFileProtectionNone isEqualToString:[testFileAttributes objectForKey:NSFileProtectionKey]];
    
    return fileProtectionEnabled;
}

- (IBAction)addNewContainer:(UIBarButtonItem *)sender 
{
    NSError* directory_creation_error = nil;
    
//    NSString* path = [FilePathFactory getUniquePathInFolder:[FilePathFactory applicationDocumentsDirectory] forFileExtension:nil];
    NSString* path = [FilePathFactory getUniqueContainer:[FilePathFactory applicationDocumentsDirectory]];
    
    NSLog(@"Path: %@",path);
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:attributes error:&directory_creation_error];
    if(directory_creation_error != nil)
    {
            [Error log:directory_creation_error];
    }
    SecureContainer* newcontainer = [[SecureContainer alloc] init];
    newcontainer.basePath = path;
    newcontainer.name = [path lastPathComponent];
    newcontainer.creationDate = [NSDate date];
    [self.containers addObject:newcontainer];
    
    //enabling edit button
    [self showEditBarButtonItem];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.containers count] - 1 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    
    
    if (self.containers.count > 0) {
        [self removeHelpView];
    }
}

-(void) dealloc
{
    self.containers = nil;
    self.btConnectionHandler = nil;
    self.receivedFileURL = nil;
}

#pragma mark - certificate request
- (void)sendCertificateRequest
{
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    self.sendRequest = YES;
    [self presentModalViewController:picker animated:YES];
}


#pragma mark - mail comoposer delegate
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

#pragma mark - certificate request
- (void)manageCertificateRequest:(NSData*)request
{    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:request];
    
    XMLParser *parser = [[XMLParser alloc] initXMLParser];
    [xmlParser setDelegate:parser];
    
    BOOL success = [xmlParser parse];
    
    if(success)
        NSLog(@"XML parser succeeded!");
    else
        NSLog(@"A XML parser ERROR occured!");
    
    CertificateRequest *certRequest = parser.certRequest;
    
    NSLog(@"emailaddress: %@", certRequest.emailAddress);
    NSLog(@"phone number: %@", certRequest.phoneNumber);
    self.phoneNumber = certRequest.phoneNumber;
    
    MFMailComposeViewController* composer = [[MFMailComposeViewController alloc] init];
    [composer setToRecipients:[NSArray arrayWithObject:certRequest.emailAddress]];
    [composer setSubject:NSLocalizedString(@"My Certificate", @"Subject for certificate email in root view")];
    [composer setMessageBody:NSLocalizedString(@"You will receive the chechsum for my certificate shortly via SMS or iMessage", @"Body for certificate email in root view") isHTML:NO];
    composer.mailComposeDelegate = self;
    
    
    NSData *cert = [PersistentStore getActiveCertificateOfUser];
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cert.bytes, cert.length, macOut.mutableBytes);
    NSString *encoded =  [Base64 encode:macOut];
    self.hash = encoded;
    
    [composer addAttachmentData:cert mimeType:@"application/iaikencryption" fileName:@"cert.iaikcert"];
    
    self.certMailSent = YES;
    [self presentModalViewController:composer animated:YES];
    
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"tag: %d", textField.superview.tag);
    SecureContainer *container = [self.containers objectAtIndex:textField.superview.tag];
    //creating new path
    NSString* newpath = [[FilePathFactory applicationDocumentsDirectory] stringByAppendingPathComponent:textField.text];
    
    //check if the filename is allready present, checking if name is not an emtpy string
    if([[NSFileManager defaultManager] fileExistsAtPath:newpath] == YES && ![container.name isEqualToString:textField.text])
    {
        UIAlertView* alert;
        
        if([textField.text isEqualToString:@""])
        {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter a name", @"Title for alert in container detail view") 
                                               message:NSLocalizedString(@"Please enter a name for the container", @"Message for alert in container detail view") 
                                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        }
        else {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Container allready exists", @"Title for alert in container detail view") 
                                               message:NSLocalizedString(@"There seems to exist another container with the same namne, please choose a different one", @"Message for alert in container detail view") 
                                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        }
        
        [alert show];
        
        textField.text = container.name;
        
    }
    else if([container.name isEqualToString:textField.text] == NO)
    {
        //assigning container properties and renamind directory
        container.name = textField.text;
        
        NSError* err = 0;
        [[NSFileManager defaultManager] moveItemAtPath:container.basePath toPath:newpath error:&err];
        if (err) {
            [Error log:err];
        }
        
        container.basePath = newpath;
        
        //changing paths of the existing files
        NSMutableArray* newfileurls = [[NSMutableArray alloc] init];
        
        for(NSString __strong *file in container.fileUrls)
        {
            file = [container.basePath stringByAppendingPathComponent:[file lastPathComponent]];
            [newfileurls addObject:file];
        }
        
        container.fileUrls = newfileurls;
    }
    
    [textField endEditing:YES];
    return YES;
}


#pragma mark - dropbox integration
- (void)uploadFileToDropbox:(NSData*)encryptedContainer withName:(NSString*)name
{
    NSString *fileName = [NSString stringWithFormat:@"%@.iaikcontainer", name];
    NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    [encryptedContainer writeToFile:localPath atomically:YES];
    
    NSString *destDir = @"/Public";
    
    [[self restClient] uploadFile:fileName toPath:destDir
                    withParentRev:nil fromPath:localPath];
}

#pragma mark - dropbox file upload delegates
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata 
{
    [[self restClient] loadSharableLinkForFile:metadata.path];
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    if (error) {
        [Error log:error];
    }
}

#pragma mark - shareable link dropbox delegates
- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link 
           forFile:(NSString*)path
{
    UIAlertView* alert = nil;
    NSString *message = [NSString stringWithFormat:@"File uploaded successfully into your Public folder. Your public link to this file is %@", link];
    alert = [[UIAlertView alloc] initWithTitle:@"Dropbox Upload" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Send Link", @"Copy Link", nil];
    alert.delegate = self.handler;
    self.handler.fileUrl = link;
    self.handler.delegate = self;
    
    [alert show];
}

- (void)restClient:(DBRestClient*)restClient loadSharableLinkFailedWithError:(NSError*)error {
    if (error) {
        [Error log:error];
    }
}

- (void)showEmailMessageComposer:(Email*)mail {
    MFMailComposeViewController* composer = [[MFMailComposeViewController alloc] init];
    [composer setToRecipients:mail.recipients];
    [composer setSubject:mail.subject];
    [composer setMessageBody:mail.body isHTML:NO];
    composer.mailComposeDelegate = self;
        
    [self presentModalViewController:composer animated:YES];
}


@end
