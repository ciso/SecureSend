//
//  UserSettingsViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "UserSettingsViewController.h"
#import "Validation.h"
#import "X509CertificateUtil.h"
#import "PersistentStore.h"

@interface UserSettingsViewController ()

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) UITextField *activeTextField;
@property (nonatomic, strong) NSIndexPath *activeIndexPath;

@end

@implementation UserSettingsViewController

@synthesize sender          = _sender;
@synthesize email           = _email;
@synthesize phone           = _phone;
@synthesize name            = _name;
@synthesize surname         = _surname;
@synthesize activeTextField = _activeTextField;
@synthesize activeIndexPath = _activeIndexPath;

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
    
    //getting users certificate
    NSData *certificate = [PersistentStore getActiveCertificateOfUser];
    NSString *commonName = [X509CertificateUtil getCommonName:certificate];
    NSArray *tokens = [commonName componentsSeparatedByString:@" "];
        
    //assuming default values
    self.email   = [X509CertificateUtil getEmail:certificate];
    self.phone   = @"";
    self.name    = [tokens objectAtIndex:0];
    self.surname = [tokens lastObject];
    
    //touch recognizer to hide keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard
{
    //resigning first responder
    if (self.activeTextField != nil)
    {
        [self.activeTextField resignFirstResponder];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        ret = 2;
    }
    else if (section == 1)
    {
        ret = 2;
    }
    
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSString *placeholder = nil;
    
    UILabel *detailLabel = (UILabel*)[cell viewWithTag:100];
    UITextField *textField = (UITextField*)[cell viewWithTag:101];
    textField.delegate = self;
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        detailLabel.text = NSLocalizedString(@"Email", @"Text in user settings view");
        textField.text = self.email;
        placeholder = @"max@mustermann.at";
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        detailLabel.text = NSLocalizedString(@"Phone", @"Text in user settings view");
        textField.text = self.phone;
        placeholder = @"0664 1234567";
        textField.keyboardType = UIKeyboardTypePhonePad;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        detailLabel.text = NSLocalizedString(@"Name", @"Text in user settings view");
        placeholder = @"Max";
        textField.text = self.name;
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        detailLabel.text = NSLocalizedString(@"Surname", @"Text in user settings view");
        placeholder = @"Mustermann";
        textField.text = self.surname;
    }
    
    textField.placeholder = placeholder;
    
    //returning table view cell
    return cell;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Mandatory", @"Section headline in user settings view");
    }
    else if (section == 1) {
        return NSLocalizedString(@"Optional", @"Section headline in user settings view");
    }
    
    return nil;
}



- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"The requested certificate will be sent to your email address and the validation checksum directly to your phone.",
                                 @"Footer text in user setting view");
    }
    else if (section == 1) {
        return NSLocalizedString(@"You can change this later in the Settings of your iPhone",
                          @"Footer text in user settings view");
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)doneButtonClicked:(UIBarButtonItem *)sender 
{
    //assuming input from active field (didEndEditing _not_ called right now!)
    if (self.activeTextField != nil && self.activeIndexPath != nil)
    {
        [self assumeInput:self.activeTextField.text withIndexPath:self.activeIndexPath];
    }
    
    NSString *email = self.email;
    NSString *phone = self.phone;
    
    if (![Validation emailIsValid:email] || ![Validation phoneNumberIsValid:phone])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Title of alert view in user settings view") 
                                                        message:NSLocalizedString(@"Please enter a valid email address and/or phone number", @"Message of alert view in user settings view")
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else 
    {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Email: %@\nPhone: %@", @"Message of alert view in user settings view"), email, phone];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Is this correct?", @"Title of alert view in user settings view")
                                                        message:message
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"NO", @"...")
                                              otherButtonTitles:NSLocalizedString(@"YES", @"..."), nil];
        [alert show];
    }
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *input = textField.text;
    
    //assuming values from input textfield into corresponding properties
    [self assumeInput:input withIndexPath:self.activeIndexPath];
    
    self.activeTextField = nil;
    self.activeTextField = nil;
}

- (void)assumeInput:(NSString*)input withIndexPath:(NSIndexPath*)indexPath {
    //assuming values from input textfield into corresponding properties
    if (indexPath.section == 0 && indexPath.row == 0) {
        self.email = input;
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        self.phone = input;
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        self.name = input;
    }
    else  if (indexPath.section == 1 && indexPath.row == 1) {
        self.surname = input;
    }
    
}

#pragma mark - UIAlertViewDelegateMethods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0)
    {
        NSString *email = self.email;
        NSString *phone = self.phone;
        NSString *forename = self.name;
        NSString *surname = self.surname;
        
        //setting new userinfo
        [[NSUserDefaults standardUserDefaults] setValue:email forKey:@"default_email"];
        [[NSUserDefaults standardUserDefaults] setValue:phone forKey:@"default_phone"];
        [[NSUserDefaults standardUserDefaults] setValue:forename forKey:@"default_forename"];
        [[NSUserDefaults standardUserDefaults] setValue:surname forKey:@"default_surname"];
        
        if ([self.sender respondsToSelector:@selector(openMailComposer)])
        {
            [self dismissModalViewControllerAnimated:NO];
            
            [self.sender performSelector:@selector(openMailComposer)];
            
        }
        else 
        {
            [self dismissModalViewControllerAnimated:YES];        
        }
    }

}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    
}

- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
