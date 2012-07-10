//
//  XMLParser.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 10.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

- (XMLParser *) initXMLParser 
{
        
    self.appDelegate = (XMLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
    
    if([elementName isEqualToString:@"Books"]) {
        //Initialize the array.
        self.appDelegate.books = [[NSMutableArray alloc] init];
    }
    else if([elementName isEqualToString:@"Book"]) {
        
        //Initialize the book.
        aBook = [[Book alloc] init];
        
        //Extract the attribute here.
        aBook.bookID = [[attributeDict objectForKey:@"id"] integerValue];
        
        NSLog(@"Reading id value :%i", aBook.bookID);
    }
    
    NSLog(@"Processing Element: %@", elementName);
}

@end
