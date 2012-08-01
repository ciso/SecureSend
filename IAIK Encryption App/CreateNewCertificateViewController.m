//
//  CreateNewCertificateViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 24.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CreateNewCertificateViewController.h"
#import "Crypto.h"
#import "Validation.h"
#import "LoadingView.h"
#import "PersistentStore.h"

@interface CreateNewCertificateViewController ()

@property (nonatomic, strong) NSData *certificate;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *repeatEmail;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *organization;
@property (nonatomic, strong) NSString *organizationUnit;
@property (nonatomic, strong) NSIndexPath *activeIndexPath;
@property (nonatomic, strong) UITextField *activeTextField;

- (NSIndexPath*)getIndexPathForField:(FieldTypes)type;
- (void)assumeInput:(NSString*)input withIndexPath:(NSIndexPath*)indexPath;

@end

@implementation CreateNewCertificateViewController

@synthesize certificate      = _certificate;
@synthesize firstName        = _firstName;
@synthesize lastName         = _lastName;
@synthesize email            = _email;
@synthesize repeatEmail      = _repeatEmail;
@synthesize country          = _country;
@synthesize city             = _city;
@synthesize organization     = _organization;
@synthesize organizationUnit = _organizationUnit;
@synthesize activeIndexPath  = _activeIndexPath;
@synthesize activeTextField  = _activeTextField;

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
    
    //check if the user is obtaining his first certificate
    //or renewing an old one    
    self.certificate = [PersistentStore getActiveCertificateOfUser];
    
    if (self.certificate != nil)
    {
        NSLog(@"The user does already have a certificate!");
    }
    
    //maybe set values from existing certificate here
    self.firstName        = @"";
    self.lastName         = @"";
    self.email            = @"";
    self.repeatEmail      = @"";
    self.country          = @"";
    self.city             = @"";
    self.organization     = @"";
    self.organizationUnit = @"";
    
    //touch recognizer to hide keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    
    
    //IMPORTANT: JUST TEMP!!!! REMOVE IN FINAL VERSION!!! todo
    [self assumeSampleInput];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)dismissKeyboard 
{
    //resigning first responder
    if (self.activeTextField != nil)
    {
        [self.activeTextField resignFirstResponder];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = 0;
    if (section == 0)
    {
        ret = 4;
    }
    else if (section == 1)
    {
        ret = 4;
    }
    
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:100];
    UITextField *textfield = (UITextField*)[cell viewWithTag:101];
    textfield.delegate = self;
    
    NSString *title = @"";
    NSString *detail;
    NSString *placeholder = @"";
    
    
    
    switch ([self getFieldTypeForIndexPath:indexPath])
    {
        case kFieldFirstName:
            title = @"Firstname";
            detail = self.firstName;
            placeholder = @"Max";
            break;
        case kFieldLastName:
            title = @"Lastname";
            detail = self.lastName;
            placeholder = @"Mustermann";
            break;
        case kFieldEmail:
            title = @"Email";
            detail = self.email;
            placeholder = @"max@mustermann.at";
            textfield.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        case kFieldRepeatEmail:
            title = @"Repeat Email";
            detail = self.repeatEmail;
            placeholder = @"max@mustermann.at";
            textfield.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        case kFieldCountry:
            title = @"Country";
            detail = self.country;
            placeholder = @"AT";
            break;
        case kFieldCity:
            title = @"City";
            detail = self.city;
            placeholder = @"Graz";
            break;
        case kFieldOrganization:
            title = @"Organization";
            detail = self.organization;
            placeholder = @"Graz University of Technology";
            break;
        case kFieldOrganizationUnit:
            title = @"Org. Unit";
            detail = self.organizationUnit;
            placeholder = @"IAIK";
            break;  
    }

    titleLabel.text = title;
    textfield.text = detail;
    textfield.placeholder = placeholder;
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *ret = nil;
    if (section == 0)
    {
        ret = @"Mandatory Fields";
    }
    else if (section == 1)
    {
        ret = @"Optional Fields";
    }
    
    return ret;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *ret = nil;
    if (section == 0)
    {
        ret = @"Maecenas sed diam eget risus varius blandit sit amet non magna. Integer posuere erat a ante venenatis dapibus posuere velit aliquet.";
    }
    else if (section == 1)
    {
        ret = @"Etiam porta sem malesuada magna mollis euismod.";
    }
    
    return ret;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL nextExists = NO;
    
    [textField resignFirstResponder];    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[textField superview] superview]];
    
    //check if there is another row in this section
    NSInteger nextRow = 0;
    NSInteger nextSection = 0;
    if (indexPath.row+1 < [self.tableView numberOfRowsInSection:indexPath.section])
    {
        nextRow = indexPath.row + 1;
        nextSection = indexPath.section;
        nextExists = YES;
    }
    else if ((indexPath.row+1 == [self.tableView numberOfRowsInSection:indexPath.section]) 
             && indexPath.section < [self.tableView numberOfSections])
    {
        nextRow = 0; 
        nextSection = indexPath.section + 1;
        nextExists = YES;
    }
    
    //there exist a next row
    if (nextExists)
    {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:nextRow inSection:nextSection];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
        UITextField *nextTextField = (UITextField*)[cell viewWithTag:101];

        [nextTextField becomeFirstResponder]; 
    }
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = (NSIndexPath*)[self.tableView indexPathForCell:(UITableViewCell*)[[textField superview] superview]];
    
    self.activeTextField = textField;
    self.activeIndexPath = indexPath;
}

