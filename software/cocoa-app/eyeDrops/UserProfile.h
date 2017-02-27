/**
 * @file        UserProfile.h
 * @brief       Header file containing the user profile class.
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

/**
 * @brief       A project specific user profile.
 *
 * @class       UserProfile
 * @discussion  This class represents a user profile with name, id, creation date and calibration parameters.
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/17
 */
@interface UserProfile : NSObject {
    
    /**
     * The date of creation.
     */
    NSDate *date;
    
    /**
     * A DateFormatter to format the date.
     */
    NSDateFormatter *dateFormatter;
    
    float parameterarray[12];
}

/**
 * The user name.
 */
@property (nonatomic) NSString *name;

/**
 * The user id.
 */
@property (nonatomic) NSNumber *userId;

/**
 * The calibration parameters.
 */
@property (nonatomic) NSMutableArray *parameters;


/**
 * This methods initializes the user profile. Only needed to setup the DateFormatter.
 */
- (id)init;

/**
 * This method returns a new user profile with the given content.
 *
 * @param   name
 *      The user name.
 * @param   userId
 *      The user id.
 * @param   parameters
 *      The calibration parameters.
 *
 * @return  A new profile with the given content.
 */
+ (UserProfile *)userProfileWithName:(NSString *)name
                               andId:(NSNumber *)userId
                       andParameters:(NSMutableArray *)parameters;

/**
 * Getter for attribute name.
 *
 * @return Returns the profile's name.
 */
- (NSString*)getName;

/**
 * Getter for attribute parameters.
 *
 * @return A dictionary with key-values-pairs of the profile's content.
 */
- (NSDictionary*)getAttributes;

/**
 * Getter for a specific parameter.
 *
 * @param   index   The index of the requested parameter.
 * @return The requested parameter.
 */
- (NSNumber*)getParameter:(int)index;

@end
