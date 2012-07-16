//
//  ContainerDetailViewController.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Crypto.h"
#import "ContainerDetailViewController.h"
#import "SecureContainer.h"
#import "SourceSelectionViewController.h"
#import "AppDelegate.h"
#import "FilePathFactory.h"
#import "NameCell.h"
#import "ZipArchive.h"
#import "KeyChainManager.h"
#import "CertificateXplorerViewController.h"
#import "LoadingView.h"
#import "PreviewViewController.h"

@interface ContainerDetailViewController() {
@private
    NSInteger rowAddFile;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@end

@implementation ContainerDetailViewController

#define SECTION_NAME 0
#define SECTION_ACTION 2
#define SECTION_FILES 1
#define NUMBER_ROWS_INFOS 1
#define NUMBER_SECTIONS 3
#define NUMBER_ROWS_ACTION 1
#define ROW_SEND_CONTAINER 0
#define ROW_NAME 0

#define SEGUE_TO_SOURCESEL @"toSourceSelectionViewController"
#define SEGUE_TO_XPLORER @"toCertificateXplorer"
#define SEGUE_TO_PREVIEW @"toPreviewImageScreen"
#define SEGUE_TO_SOURCESELVIEW @"toSourceSelectionView"
#define SEGUE_TO_ENCRYPT @"toEncryptAndSend"

@synthesize container, currentCertificate = _currentCertificate;
@synthesize popoverController=_myPopoverController;
@synthesize photos = _photos;
@synthesize shouldRotateToPortrait = _shouldRotateToPortrait;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    
//    [self showTabBar:self.tabBarController];
}

//- (void) showTabBar:(UITabBarController *) tabbarcontroller {
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
//    for(UIView *view in tabbarcontroller.view.subviews)
//    {
//        NSLog(@"%@", view);
//        
//        if([view isKindOfClass:[UITabBar class]])
//        {
//            [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];
//            
//        } 
//        else 
//        {
//            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
//        }
//        
//        
//    }
//    
//    [UIView commitAnimations]; 
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];

