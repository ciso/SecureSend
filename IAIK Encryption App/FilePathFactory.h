//
//  FilePathFactory.h
//  bac_01
//
//  Created by Christoph Hechenblaikner on 23.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NAME_INBOX_DIRECTORY @"Inbox"
#define NAME_TEMP_INCOMING_ZIP @"intempzip"
#define NAME_INCOMING_DIRECTORY @"incoming"
#define DIRECTORY_EXTENSION @"iaikencryptiondirectory"

#define EXTENSION_PDF @"pdf"
#define EXTENSION_JPG @"jpg"
#define EXTENSION_JPEG @"jpeg"
#define EXTENSION_PNG @"png"
#define EXTENSION_GIF @"gif"



@class SecureContainer;

@interface FilePathFactory : NSObject


+ (NSString *) applicationDocumentsDirectory;

+ (NSString *)getUniquePathInFolder:(NSString *)folder forFileExtension:(NSString *)fileExtension;

+ (NSString*)getUniquePathInFolder:(NSString*)folder forFileExtension:(NSString *)fileExtension andFileName:(NSString*) filename;

+ (NSString*) getTemporaryZipPath;

+ (NSMutableArray*) getContainersOfFileStructure;

+(SecureContainer*) parseContainerAtPath: (NSString*) containerpath;

@end
