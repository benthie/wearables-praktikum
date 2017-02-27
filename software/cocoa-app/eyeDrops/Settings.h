/**
 * @file        Settings.h
 * @brief       Header file containing the shared settings class.
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
 * @brief       The shared settings container.
 *
 * @class       Settings
 * @discussion  This class manages the shared settings of the application.
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/17
 */
@interface Settings : NSObject <NSCoding>

/**
 * Boolean value that indicates whether an autoscan is desired.
 */
@property BOOL autoScan;

/**
 * Boolean value that indicates whether an autoconnect to the last known device is desired.
 */
@property BOOL autoConnect;

/**
 * Integer value that represents the maximum blur radius.
 */
@property NSUInteger maxBlurRadius;

/**
 * Float value that represents the blur step.
 */
@property float blurStep;

/**
 * Float value that represents the blur speed.
 */
@property float blurSpeed;

/**
 * Float value that represents the battery level.
 */
@property float batteryLevel;

/**
 * Integer value that represents the allowed interval without blinking.
 */
@property NSUInteger blinkTimerValue;

/**
 * Boolean value that indicates whether the XML file is automatically selected.
 */
@property BOOL autoSelectXMLFile;

/**
 * The path to the XML file.
 */
@property NSString *xmlFile;

/**
 * The last known device.
 */
@property NSString *lastKnownDevice;

/**
 * This method returns the shared instance of this singleton class.
 */
+ (id)sharedInstance;

@end
