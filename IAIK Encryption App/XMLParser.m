//
//  XMLParser.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 10.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "XMLParser.h"
#import "CertificateRequest.h"

@implementation XMLParser

@synthesize currentElementValue = _currentElementValue;
@synthesize appDelegate = _appDelegate;
@synthesize certRequest = _certRequest;

- (XMLParser *) initXMLParser 
{
    self.appDelegate = (XMLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
    
    if([elementName isEqualToString:@"CertificateRequest"]) 
    {
        self.certRequest = [[CertificateRequest alloc] init];
        
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{    
    if(self.currentElementValue == nil)
        self.currentElementValue = [[NSMutableString alloc] initWithString:string];
    else
        [self.currentElementValue appendString:string];
        
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
    
    
    if([elementName isEqualToString:@"CertificateRequest"]) 
    {
        return;
    }
    else 
    {
        [self.certRequest setValue:self.currentElementValue forKey:elementName];
    }
    //NSLog(@"email: %@", self.certRequest.emailAddress);

    
    self.currentElementValue = nil;
}

@end
