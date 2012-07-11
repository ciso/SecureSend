//
//  UserSettingsViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "UserSettingsViewController.h"
#import "Validation.h"

@interface UserSettingsViewController ()

@end

@implementation UserSettingsViewController

@synthesize sender = _sender;

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
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        UILabel *nameLabel = (UILabel*)[cell viewWithTag:100];
        UITextField *textField = (UITextField*)[cell viewWithTag:101];
        
        NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:@"default_email"];
        nameLabel.text = @"Email";
        textField.text = email;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        UILabel *phoneLabel = (UILabel*)[cell viewWithTag:100];
        UITextField *textField = (UITextField*)[cell viewWithTag:101];
        
        NSString *phone = [[NSUserDefaults standardUserDefaults] stringForKey:@"default_phone"];
        phoneLabel.text = @"Phone";
        textField.text = phone;
        textField.keyboardType = UIKeyboardTypePhonePad;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        UILabel *nameLabel = (UILabel*)[cell viewWithTag:100];
        UITextField *textField = (UITextField*)[cell viewWithTag:101];
        
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"default_forename"];
        nameLabel.text = @"Forename";
        textField.text = username;
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        UILabel *nameLabel = (UILabel*)[cell viewWithTag:100];
        UITextField *textField = (UITextField*)[cell viewWithTag:101];
        
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"default_surname"];
        nameLabel.text = @"Surname";
        textField.text = username;
    }
    
    //returning table view cell
    return cell;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        //creating header label
        UILabel* headerLabel = [[UILabel alloc] init];
        headerLabel.frame = CGRectMake(30, 5, 220, 30);
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:17];
        headerLabel.text = @"   Mandatory";
        headerLabel.alpha = 1.0;
        
        return headerLabel;
    }
    else if (section == 1)
    {
        {
            //creating header label
            UILabel* headerLabel = [[UILabel alloc] init];
            headerLabel.frame = CGRectMake(30, 5, 220, 30);
            headerLabel.backgroundColor = [UIColor clearColor];
            headerLabel.textColor = [UIColor whiteColor];
            headerLabel.font = [UIFont boldSystemFontOfSize:17];
            headerLabel.text = @"   Optional";
            headerLabel.alpha = 1.0;
            
            return headerLabel;
        }
    }
    
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 65.0;
    }
    if (section == 1)
    {
        return 45.0;
    }
    
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        //creating footer label
        UILabel* footerLabel = [[UILabel alloc] init];
        footerLabel.frame = CGRectMake(20, 15, 280, 100);
        footerLabel.textAlignment = UITextAlignmentCenter;
        footerLabel.numberOfLines = 0;
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.textColor = [UIColor whiteColor];
        footerLabel.font = [UIFont systemFontOfSize:14];
        footerLabel.text =  [[NSString alloc] initWithFormat:@"The requested certificate will be sent to your\nemail address and the validation checksum\ndirectly to your phone."];
        footerLabel.alpha = 0.85;
        footerLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        return footerLabel;
    }
    if (section == 1)
    {
        NSString* device = @"iPhone";
        UIDevice* thisDevice = [UIDevice currentDevice];
        if (thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
            device = @"iPad";
        
        
        //creating footer label
        UILabel* footerLabel = [[UILabel alloc] init];
        footerLabel.frame = CGRectMake(20, 15, 280, 100);
        footerLabel.textAlignment = UITextAlignmentCenter;
        footerLabel.numberOfLines = 0;
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.textColor = [UIColor whiteColor];
        footerLabel.font = [UIFont systemFontOfSize:14];
        footerLabel.text =  [[NSString alloc] initWithFormat:@"You can change this later in the \nSettings of your %@.", device];
        footerLabel.alpha = 0.85;
        footerLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        return footerLabel;
    }
        

        
    
    return nil;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)doneButtonClicked:(UIBarButtonItem *)sender 
{
    UITableViewCell *emailCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITableViewCell *phoneCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITableViewCell *forenameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITableViewCell *surnameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];

    UITextField *emailTextField = (UITextField*)[emailCell viewWithTag:101];
    UITextField *phoneTextField = (UITextField*)[phoneCell viewWithTag:101];
    UITextField *forenameTextField = (UITextField*)[forenameCell viewWithTag:101];
    UITextField *surnameTextField = (UITextField*)[surnameCell viewWithTag:101];

    NSString *email = emailTextField.text;
    NSString *phone = phoneTextField.text;
    NSString *forename = forenameTextField.text;
    NSString *surname = surnameTextField.text;

    
    if (![Validation emailIsValid:email] || ![Validation phoneNumberIsValid:phone])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"Please enter a valid email address and/or phone number"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else 
    {
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

- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
