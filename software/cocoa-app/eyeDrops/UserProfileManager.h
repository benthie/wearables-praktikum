/**
 * @file        UserProfileManager.h
 * @brief       Header file containing the user profile manager class.
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

#import <Foundation/Foundation.h>
#import "UserProfile.h"
#import "AppDelegate.h"

/**
 * @brief       The user profile manager to read/write from XML file and manage the profiles.
 *
 * @class       UserProfileManager
 * @discussion  This class manages the user profiles. User profiles will be read from a XML-file
 *  and then be managed by this class. Profiles can be added, deleted or manipulated. When the
 *  application will terminate, the profiles will be written to the XML file so save them for the
 *  the next usage of the app.
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/17
 */
@interface UserProfileManager : NSObject {
    
    /**
     * Array containing the profiles.
     */
    NSMutableArray *profiles;

    /**
     * The error object used while processing the XML file.
     */
    NSError *handleError;
    
    /**
     * The URL to the XML file.
     */
    NSURL *xmlURL;
    
    /**
     * The XML file.
     */
    NSXMLDocument *xmlDoc;
    
    /**
     * Boolean value that indicates whether the XML file is opened.
     */
    BOOL xmlOpened;
}

/**
 * This method (initialized and) returns the shared instance of this singleton class.
 */
+ (instancetype)sharedInstance:(NSString *)fileName;

/*
 * Thie method returns the shared instance of this singleton class.
 */
+ (instancetype)sharedInstance;

/**
 * This method changes the path and filename.
 */
- (void)changeFile:(NSString *)fileName;

/**
 * Getter method for the profiles.
 *
 * @return  An array with the profiles.
 */
- (NSMutableArray *)getProfiles;

/**
 * Opens the set XML file.
 */
- (void)openXMLDocument;

/**
 * This method saves the profiles to the afore set file.
 */
- (BOOL)saveProfiles;

/**
 * This method adds the given profile to the maanger's list.
 */
- (void)addProfile:(UserProfile *)profile;

/**
 * This method deletes the given profile from the manager's list.
 */
- (void)deleteProfile:(UserProfile *)profile;

@end
