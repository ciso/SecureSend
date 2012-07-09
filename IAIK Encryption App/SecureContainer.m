//
//  SecureContainer.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SecureContainer.h"

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
    NSError* deletionerror = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.basePath error:&deletionerror];
    
    if(deletionerror)
    {
        NSLog(@"Problem deleting container files!: %@",deletionerror.description);
    }
    else
    {
        NSLog(@"Directory deleted: %@",self.basePath);
    }
}

- (NSString*)description
{
    return self.name;
}

@end
