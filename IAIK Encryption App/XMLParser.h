//
//  XMLParser.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 10.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMLAppDelegate;

@interface XMLParser : NSObject

@property (nonatomic, strong) NSMutableString *currentElementValue;
@property (nonatomic, strong) XMLAppDelegate *appDelegate;

- (XMLParser *) initXMLParser;
@end
