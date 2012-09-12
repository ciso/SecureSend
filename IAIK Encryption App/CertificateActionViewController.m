//
//  CertificateActionViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 13.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CertificateActionViewController.h"
#import "Validation.h"
#import "TextProvider.h"
#import "CertificateRequest.h"
#import "UserSettingsViewController.h"
#import "RootViewController.h"
#import "PersistentStore.h"
#import "TestFlight.h"

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
    //self.tableView.scrollEnabled = NO;
    
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
    return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        //beta
        [TestFlight passCheckpoint:@"SendCertificateTwoWay"];
        
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
    //beta
    [TestFlight passCheckpoint:@"SendCertificateBluetooth"];
    
    NSData *sendData = [PersistentStore getActiveCertificateOfUser];
    
    [self.btConnectionHandler sendDataToAll:sendData];
}

#pragma mark - BluetoothConnectionHandlerDelegate methods

- (void) receivedBluetoothData:(NSData*)data
{
    //beta
    [TestFlight passCheckpoint:@"ReceivedBluetoothData"];
    
    UITabBarController *tabBar = self.tabBarController;
    UINavigationController* navi = (UINavigationController*)[tabBar.viewControllers objectAtIndex:0];
    RootViewController* root = (RootViewController*)[navi.viewControllers objectAtIndex:0];
    
    root.receivedCertificateData = data;

    //showing people picker do identify owner of the certificate
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = root;
    [self presentModalViewController:picker animated:YES];
}

#pragma mark - ABPeoplePickerDelegate methods

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    self.sendRequest = NO;
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - certificate request
- (void)sendCertificateRequest
{
    //beta
    [TestFlight passCheckpoint:@"SendCertificateRequest"];
    
    
    UITabBarController *tabBar = self.tabBarController;
    UINavigationController* navi = (UINavigationController*)[tabBar.viewControllers objectAtIndex:0];
    RootViewController* root = (RootViewController*)[navi.viewControllers objectAtIndex:0];
    
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = root;//root;
    //self.sendRequest = YES;
    root.sendRequest = YES;
    [self presentModalViewController:picker animated:YES];
}



@end
