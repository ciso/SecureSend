//
//  CertificateXplorerViewController.m
//  IAIK Encryption App
//
//  Created by Christoph Hechenblaikner on 11.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CertificateXplorerViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/ABAddressBook.h>
#import "FilePathFactory.h"
#import "Crypto.h"
#import "KeyChainStore.h"


@interface CertificateXplorerViewController ()
{
    NSInteger selected_index;
}

@end

@implementation CertificateXplorerViewController

@synthesize relevantPeople = _relevantPeople, delegate = _delegate, expirationDates = _expirationDates;

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        selected_index = -1;
        
        ABAddressBookRef addressbookref = ABAddressBookCreate();
        NSArray* allpeople = (__bridge NSArray*) ABAddressBookCopyArrayOfAllPeople(addressbookref);
        
        Crypto* crypto = [Crypto getInstance];
        
        self.relevantPeople = [[NSMutableArray alloc] init];
        self.expirationDates = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < allpeople.count; i++)
        {
            ABRecordRef ref = (__bridge_retained  ABRecordRef)[allpeople objectAtIndex:i];
            
            NSString* identifier = [NSString stringWithFormat:@"%d", ABRecordGetRecordID(ref)];
            
            NSData *cert = [KeyChainStore dataForKey:identifier type:kDataTypeCertificate];
                
            if(cert != nil)
            {
                [self.relevantPeople addObject:(__bridge id)ref];
                [self.expirationDates addObject:[crypto getExpirationDateOfCertificate:cert]];
            }
        }
        
        
        //---------------------------DEBUG
        
        /* NSString* filePath = [[NSBundle mainBundle] pathForResource:@"user" ofType:@"der"];  
         NSData* myData = [NSData dataWithContentsOfFile:filePath];  
         
         ABRecordRef person = [allpeople objectAtIndex:0];
         
         NSString* identifier = [NSString stringWithFormat:@"%d",ABRecordGetRecordID(person)];
         
         if(myData && [KeyChainManager getCertificateofOwner:identifier] == nil)
         {
         [KeyChainManager addCertificate:myData withOwner:identifier];
         [self.relevantPeople addObject:[allpeople objectAtIndex:0]];
         }*/ 
        
        
        
        //-------------------------------
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
    
    if (self.relevantPeople.count == 0) {
        UIImage *image = [UIImage imageNamed:@"recipienthelp"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = 200;
        
        [self.view addSubview:imageView];

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
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.relevantPeople count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ABRecordRef person = (__bridge_retained ABRecordRef)[self.relevantPeople objectAtIndex:indexPath.row];
    
    NSString* firstname = (__bridge NSString*) ABRecordCopyValue(person,kABPersonFirstNameProperty);
    NSString* lastname = (__bridge NSString*) ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSString* name = [firstname stringByAppendingFormat:@" %@",lastname];
    
    cell.textLabel.text = name;
    
    NSString* datestring;
    
    NSDate* expirationdate = [self.expirationDates objectAtIndex:indexPath.row];
    
    if([expirationdate compare:[NSDate date]] == NSOrderedAscending)
    {
        //date is before today --> cert expired!!
        cell.imageView.image = [UIImage imageNamed:@"not_ok.png"];
        datestring  = NSLocalizedString(@"expired at ", @"Certificate date expired in certificate explorer");
    }
    else 
    {
        //date is after today --> cert valid
        cell.imageView.image = [UIImage imageNamed:@"checkmark.png"];
        datestring = NSLocalizedString(@"expires at ", @"Certificate date expires in certificate explorer");
    }
    
    //creating formatter and displaying expiration date
    NSDateFormatter* formatter= [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    datestring = [datestring stringByAppendingString:[formatter stringFromDate:[self.expirationDates objectAtIndex:indexPath.row]]];
    
    cell.detailTextLabel.text = datestring;
    
    return cell;
}

#pragma mark - UIActionSheetDelegate methods

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    switch (buttonIndex) {
//        case 0:
//        {
//            //deleting certificate
//            [self deleteSelectedCertificate];
//            
//            NSIndexPath* affected = [NSIndexPath indexPathForRow:selected_index inSection:0];
//            
//            //reloading data
//            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:affected] withRowAnimation:UITableViewRowAnimationRight];
//
//            break;
//        }
//        case 1:
//        {
//            //getting person
//            ABRecordRef person = (__bridge_retained ABRecordRef)[self.relevantPeople objectAtIndex:selected_index];
//            
//            NSString* mailaddress = (__bridge NSString*) ABRecordCopyValue(person, kABPersonEmailProperty);
//            
//            //creating and initialising mail composer
//            MFMailComposeViewController* mailcontroller = [[MFMailComposeViewController alloc] init];
//            [mailcontroller setToRecipients:[NSArray arrayWithObject:mailaddress]];
//            [mailcontroller setSubject:NSLocalizedString(@"Request for certificate", @"Subject for mail in certificate explorer")];
//            [mailcontroller setTitle:NSLocalizedString(@"Request for certificate", @"Title for mail in certificate explorer")];
//            [mailcontroller setMessageBody:NSLocalizedString(@"Please send me your IAIK enryption certificate", @"Body for mail in certificate explorer") isHTML:NO];
//            
//            [self presentModalViewController:mailcontroller animated:YES];
//            
//        }
//        default:
//            break;
//    }
//}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    selected_index = indexPath.row;
    
    //getting person
    ABRecordRef person = (__bridge_retained ABRecordRef)[self.relevantPeople objectAtIndex:indexPath.row];
    
    //getting id of person and certificate
    ABRecordID person_id =  ABRecordGetRecordID(person);
    
    NSString* identifier = [NSString stringWithFormat:@"%d",person_id];
    
    NSData *cert = [KeyChainStore dataForKey:identifier type:kDataTypeCertificate];
    
    //just debug
    NSString *temp = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)); //retrieving first name
    NSLog(@"temp: %@", temp); //works...
    
    //just an educated gues...
    ABRecordID idRec = ABRecordGetRecordID(person); //user id
    ABAddressBookRef addressBook = ABAddressBookCreate(); //addressbook
    ABMultiValueRef ref = ABRecordCopyValue(ABAddressBookGetPersonWithRecordID(addressBook, idRec), kABPersonEmailProperty);
    NSArray *emails = (__bridge NSArray *)(ABMultiValueCopyArrayOfAllValues(ref));
    NSLog(@"emails: %@", emails);
    
    //end of debug
    
    ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSArray *emailAddresses = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
    
    [self.delegate setCert:cert];
    [self.delegate setRecipientMail:[emailAddresses objectAtIndex:0]];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
//    selected_index = indexPath.row;
//    
//    UIActionSheet* certoptions = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Certificate", @"certificate") delegate:self 
//                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") 
//                                               destructiveButtonTitle:NSLocalizedString(@"Delete Certificate", @"Delete Certificate") 
//                                                    otherButtonTitles:NSLocalizedString(@"Request new certificate of contact", @"Button title in action sheet in certificate explorer"), 
//                                                                                        nil];
//    
//    [certoptions showInView:self.view];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    selected_index = indexPath.row;
    [self deleteSelectedCertificate];
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //TODO cover errors
    
    [self dismissModalViewControllerAnimated:YES];
}


-(IBAction)didCancel:(id)sender
{
    
    [self.presentingViewController dismissModalViewControllerAnimated:YES];    
}


-(void) deleteSelectedCertificate
{

    ABRecordRef ref = (__bridge_retained ABRecordRef)[self.relevantPeople objectAtIndex:selected_index];
    
    NSString* identifier = [NSString stringWithFormat:@"%d",ABRecordGetRecordID(ref)];
    
    
    if (![KeyChainStore removeItemForKey:identifier type:kDataTypeCertificate])
    {
        NSLog(@"Could not delete certificate in keychain");

    }
    
    [self.relevantPeople removeObjectAtIndex:selected_index];
    [self.expirationDates removeObjectAtIndex:selected_index];

}

-(void) dealloc
{
    self.delegate = nil;
    self.relevantPeople = nil;
    self.expirationDates = nil;
}

@end
