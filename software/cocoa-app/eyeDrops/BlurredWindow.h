/**
 * @file        BlurredWindow.h
 * @brief       Header file containing the BlurredWindow class.
 *
 * @authors     Benjamin Thiemann, Benjamin Völker
 * @date        2016/12/08
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

#import <Cocoa/Cocoa.h>
#import "Settings.h"

/**
 * @brief       The Blurred Window controller..
 *
 * @class       BlurredWindow
 * @discussion  This class represents a blurred window..
 *
 * @authors     Benjamin Thiemann, Benjamin Völker
 * @date        2016/12/08
 */
@interface BlurredWindow : NSWindowController {
    
    /**
     * Float value representing the blur step.
     */
    float blurStep;
    
    /**
     * Float value that represents the blur speed.
     */
    float blurStepDelay;
    
    /**
     * Float value that represents the current blur radius.
     */
    float currentBlurRadius;
    
    /**
     * Float value that represents the maximum blur radius.
     */
    float maxBlurRadius;
    
    /**
     * Boolean value that indicates whether a blurring is ongoing.
     */
    bool isBlurring;
}

/**
 * A Core Graphics connection.
 */
typedef void * CGSConnection;

/**
 * Enable the window to be blurred by Core Graphics.
 */
extern OSStatus CGSSetWindowBackgroundBlurRadius(CGSConnection connection, NSInteger   windowNumber, int radius);

/**
 * Enable the connection to be threaded.
 */
extern CGSConnection CGSDefaultConnectionForThread();

/**
 * This method enables blurring for the given window with the given radius.
 *
 * @param   window
 *      The window to blur.
 * @param   radius
 *      The blur radius.
 */
- (void)enableBlurForWindow:(NSWindow *)window withRadius:(int) radius;

/**
 * This method starts a fading blurring of the window.
 */
- (void)startBlur;

/**
 * This method stops the blurring of the window.
 */
- (void)stopBlur;

@end
