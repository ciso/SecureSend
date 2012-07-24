//
//  CreateNewCertificateViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 24.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CreateNewCertificateViewController.h"
#import "KeyChainManager.h"
#import "Crypto.h"

@interface CreateNewCertificateViewController ()

@property (nonatomic, strong) NSData *certificate;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *organization;
@property (nonatomic, strong) NSString *organizationUnit;

@end

@implementation CreateNewCertificateViewController

@synthesize certificate = _certificate;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize email = _email;
@synthesize country = _country;
@synthesize city = _city;
@synthesize organization = _organization;
@synthesize organizationUnit = _organizationUnit;

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
    self.certificate = [KeyChainManager getCertificateofOwner:CERT_ID_USER];
    
    if (self.certificate != nil)
    {
        NSLog(@"The user does already have a certificate!");
    }

    
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
    NSString *detail = @"";
    NSString *placeholder = @"";
    
    //section 1
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        title = @"Firstname";
        detail = @"";
        placeholder = @"Max";
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        title = @"Lastname";
        detail = @"";
        placeholder = @"Mustermann";
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        title = @"Email";
        detail = @"";
        placeholder = @"max@mustermann.at";
    }
    else if (indexPath.section == 0 && indexPath.row == 3)
    {
        title = @"Repeat Email";
        detail = @"";
        placeholder = @"max@mustermann.at";
    }
    //section 2
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        title = @"Country";
        detail = @"";
        placeholder = @"AT";
        //country, city, organization, organization unit
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        title = @"City";
        detail = @"";
        placeholder = @"Graz";
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        title = @"Organization";
        detail = @"";
        placeholder = @"Graz University of Technology";
    }
    else if (indexPath.section == 1 && indexPath.row == 3)
    {
        title = @"Org. Unit";
        detail = @"";
        placeholder = @"IAIK";
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
    [textField resignFirstResponder];
    BOOL nextExists = NO;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[textField superview] superview]];
    
    NSLog(@"row: %d, section: %d", indexPath.row, indexPath.section);

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
    
    if (nextExists)
    {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:nextRow inSection:nextSection];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
        UITextField *nextTextField = (UITextField*)[cell viewWithTag:101];
        
        NSLog(@"next: %@", nextTextField.text);
        
        [nextTextField becomeFirstResponder]; 
    }
    
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField 
{
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:(CustomCell*)[[textField superview] superview]]; // this should return you your current indexPath
    
//    // From here on you can (switch) your indexPath.section or indexPath.row
//    // as appropriate to get the textValue and assign it to a variable, for instance:
//    if (indexPath.section == kMandatorySection) {
//        if (indexPath.row == kEmailField) self.emailFieldValue = textField.text;
//        if (indexPath.row == kPasswordField) self.passwordFieldValue = textField.text;
//        if (indexPath.row == kPasswordConfirmField) self.passwordConfirmFieldValue = textField.text;
//    }
//    else if (indexPath.section == kOptionalSection) {
//        if (indexPath.row == kFirstNameField) self.firstNameFieldValue = textField.text;
//        if (indexPath.row == kLastNameField) self.lastNameFieldValue = textField.text;
//        if (indexPath.row == kPostcodeField) self.postcodeFieldValue = textField.text;
//    }   
}


#pragma mark- UINavigationBar buttons

- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveButtonClicked:(UIBarButtonItem *)sender 
{
    UITextField *firstNameTextField = (UITextField*)[[self tableView:self.tableView 
                                               cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:101];
    
    NSString *firstName = firstNameTextField.text;
    
    NSLog(@"firstname: %@", firstName);
//    
//    if(self.firstname.text.length == 0 || self.lastname.text.length == 0|| self.emailaddress.text.length == 0)
//    {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Mandatory data not present", @"Title of alert view in create certificate view") 
//                                                        message:NSLocalizedString(@"Please enter all required data to generate the certificate", @"Message of alert view in create certificate view") 
//                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        
//        [alert show];
//    }
//    else 
//    {     
//        //creating certificate from user input
//        Crypto *crypto = [Crypto getInstance];
//        
//        UIView* load = [LoadingView showLoadingViewInView:self.view withMessage:NSLocalizedString(@"Creating Certificate", @"Loading text in create certificate view")];
//        
//        //running key and cert generation in own thread
//        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//            //create a rsa key
//            NSData *key = [crypto createRSAKeyWithKeyLength:2048];
//            
//            if([KeyChainManager addUsersPrivateKey:key] == NO)
//            {
//                NSLog(@"NEIIIIIIIIIIIINNNNN");
//            }
//            
//            //create new certificate based on the before created key
//            NSData* cert = [crypto createX509CertificateWithPrivateKey:key 
//                                                              withName:self.firstname.text
//                                                          emailAddress:self.lastname.text
//                                                               country:self.countrycode.text 
//                                                                  city:self.city.text
//                                                          organization:self.organisation.text
//                                                      organizationUnit:self.organisationalunit.text];
//            
//            
//            if([KeyChainManager addCertificate:cert withOwner:CERT_ID_USER] == NO)
//            {
//                NSLog(@"NEEEEIIIIINNN");
//            }
//            
//            dispatch_async( dispatch_get_main_queue(), ^{
//                
//                [load removeFromSuperview];
//                
//                [self dismissModalViewControllerAnimated:YES];
//                
//            });
//        });
//        
//    }

}




@end
