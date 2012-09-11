//
//  FilePathFactory.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 23.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilePathFactory.h"
#import "SecureContainer.h"

#define CONTAINER_PREFIX @"CO"

@implementation FilePathFactory

+ (NSString *) applicationDocumentsDirectory 
{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString*)getUniquePathInFolder:(NSString*)folder forFileExtension:(NSString *)fileExtension andFileName:(NSString*) filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray* existingFiles = [fileManager contentsOfDirectoryAtPath:folder error:nil];
    NSString* uniquePath;
    NSString* uniquename;
    
    NSString* file = filename;
    
    if(fileExtension != nil)
        file = [file stringByAppendingPathExtension:fileExtension];
    
    if([existingFiles containsObject:file] == NO)
    {
        return [folder stringByAppendingPathComponent:file];
    }
    
    do {
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        
        NSString* prefix = [(__bridge NSString*) newUniqueIdString substringToIndex:3];
        
        uniquename =  [filename stringByAppendingString:prefix];
        
        uniquePath = [folder stringByAppendingPathComponent:uniquename];
        
        if(fileExtension != nil)
            uniquePath = [uniquePath stringByAppendingPathExtension:fileExtension];
        
        CFRelease(newUniqueId);
        CFRelease(newUniqueIdString);
    } while ([existingFiles containsObject:uniquename]);
    
    return uniquePath;
}


+ (NSString *)getUniquePathInFolder:(NSString *)folder forFileExtension:(NSString *)fileExtension {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *existingFiles = [fileManager contentsOfDirectoryAtPath:folder error:nil];
    NSString *uniquePath;
    NSString* uniqueName;
    do {
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        
        uniqueName =  [[CONTAINER_PREFIX stringByAppendingString:(__bridge NSString*) newUniqueIdString] substringToIndex:8];
        
        if(fileExtension != nil)
            uniqueName = [uniqueName stringByAppendingPathExtension:fileExtension];
        
        uniquePath = [folder stringByAppendingPathComponent:uniqueName];
        
        CFRelease(newUniqueId);
        CFRelease(newUniqueIdString);
    } while ([existingFiles containsObject:uniqueName]);
    
    return uniquePath;
}

+ (NSString *)getUniqueContainer:(NSString*)folder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *existingFiles = [fileManager contentsOfDirectoryAtPath:folder error:nil];
    NSString *uniquePath;
    NSString *uniqueName;
    NSInteger count = 1;
    NSString *containerName = @"New Container";
    
    do {
        uniqueName = [NSString stringWithFormat:@"%@ #%d", containerName, count++];
        uniquePath = [folder stringByAppendingPathComponent:uniqueName];
    } while ([existingFiles containsObject:uniqueName]);
    
    return uniquePath;
}


+ (NSString*) getTemporaryZipPath
{
    return [[FilePathFactory applicationDocumentsDirectory] stringByAppendingPathComponent:@"temp_zip_container"];
}

+ (NSMutableArray*) getContainersOfFileStructure
{
    //creating containers-array
    NSMutableArray* newcontainers = [[NSMutableArray alloc] init];
    
    //parsing file-structure in /Documents to reconstruct containers
    NSString* docpath = [FilePathFactory applicationDocumentsDirectory];
    NSArray* containersinfilesystem = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docpath error:nil];
    
    NSArray* contentsofinbox = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[docpath stringByAppendingPathComponent:NAME_INBOX_DIRECTORY] error:nil];
    
    NSLog(@"contents of inbox: %@",contentsofinbox.description);
    
    
    if(containersinfilesystem.count != 0)
        NSLog(@"found containers: %@",containersinfilesystem.description);
    
    for(NSString* container in containersinfilesystem)
    {
        NSString* containerpath = [docpath stringByAppendingPathComponent:container];
        
        BOOL isdir;
        
        [[NSFileManager defaultManager] fileExistsAtPath:containerpath isDirectory:&isdir];
        
        if(isdir == NO || [container isEqualToString:NAME_INBOX_DIRECTORY] == YES)
            continue;
        
        SecureContainer* newcontainer = [self parseContainerAtPath:containerpath];
        
        [newcontainers addObject:newcontainer];
    }
    
    return newcontainers;
}

+(SecureContainer*) parseContainerAtPath: (NSString*) containerpath
{
    //Creating container for directory and adding it to RootViewController (with fileURLs)
    SecureContainer* newcontainer = [[SecureContainer alloc] init];
    
    newcontainer.basePath = containerpath;
    
    newcontainer.name = [containerpath lastPathComponent];
    
    //getting creation date of container
    
    NSDictionary* attritube = [[NSFileManager defaultManager] attributesOfItemAtPath:newcontainer.basePath error:nil];
    newcontainer.creationDate = (NSDate*) [attritube objectForKey:NSFileCreationDate];
    
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:newcontainer.basePath error:nil];
    
    for(NSString* file in files)
    {
        NSLog(@"Found file in container %@:%@",newcontainer.name,file);
        [newcontainer.fileUrls addObject:[newcontainer.basePath stringByAppendingPathComponent:file]];
    }
    
    return newcontainer;
}

@end
