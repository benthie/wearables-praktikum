/**
 * @file        UserProfileManager.m
 * @brief       Implementation file containing the user profile manager class.
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/17
 * @copyright   MIT License, Copyright (c) 2017 University of Freiburg im Breisgau, Germany,<br>
 *      Marlene Fiedler <fiedlerm@informatik.uni-freiburg.de>,<br>
 *      Lorenz Miething <miethinl@informatik.uni-freiburg.de>,<br>
 *      Benjamin Thiemann <benjamin.thiemann@neptun.uni-freiburg.de><br>
 *      <br>
 *      Permission is hereby granted, free of charge, to any person obtaining a copy
 *      of this software and associated documentation files (the "Software"), to deal
 *      in the Software without restriction, including without limitation the rights
 *      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *      copies of the Software, and to permit persons to whom the Software is
 *      furnished to do so, subject to the following conditions:<br>
 *      <br>
 *      The above copyright notice and this permission notice shall be included in all
 *      copies or substantial portions of the Software.<br>
 *      <br>
 *      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *      SOFTWARE.
 */

#import "UserProfileManager.h"


@implementation UserProfileManager

/*
 * This method initialized and returns the shared instance of this singleton class.
 */
+ (instancetype)sharedInstance:(NSString *)fileName {
    
    // The static shared instance.
    static UserProfileManager *sharedInstance = nil;
    
    // Singleton token.
    static dispatch_once_t onceToken;
    
    // Check if token already existing.
    dispatch_once(&onceToken, ^{
        
        // Create instance once.
        sharedInstance = [[UserProfileManager alloc] initWithFile:fileName];
        
    });
    
    // Return the single instance.
    return sharedInstance;
}

/*
 * Thie method returns the shared instance of this singleton class.
 */
+ (instancetype)sharedInstance {
    
    return [self sharedInstance:nil];
}

/*
 * Initialization method.
 */
- (id)initWithFile:(NSString *)fileName {
    
    // Get file existance status.
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
    
    self = [super init];
    
    // Create new profiles array each time a new xml file is loaded.
    profiles = [[NSMutableArray alloc] init];
    
    // Check if file is nil
    if (!fileExists) {
        
        // No file opened.
        xmlOpened = false;
        
        // Return the empty profile manager.
        return self;
        
    } else {
        // Create url to file.
        xmlURL = [NSURL fileURLWithPath:fileName];
    }
    
    if (!xmlURL) {
        NSLog(@"Can't create an URL from file %@.", fileName);
        xmlOpened = false;
    } else {
        [self openXMLDocument];
        [self readProfilesFromXMLFile];
    }
    
    return self;
}

/*
 * Opens the XML document with the url stored in xmlURL.
 * Saves the opened document to xmlDoc.
 */
- (void)openXMLDocument {
    
    NSError *err=nil;
    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:xmlURL
                                                  options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                    error:&err];
    if (xmlDoc == nil) {
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:xmlURL
                                                      options:NSXMLDocumentTidyXML
                                                        error:&err];
    }
    if (xmlDoc == nil)  {
        if (err) {
            NSLog(@"Error occurred: %@", err);
        }
        xmlOpened = false;
        return;
    }
    if (err) {
        NSLog(@"Error occurred: %@", err);
        xmlOpened = false;
    }
}

/*
 * Reads the profiles from the XML document stored in xmlDoc.
 */