- (void)textFieldDidEndEditing:(UITextField *)textField 
{
    NSString *input = textField.text;    
    
    //assuming values from input textfield into corresponding properties
    [self assumeInput:input withIndexPath:self.activeIndexPath];
    
    self.activeTextField = nil;
    self.activeTextField = nil;
}

#pragma mark- UINavigationBar buttons

- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveButtonClicked:(UIBarButtonItem *)sender 
{    
    //assuming input from active field (didEndEditing _not_ called right now!)
    if (self.activeTextField != nil && self.activeIndexPath != nil)
    {
        [self assumeInput:self.activeTextField.text withIndexPath:self.activeIndexPath];   
    }
    
    //test output
    NSLog(@"firstName: %@", self.firstName);
    NSLog(@"lastName: %@", self.lastName);
    NSLog(@"email: %@", self.email);
    NSLog(@"repeatEmail: %@", self.repeatEmail);
    NSLog(@"country: %@", self.country);
    NSLog(@"city: %@", self.city);
    NSLog(@"organization: %@", self.organization);
    NSLog(@"organizationUnit: %@", self.organizationUnit);
        
    //resigning first responder of textfield
    [self.activeTextField resignFirstResponder];
    
    
    //check if first- and lastname is long enough
    if ([self.firstName length] < 3
        || [self.lastName length] < 3)
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"SecureSend" 
                                                             message:@"Firstname or lastname not long enough." 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil];
        
        [errorAlert show];
        return;
    }
    
    //check if email is entered correctly (twice)
    if (![self.email isEqualToString:self.repeatEmail])
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"SecureSend" 
                                                             message:@"Email confirmation not equal." 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil];
        [errorAlert show];
        return;
    }
    
    //check if email hast the correct format
    if (![Validation emailIsValid:self.email])
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"SecureSend" 
                                                             message:@"Email is not valid." 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil];
        [errorAlert show];
        return;
    }

    
    //VALIDATION SUCCEEDED
    //---------------------------------
    
    Crypto *crypto = [Crypto getInstance];
    
    self.tableView.scrollEnabled = NO;
    UIView *load = [LoadingView showLoadingViewInView:self.tableView withMessage:@"Creating Certificate"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *key = [crypto createRSAKeyWithKeyLength:2048];
                    
        //adding users' private key into keychain
//        if([KeyChainManager addUsersPrivateKey:key] == NO)
//        {
//            NSLog(@"Error occured when adding private key of user into Keychain!");
//        }
        
        //create new certificate based on the before created key
        NSData* cert = [crypto createX509CertificateWithPrivateKey:key 
                                                          withName:self.firstName
                                                      emailAddress:self.lastName
                                                           country:self.country 
                                                              city:self.city
                                                      organization:self.organization
                                                  organizationUnit:self.organizationUnit];
        
        //adding users' certificate into keychain
        //old
//        if([KeyChainManager addCertificate:cert withOwner:CERT_ID_USER] == NO)
//        {
//            NSLog(@"Error occured when adding certificate of user into Keychain!");
//        }
        
        
        
        //new
        [PersistentStore storeForUserCertificate:cert privateKey:key]; //test
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.scrollEnabled = YES; //should not change anything...
            [load removeFromSuperview];
            [self dismissModalViewControllerAnimated:YES];
        });
    });
}


