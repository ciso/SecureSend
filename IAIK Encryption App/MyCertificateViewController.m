//
//  MyCertificateViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 23.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "MyCertificateViewController.h"
#import "PersistentStore.h"
#import "X509CertificateUtil.h"
#import "CreateNewCertificateViewController.h"
#import "TestFlight.h"

#define SEGUE_TO_CERT_ASS @"toCertSendAssist"

@interface MyCertificateViewController ()

@property (nonatomic, strong) NSData *certificate;

@end

@implementation MyCertificateViewController

@synthesize certificate = _certificate;
@synthesize btConnectionHandler = _btConnectionHandler;

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
    
    [self loadCertificate];

    self.tableView.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openHiddenDeveloperView)];
    [self.navigationController.navigationBar addGestureRecognizer:gesture];
    
    //allocating bluetooth connection handler
    self.btConnectionHandler = [[BluetoothConnectionHandler alloc] init];
    
}

- (void)openHiddenDeveloperView {
    [self performSegueWithIdentifier:@"toHiddenDeveloperView" sender:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)loadCertificate {
    self.certificate = [PersistentStore getActiveCertificateOfUser];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        return 7;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        
        //generics
        cell.textLabel.textColor = [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:51.0/255.0 alpha:1.0];
        cell.textLabel.text = @"Send Certificate via Bluetooth";
        cell.detailTextLabel.text = @"Send your certificate to another person via a Bluetooth connection";
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        //generics
        cell.textLabel.textColor = [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:51.0/255.0 alpha:1.0];
        cell.textLabel.text = @"Send Certificate via Email";
        cell.detailTextLabel.numberOfLines = 4;
        cell.detailTextLabel.text = @"Send your certificate to another person via a two-way exchange using Email for sending your certificate and SMS for an unique verification checksum";
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        //generics
        cell.textLabel.textColor = [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:51.0/255.0 alpha:1.0];
        cell.textLabel.text = @"Create new Certificate";
        cell.detailTextLabel.text = @"You can create a new certificate here. Use this only if you really need a new certificate. For example if your old one is leaked or has been stolen";
    }
    else if (indexPath.section == 2) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];

        NSString *title = @"";
        NSString *detail = @"";
        
        if (indexPath.section == 2 && indexPath.row == 0)
        {
            title = @"Name";
            
            detail = [X509CertificateUtil getCommonName:self.certificate];
        }
        else if (indexPath.section == 2 && indexPath.row == 1)
        {
            title = @"Email";
            
            detail = [X509CertificateUtil getEmail:self.certificate];
        }
        else if (indexPath.section == 2 && indexPath.row == 2)
        {
            title = @"Expires";
            
            NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            NSString *datestring = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[X509CertificateUtil getExpirationDate:self.certificate]]];
            
            detail = datestring;
        }
        else if (indexPath.section == 2 && indexPath.row == 3)
        {
            title = @"Serial";
            
            detail = [X509CertificateUtil getSerialNumber:self.certificate];
        }
        else if (indexPath.section == 2 && indexPath.row == 4)
        {
            title = @"Org.";
            
            detail = [X509CertificateUtil getOrganization:self.certificate];
        }
        else if (indexPath.section == 2 && indexPath.row == 5)
        {
            title = @"Org. Unit";
            
            detail = [X509CertificateUtil getOrganizationUnit:self.certificate];
        }
        else if (indexPath.section == 2 && indexPath.row == 6)
        {
            title = @"City";
            
            detail = [X509CertificateUtil getCity:self.certificate];
        }
        
        // Configure the cell...
        cell.textLabel.text = title;
        cell.detailTextLabel.text = detail;
    }
    

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
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
    else {
        return 44.0;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *ret = nil;
    
    if (section == 2) {
        ret = @"Certificate";
    }
    
    return ret;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"createNewCertSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
            
            if ([[nav.viewControllers objectAtIndex:0] isKindOfClass:[CreateNewCertificateViewController class]]) {

                CreateNewCertificateViewController *destination = (CreateNewCertificateViewController*)[nav.viewControllers objectAtIndex:0];
                destination.owner = self;
            }
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self sendCertificateBluetooth];
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        //beta
        [TestFlight passCheckpoint:@"SendCertificateTwoWay"];
        
        [self performSegueWithIdentifier:SEGUE_TO_CERT_ASS sender:nil];
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"createNewCertSegue" sender:nil];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - methods to send certificate

-(void) sendCertificateBluetooth
{
    //beta
    [TestFlight passCheckpoint:@"SendCertificateBluetooth"];
    
    NSData *sendData = [PersistentStore getActiveCertificateOfUser];
    
    [self.btConnectionHandler sendDataToAll:sendData];
}

@end
