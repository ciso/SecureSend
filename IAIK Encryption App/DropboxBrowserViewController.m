//
//  DropboxBrowserViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 23.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "DropboxBrowserViewController.h"
#import "LoadingView.h"
#import "Error.h"
#import "SecureContainer.h"

@interface DropboxBrowserViewController ()

@property (nonatomic, strong) UIView *load;
@property (nonatomic, strong) NSArray *folders;
@property (nonatomic, assign) BOOL first;

@end

@implementation DropboxBrowserViewController

@synthesize load        = _load;
@synthesize folders     = _folders;
@synthesize dropboxPath = _dropboxPath;
@synthesize container   = _container;
@synthesize caller      = _caller;
@synthesize first       = _first;


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
    self.first = YES;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    //[[DBSession sharedSession] unlinkAll];
    
    if (self.first) {
        self.first = NO;
        
        if (![[DBSession sharedSession] isLinked])
        {
            self.root.dropboxBrowser = self;
            [[DBSession sharedSession] linkFromController:self.root];
            
        }
        else
        {
            [self loadFolder];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [self.load removeFromSuperview]; //temp
        self.tableView.userInteractionEnabled = YES;
        self.caller = nil;
        self.root.restClient.delegate = nil;
    }
    [super viewWillDisappear:animated];
}

- (void)loadFolder {
    self.root.dropboxBrowser = nil;
    
    self.load = [LoadingView showLoadingViewInView:self.view.window withMessage:@"Loading ..."];
    self.tableView.userInteractionEnabled = NO;
    self.root.restClient.delegate = self;
    
    if (self.dropboxPath == nil) {
        self.dropboxPath = @"/";
    }
    
    [self.root.restClient loadMetadata:self.dropboxPath];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.folders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImage *image = nil;
    DBMetadata *file = [self.folders objectAtIndex:indexPath.row];
    
    if (file.isDirectory) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        image = [UIImage imageNamed:@"folder"];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        image = [UIImage imageNamed:@"file"];
    }
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:101];
    imageView.image = image;
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:102];
    textLabel.text = file.filename;
        
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBMetadata *file = [self.folders objectAtIndex:indexPath.row];

    if (file.isDirectory) {
        UIStoryboard *storyboard = self.storyboard;
        DropboxBrowserViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DropboxViewController"];
        viewController.dropboxPath = file.path;
        viewController.root = self.root;
        viewController.container = self.container;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        NSString *localPath = [NSString stringWithFormat:@"%@/%@", self.container.basePath, file.filename];
        self.load = [LoadingView showLoadingViewInView:self.view.window withMessage:@"Loading File ..."];
        self.tableView.userInteractionEnabled = NO;
        [self.root.restClient loadFile:file.path intoPath:localPath];
    }
}


- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    [self.load removeFromSuperview];
    self.tableView.userInteractionEnabled = YES;

    if (metadata.isDirectory) {
        self.folders = [NSArray arrayWithArray:metadata.contents];
        [self.tableView reloadData];
    }
}

- (void)restClient:(DBRestClient *)client
    loadMetadataFailedWithError:(NSError *)error {
    
    if (error) {
        [Error log:error];
    }
    [self.load removeFromSuperview]; //temp
    self.tableView.userInteractionEnabled = YES;
    [self dismissModalViewControllerAnimated:YES]; //temp
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    NSLog(@"File loaded into path: %@", localPath);
    [self.load removeFromSuperview]; //temp
    self.tableView.userInteractionEnabled = YES;
    [self.container reloadFiles];
    [((UITableViewController*)self.caller).tableView reloadData];
    [self dismissModalViewControllerAnimated:YES]; //temp
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    NSLog(@"There was an error loading the file - %@", error);
    [self.load removeFromSuperview]; //temp
    self.tableView.userInteractionEnabled = YES;
    [self dismissModalViewControllerAnimated:YES]; //temp
}


@end