//    if (self.shouldRotateToPortrait)
//    {
//        self.shouldRotateToPortrait = NO;
//        
//        UIViewController *c = [[UIViewController alloc]init];
//        [self presentModalViewController:c animated:NO];
//        [self dismissModalViewControllerAnimated:NO];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(section == SECTION_FILES)
    {
        rowAddFile = [self.container.fileUrls count];
        return rowAddFile + 1;
    }
    else if(section == SECTION_ACTION)
        return NUMBER_ROWS_ACTION;
    
    else if(section == SECTION_NAME)
        return NUMBER_ROWS_INFOS;
    else
        return [self.container.fileUrls count];
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_NAME)
    {
        if(indexPath.row == ROW_NAME)
        {
            NameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NameCell"];
            
            cell.nameField.text = self.container.name;
            
            return cell;
        }
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    if(indexPath.section == SECTION_FILES)
    {
        if(indexPath.row == rowAddFile)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"Add file", @"Text for cell label in container detail view. This label is the action button for adding a new file to a container");
        }
        else
        {
            //get path of file
            NSString* path = [container.fileUrls objectAtIndex:indexPath.row];
            cell.textLabel.text = [path lastPathComponent];
            
            //test
            NSError *error;
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
            NSLog(@"attributes: %@", attributes);
            
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
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
            
            
            //check extensions
            if([[path pathExtension] isEqualToString:EXTENSION_JPG] 
               || [[path pathExtension] isEqualToString:EXTENSION_JPEG]
               || [[path pathExtension] isEqualToString:EXTENSION_GIF]
               || [[path pathExtension] isEqualToString:EXTENSION_PNG]
               || [[path pathExtension] isEqualToString:EXTENSION_PDF])
            {
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else 
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    else if(indexPath.section == SECTION_ACTION)
    {
        if(indexPath.row == ROW_SEND_CONTAINER)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"Encrypt / Share container", @"Text for cell label in container detail view. This button is for encrypt and share container");
        }
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if(section == SECTION_ACTION)
        return NSLocalizedString(@"Actions", @"Headline for action section in container detail");
    else if(section == SECTION_FILES)
        return NSLocalizedString(@"Files", @"Headline for files section in container detail");
    else if(section == SECTION_NAME)
        return NSLocalizedString(@"Name", @"Headline for name section in container detail");
    else
        return NSLocalizedString(@"ERROR", @"Headline for erro section. Should not occur");
    
    return NSLocalizedString(@"Files in Container", @"Headline for section in container detail");
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_ACTION)
    {
        if(indexPath.row == ROW_SEND_CONTAINER)
        {
            [self performSegueWithIdentifier:SEGUE_TO_XPLORER sender:nil];
        }
    }
    else if(indexPath.section == SECTION_FILES)
    {
        if(indexPath.row == rowAddFile)
        {
            [self addFile];
        }
        else 
        {
            
            
            //teeeeest! debug
            self.shouldRotateToPortrait = YES;
            
            NSString* path = [self.container.fileUrls objectAtIndex:indexPath.row];
            
            
            //test
            NSString *pathExtension = [path pathExtension];
            
            if ([pathExtension isEqualToString:EXTENSION_JPG] 
                || [pathExtension isEqualToString:EXTENSION_JPEG]
                || [pathExtension isEqualToString:EXTENSION_PNG]
                || [pathExtension isEqualToString:EXTENSION_GIF])
            {
                NSMutableArray *photos = [[NSMutableArray alloc] init];
                MWPhoto *photo;
                
                UIImage *temp = [UIImage imageWithContentsOfFile:path];
                if (temp.imageOrientation == UIImageOrientationUp)
                {
                    NSLog(@"UP");
                }
                else if (temp.imageOrientation == UIImageOrientationDown)
                {
                    NSLog(@"DOWN");
                }
                else if (temp.imageOrientation == UIImageOrientationLeft)
                {
                    NSLog(@"LEFT");
                }
                else if (temp.imageOrientation == UIImageOrientationRight)
                {
                    NSLog(@"RIGHT");
                }
                
                photo = [MWPhoto photoWithFilePath:path];
                
                [photos addObject:photo];
                
                self.photos = photos;

                
                // Create browser
                MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
                browser.displayActionButton = NO;
                
                [self.navigationController pushViewController:browser animated:YES];
            }
            else if ([pathExtension isEqualToString:EXTENSION_PDF])
            {
                [self performSegueWithIdentifier:SEGUE_TO_PREVIEW sender:path];
            }
 
                //old preview
//            NSString* pathextension = [path pathExtension];
//            if([pathextension isEqualToString:EXTENSION_JPG] || [pathextension isEqualToString:EXTENSION_PDF])
//            {
//                [self performSegueWithIdentifier:SEGUE_TO_PREVIEW sender:path];
//            }
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//test
#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_FILES && indexPath.row != rowAddFile)
        return YES;
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSError * error;
    if([[NSFileManager defaultManager] removeItemAtPath:[self.container.fileUrls objectAtIndex:indexPath.row] error:&error] == NO)
    {
        NSLog(@"Problem deleting file");
        
        //TODO error description
    }
    
    [self.container.fileUrls removeObjectAtIndex:indexPath.row];
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//    UIView *hView = [[UIView alloc] initWithFrame:CGRectZero];
//    hView.backgroundColor=[UIColor clearColor];
//    
//    UILabel *hLabel=[[UILabel alloc] initWithFrame:CGRectMake(19,10,301,21)];
//    
//    hLabel.backgroundColor=[UIColor clearColor];
//    hLabel.shadowColor = [UIColor blackColor];
//    hLabel.shadowOffset = CGSizeMake(0.5,1);
//    hLabel.textColor = [UIColor whiteColor];
//    hLabel.font = [UIFont boldSystemFontOfSize:17];
//    hLabel.text = [self tableView:tableView titleForHeaderInSection:section];
//    
//    [hView addSubview:hLabel];
//        
//    return hView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return 60;
    }
    else
    {
        return 45;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //creating new path
    NSString* newpath = [[FilePathFactory applicationDocumentsDirectory] stringByAppendingPathComponent:textField.text];
    
    //check if the filename is allready present, checking if name is not an emtpy string
    if([[NSFileManager defaultManager] fileExistsAtPath:newpath] == YES && ![self.container.name isEqualToString:textField.text])
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
        
        textField.text = self.container.name;
        
    }
    else if([self.container.name isEqualToString:textField.text] == NO)
    {
        //assigning container properties and renamind directory
        self.container.name = textField.text;
        
        NSError* err = 0;
        [[NSFileManager defaultManager] moveItemAtPath:self.container.basePath toPath:newpath error:&err];
        if(err != 0)
        {
            NSLog(@"Problem renaming container directory!!");
        }
        
        self.container.basePath = newpath;
        
        //changing paths of the existing files
        NSMutableArray* newfileurls = [[NSMutableArray alloc] init];
        
        for(NSString __strong *file in self.container.fileUrls)
        {
            file = [self.container.basePath stringByAppendingPathComponent:[file lastPathComponent]];
            [newfileurls addObject:file];
        }
        
        self.container.fileUrls = newfileurls;
    }
    
    [textField endEditing:YES];
    return YES;
}

#pragma mark - ModifyContainerPropertyDelegate methods

-(void) addFilesToContainer:(NSArray*) filePaths
{
    [self.container.fileUrls addObjectsFromArray:filePaths];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_FILES] withRowAnimation:UITableViewRowAnimationRight];
    //todo! didn't work after refactoring of iPad UI
    
    //[self.tableView reloadData]; 
}

