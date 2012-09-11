//
//  SecureContainer.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SecureContainer.h"
#import "Error.h"

@implementation SecureContainer

@synthesize name = _name, fileUrls = _fileUrls, basePath = _basePath, creationDate = _creationDate;

- (id) init
{
    self = [super init];
    
    if(self)
    {
        NSMutableArray* tempfileurls = [[NSMutableArray alloc] init];
        
        self.fileUrls = tempfileurls;
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"Secure container gets destructed!!");
    
    //Deleting saved files in Documents directory that belong to that container!
    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.basePath error:&error];
    
    if (error) {
        [Error log:error];
    }
    else
    {
        NSLog(@"Directory deleted: %@",self.basePath);
    }
}

- (void)reloadFiles {
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.basePath error:nil];
    self.fileUrls = [[NSMutableArray alloc] init];
    
    for(NSString* file in files)
    {
        NSLog(@"Found file in container %@:%@", self.name, file);
        [self.fileUrls addObject:[self.basePath stringByAppendingPathComponent:file]];
    }

}

- (NSString*)description
{
    return self.name;
}

@end
