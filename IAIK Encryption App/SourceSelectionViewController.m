//
//  SourceSelectionViewController.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SourceSelectionViewController.h"
#import <UIKit/UIImagePickerController.h>
#import "FilePathFactory.h"
#import "ContainerDetailViewController.h"

@implementation SourceSelectionViewController

@synthesize delegate, basePath;
@synthesize button = _button;
@synthesize popover = _popover;
@synthesize caller = _caller;


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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = NSLocalizedString(@"Image Gallery", @"Select image gallery as input source for contaier files in source selection view");
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
    
        //if ipad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            self.popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];        
                        
            [self.popover presentPopoverFromBarButtonItem:self.button 
                            permittedArrowDirections:UIPopoverArrowDirectionUp 
                                            animated:YES];

        }
        else { //iphone
            [self presentModalViewController:imagePicker animated:YES];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate 

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
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
@end