-(IBAction)addFile
{
    [self performSegueWithIdentifier:SEGUE_TO_SOURCESEL sender:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //TODO cover errors
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ModifyCertPropertyDelegate methods

-(void) setCert: (NSData*) cert
{
    self.currentCertificate = cert;
    
    [self dismissModalViewControllerAnimated:YES];
    
    
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose action", @"Title for alert in container detail view") delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:/*NSLocalizedString(@"Share via Dropbox",  @"Alert button in container detail view to share container using Dropbox"),*/ 
                             NSLocalizedString(@"Send Container via Email", @"Button in alter view in container detail view for sending a container via email"), nil];
    
    [action showInView:self.view];
    
}

#pragma mark - methods for sharing container

-(void) sendContainerMail: (NSData*) data
{
    
    //creating and initialising mail composer
    MFMailComposeViewController* mailcontroller = [[MFMailComposeViewController alloc] init];
    [mailcontroller setSubject:NSLocalizedString(@"Container", @"Subject for mail when sending an encrypted container in container detail view")];
    [mailcontroller setTitle:NSLocalizedString(@"Secure files via container", @"Title for mail when sending an encrypted container in container detail view")];
    mailcontroller.mailComposeDelegate = self;
    
    
    //attaching encrypted file to mail
    NSString* filename = [self.container.name stringByAppendingPathExtension:@"iaikcontainer"];
    
    [mailcontroller addAttachmentData:data mimeType:@"application/iaikencryption" fileName:filename];
    
    [self presentModalViewController:mailcontroller animated:YES];
}


#pragma mark - methods for encrypting/zipping containers

-(NSData*) zipAndEncryptContainer
{    
    
    //Creating zipper for compressing data
    ZipArchive* zipper = [[ZipArchive alloc] init];
    
    NSString* zippath = [FilePathFactory getTemporaryZipPath];
    
    //creating zip-file at documents-directory
    bool success = [zipper CreateZipFile2:zippath];
    
    if(success == NO)
    {
        NSLog(@"Could not create zip-file!!");
    }
    
    BOOL goodfolder = [zipper addFileToZip:self.container.basePath newname:[[self.container.basePath lastPathComponent] stringByAppendingPathExtension:DIRECTORY_EXTENSION]];
    
    if(goodfolder == NO)
    {
        NSLog(@"Could not add folder to zip!!");
    }
    
    
    //adding files of container to zip
    for(NSString* path in self.container.fileUrls)
    {
        BOOL good = [zipper addFileToZip:path newname:[path lastPathComponent]];
        if(good == NO)
        {
            NSLog(@"Could not add file to zip!!");
        }
    }
    
    //closing zip
    [zipper CloseZipFile2];
    
    //getting zipped data
    NSData* zippeddata = [NSData dataWithContentsOfFile:zippath];
    
    //deleting zip-file
    if([[NSFileManager defaultManager] 	fileExistsAtPath:[FilePathFactory getTemporaryZipPath]])
    {
        
        NSError* removeerror;
        bool really = [[NSFileManager defaultManager] removeItemAtPath:zippath error:&removeerror];
        
        if(really == NO)
        {
            NSLog(@"Error deleting zip-file %@",[removeerror userInfo]);
        }
    }
    
    NSArray* contents_after = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[FilePathFactory applicationDocumentsDirectory] error:nil];
    
    NSLog(@"currrent contents after deletion of zip-file: %@",contents_after.description);
    
    NSData* encryptedContainer = [[Crypto getInstance] encryptBinaryFile:zippeddata withCertificate:self.currentCertificate];
    
    return encryptedContainer;
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
    self.currentCertificate = nil;
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSData* encryptedcontainer = [self zipAndEncryptContainer];
    switch (buttonIndex) {
        case 0: //change this to 1 if dropbox action is also visible
        {
            if([MFMailComposeViewController canSendMail])
            {
                [self sendContainerMail:encryptedcontainer];
            }
            else 
            {
                NSLog(@"cannot send mail");    
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - segue control methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_SOURCESEL])
    {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        SourceSelectionViewController* src = (SourceSelectionViewController*)[nav.viewControllers objectAtIndex:0];//(SourceSelectionViewController*) segue.destinationViewController;
        src.basePath = self.container.basePath;
        src.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_XPLORER])
    {
        UINavigationController* navi = (UINavigationController*) segue.destinationViewController;
        
        CertificateXplorerViewController* xplorer = [navi.viewControllers objectAtIndex:0];
        
        xplorer.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_PREVIEW])
    {
        PreviewViewController* prev = (PreviewViewController*) segue.destinationViewController;
        NSString* path = (NSString*) sender;
        prev.path = path;
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_SOURCESELVIEW])
    {
        SourceSelectionViewController *destination = (SourceSelectionViewController*)segue.destinationViewController;
        destination.basePath = self.container.basePath;
        destination.delegate = self;
        
        UIStoryboardPopoverSegue* popSegue = (UIStoryboardPopoverSegue*)segue;        
        self.popoverController = popSegue.popoverController;
    }
}

-(void) dealloc
{

}

@end
