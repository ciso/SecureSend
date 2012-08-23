//
//  SourceSelectionViewController.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIImagePickerController.h>
#import "SourceSelectionViewController.h"
#import "FilePathFactory.h"
#import "ContainerDetailViewController.h"
#import "UIImage+Resize.h"
#import "RootViewController.h"
#import "DropboxBrowserViewController.h"

@implementation SourceSelectionViewController

@synthesize delegate = _delegate;
@synthesize basePath = _basePath;
@synthesize button   = _button;
@synthesize popover  = _popover;
@synthesize caller   = _caller;


-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.section == 0 && indexPath.row == 0) 
    {
        cell.textLabel.text = NSLocalizedString(@"Image Gallery", @"Select image gallery as input source for contaier files in source selection view");
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"Camera", @"Get a new image from the camera");
    }
    else if (indexPath.section == 0 && indexPath.row == 2) {
        cell.textLabel.text = @"Dropbox (NOT WORKING!)";
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.allowsEditing = NO;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            
            [self presentModalViewController:imagePicker animated:YES];
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;

        // Place image picker on the screen
        [self presentModalViewController:imagePicker animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 2) {
        
        [self performSegueWithIdentifier:@"toDropboxBrowser" sender:nil];
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO; //todo: rethink this
}

#pragma mark - UIImagePickerControllerDelegate 

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *image = [pickedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:pickedImage.size interpolationQuality:kCGInterpolationHigh];
    
    NSString* path = [FilePathFactory getUniquePathInFolder:self.basePath forFileExtension:@"jpeg"];
    
    NSLog(@"Saving image to path %@",path);
    
    NSError* error;
    if([UIImageJPEGRepresentation(image, 0.5) writeToFile:path options:NSDataWritingFileProtectionComplete error:&error] == NO)
    {
        NSLog(@"Saving image to file failed with error %@",[error localizedDescription]);
    }
    
    picker.delegate = nil;
    [self dismissModalViewControllerAnimated:YES];
    
    [self.delegate addFilesToContainer:[NSArray arrayWithObject:path]];
    
    
//    UINavigationController *nav = self.navigationController;
//    UIViewController *view = nav.parentViewController;
//    [view dismissModalViewControllerAnimated:YES];
//    [picker.navigationController.parentViewController dismissModalViewControllerAnimated:NO];
//    
//    //[picker.parentViewController dismissModalViewControllerAnimated:YES];
    
    
    //[self.navigationController popViewControllerAnimated:NO];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) dealloc
{
    self.delegate = nil;
    self.button = nil;
    self.popover = nil;
    self.caller = nil;
}

- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toDropboxBrowser"]) {
        
        UITabBarController *tabBar = (UITabBarController*)((ContainerDetailViewController*)self.delegate).tabBarController;
        UINavigationController* navi = (UINavigationController*)[tabBar.viewControllers objectAtIndex:0];
        RootViewController* root = (RootViewController*)[navi.viewControllers objectAtIndex:0];
        DropboxBrowserViewController *view = (DropboxBrowserViewController*)segue.destinationViewController;
        view.root = root;
    }
}

@end
