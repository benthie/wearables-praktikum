/**
 * @file        UserProfile.m
 * @brief       Implementation file containing the user profile class.
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

#import "UserProfile.h"

@implementation UserProfile

@synthesize name;
@synthesize userId;
@synthesize parameters;

/*
 * Initialization method.
 */
- (id)init {
    // super init
    self = [super init];
    // set date format
    dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    // get current date
    date = [NSDate date];
    parameters = [NSMutableArray alloc];
    // return the profile
    return self;
}

/*
 * Creates a new profile with the given content.
 */
+ (id)userProfileWithName:(NSString *)aName
                               andId:(NSNumber *)aUserId
                       andParameters:(NSMutableArray *)aParameters {
    
    UserProfile *profile = [[UserProfile alloc] init];
    [profile setName:aName];
    [profile setUserId:aUserId];
    [profile setParameters:aParameters];
    
    return profile;
}

/*
 * Sets the user id.
 */
- (void)setUserId:(NSNumber *)aUserId {
    userId = aUserId;
    date = [NSDate date];
}

/*
 * Sets the user name.
 */
- (void)setName:(NSString *)aName {
    name = aName;
    date = [NSDate date];
}

/*
 * Sets the parameters.
 */
- (void)setParameters:(NSMutableArray *)aParameters {
    parameters = aParameters;
    date = [NSDate date];
}

/*
 * Returns the parameter at the given index.
 */
- (NSNumber *)getParameter:(int)index {
    return [parameters objectAtIndex:index];
}

/*
 * Returns the user name.
 */
- (NSString *)getName {
    return name;
}

/*
 * Sets the parameter at the given index.
 */
- (void)setParameterAtIndex:(int)index withParameter:(float)parameter {
    [parameters replaceObjectAtIndex:index
                          withObject:[NSNumber numberWithFloat:parameter]];
    
    parameterarray[index] = parameter;
    date = [NSDate date];
}

/*
 * Returns the profile attributes.
 */
- (NSDictionary *)getAttributes {
    id keys[] = {@"id", @"name", @"date", @"p1", @"p2", @"p3", @"p4", @"p5", @"p6", @"p7", @"p8", @"p9", @"p10", @"p11", @"p12"};
    id values[] = {
        userId.stringValue,
        name,
        [dateFormatter stringFromDate:date],
        [parameters objectAtIndex:0],
        [parameters objectAtIndex:1],
        [parameters objectAtIndex:2],
        [parameters objectAtIndex:3],
        [parameters objectAtIndex:4],
        [parameters objectAtIndex:5],
        [parameters objectAtIndex:6],
        [parameters objectAtIndex:7],
        [parameters objectAtIndex:8],
        [parameters objectAtIndex:9],
        [parameters objectAtIndex:10],
        [parameters objectAtIndex:11]
    };
    NSUInteger count = sizeof(values) / sizeof(id);
    NSDictionary *result = [NSDictionary dictionaryWithObjects:values
                                                       forKeys:keys
                                                         count:count];

    return result;
}

@end