- (void)readProfilesFromXMLFile {
    
    NSError *error;
    NSXMLElement *root = [xmlDoc rootElement];  //[NSXMLNode elementWithName:@"profiles"];
    NSArray *children = [root nodesForXPath:@"user" error:&error];
    //item = [children count] ? [children objectAtIndex:0] : NULL;
    // NSLog(@"The users are: %@", children);
    
    NSUInteger i, count = [children count];
    for (i=0; i<count; i++) {
        NSXMLElement *child = [children objectAtIndex:i];
        
        NSString *name =     [[child attributeForName:@"name"] stringValue];
        NSString *userId =   [[child attributeForName:@"id"] stringValue];
        NSString *p1 =       [[child attributeForName:@"p1"] stringValue];
        NSString *p2 =       [[child attributeForName:@"p2"] stringValue];
        NSString *p3 =       [[child attributeForName:@"p3"] stringValue];
        NSString *p4 =       [[child attributeForName:@"p4"] stringValue];
        NSString *p5 =       [[child attributeForName:@"p5"] stringValue];
        NSString *p6 =       [[child attributeForName:@"p6"] stringValue];
        NSString *p7 =       [[child attributeForName:@"p7"] stringValue];
        NSString *p8 =       [[child attributeForName:@"p8"] stringValue];
        NSString *p9 =       [[child attributeForName:@"p9"] stringValue];
        NSString *p10 =      [[child attributeForName:@"p10"] stringValue];
        NSString *p11 =      [[child attributeForName:@"p11"] stringValue];
        NSString *p12 =      [[child attributeForName:@"p12"] stringValue];
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        
        NSMutableArray *parameters = [[NSMutableArray alloc] initWithCapacity:12];
        [parameters addObject:p1];
        [parameters addObject:p2];
        [parameters addObject:p3];
        [parameters addObject:p4];
        [parameters addObject:p5];
        [parameters addObject:p6];
        [parameters addObject:p7];
        [parameters addObject:p8];
        [parameters addObject:p9];
        [parameters addObject:p10];
        [parameters addObject:p11];
        [parameters addObject:p12];
        
        UserProfile *up = [[UserProfile alloc] init];
        [up setName:name];
        [up setUserId:[f numberFromString:userId]];
        [up setParameters:parameters];
        
        [profiles addObject:up];
    }
}

/*
 * Change the document path.
 */
- (void)changeFile:(id)sender {
    
    NSString *fileName = [(NSNotification *)sender object];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
    
    if (!fileExists) {
        return;
    }
    
    xmlURL = [NSURL fileURLWithPath:fileName];
    
    if (!xmlURL) {
        NSLog(@"Can't create an URL from file %@.", fileName);
        xmlOpened = false;
    } else {
        NSLog(@"opening xml file");
        [self openXMLDocument];
        [self readProfilesFromXMLFile];
    }
}

/*
 * Returns the list of profiles.
 */
- (NSMutableArray *)getProfiles {
    return profiles;
}

/*
 * Saves the current profiles to the XML document.
 */
- (BOOL)saveProfiles {
    
    // Create root element.
    NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:@"profiles"];

    // Create xmlDoc.
    xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    [xmlDoc setVersion:@"1.0"];
    [xmlDoc setCharacterEncoding:@"UTF-8"];
    
    // Add user profiles.
    for (UserProfile *profile in profiles) {
        NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"user"];
        [element setAttributesWithDictionary:[profile getAttributes]];
        [root addChild:element];
    }
    
    // Check if xmlFile opened.
    if (!xmlOpened) {
        
        // Create fileName for profile if no profile exists yet.
        NSString *fileName = [NSHomeDirectory() stringByAppendingPathComponent:@"/eyeDrops/profiles.xml"];
        
        xmlURL = [NSURL fileURLWithPath:fileName];
    }
    
    // Convert into bytes.
    NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[xmlURL path]]) {
        NSLog(@"File was created: %@", [xmlURL path]);
        [[NSFileManager defaultManager] createFileAtPath:[xmlURL path] contents:nil attributes:nil];
    }

    if (![xmlData writeToFile:[xmlURL path] atomically:YES]) {
        NSLog(@"Could not write document out...");
        return NO;
    }
    
    return YES;
}

/*
 * Adds a profile.
 */
- (void)addProfile:(UserProfile *)profile {

    [profiles addObject:profile];
    
    NSLog(@"Profilemanager has new profile to add: %@", [profiles lastObject]);
    
    NSLog(@"Update table view and menu");
    
    // Update table view in preferences.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EDNotificationProfileCreated" object:nil];
    
    // Update menu.
    [[[NSApplication sharedApplication] delegate] performSelector:@selector(updateMenuWithProfiles) withObject:nil];
}

/*
 * Deletes the given profile.
 */
- (void)deleteProfile:(UserProfile *)profile {
    
    [profiles removeObject:profile];
    
    NSLog(@"Profile deleted");

    [[NSNotificationCenter defaultCenter] postNotificationName:@"EDNotificationProfileDeleted" object:nil];    
}

@end