#pragma mark - Helper
- (NSIndexPath*)getIndexPathForField:(FieldTypes)type
{
    NSInteger row = -1;
    NSInteger section = -1;
    switch (type)
    {
        case kFieldFirstName:
            row     = 0;
            section = 0;
            break;
        case kFieldLastName:
            row     = 1;
            section = 0;
            break;
        case kFieldEmail:
            row     = 2;
            section = 0;
            break;
        case kFieldRepeatEmail:
            row     = 3;
            section = 0;
            break;
        case kFieldCountry:
            row     = 0;
            section = 1;
            break;
        case kFieldCity:
            row     = 1;
            section = 1;
            break;
        case kFieldOrganization:
            row     = 2;
            section = 1;
            break;
        case kFieldOrganizationUnit:
            row     = 3;
            section = 1;
            break;
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (FieldTypes)getFieldTypeForIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        return kFieldFirstName;
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        return kFieldLastName;
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        return kFieldEmail;
    }
    else if (indexPath.section == 0 && indexPath.row == 3)
    {
        return kFieldRepeatEmail;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        return kFieldCountry;
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        return kFieldCity;
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        return kFieldOrganization;
    }
    else if (indexPath.section == 1 && indexPath.row == 3)
    {
        return kFieldOrganizationUnit;
    }

    return 0;
}

- (FieldTypes)getFieldTypeForAccessibilityIdentifier:(NSString*)identifier
{
    if (identifier.intValue == 0)
    {
        return kFieldFirstName;
    }
    else if (identifier.intValue == 1)
    {
        return kFieldLastName;
    }
    else if (identifier.intValue == 2)
    {
        return kFieldEmail;
    }
    else if (identifier.intValue == 3)
    {
        return kFieldRepeatEmail;
    }
    else if (identifier.intValue == 4)
    {
        return kFieldCountry;
    }
    else if (identifier.intValue == 5)
    {
        return kFieldCity;
    }
    else if (identifier.intValue == 6)
    {
        return kFieldOrganization;
    }
    else if (identifier.intValue == 7)
    {
        return kFieldOrganizationUnit;
    }
    
    return 0;
}

- (void)assumeInput:(NSString*)input withIndexPath:(NSIndexPath*)indexPath
{
    //assuming values from input textfield into corresponding properties
    switch ([self getFieldTypeForIndexPath:indexPath])
    {
        case kFieldFirstName:
            self.firstName = input;
            break;
        case kFieldLastName:
            self.lastName = input;
            break;
        case kFieldEmail:
            self.email = input;
            break;
        case kFieldRepeatEmail:
            self.repeatEmail = input;
            break;
        case kFieldCountry:
            self.country = input;
            break;
        case kFieldCity:
            self.city = input;
            break;
        case kFieldOrganization:
            self.organization = input;
            break;
        case kFieldOrganizationUnit:
            self.organizationUnit = input;
            break;  
    }
    
}

- (void)assumeSampleInput
{
    self.firstName = @"Christof";
    self.lastName = @"Stromberger";
    self.email = @"stromberger@student.tugraz.at";
    self.repeatEmail = @"stromberger@student.tugraz.at";
    self.country = @"AT";
    self.city = @"Graz";
    self.organization = @"Graz University of Technology";
    self.organizationUnit = @"IAIK";
}

@end
