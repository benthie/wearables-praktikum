/**
 * @file        AnimationView.h
 * @brief       Header file containing the animation view class.
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/26
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
#import "BLEDeviceManager.h"

/**
 * @brief       This class takes care of the calibration animation.
 *
 * @class       AnimationView
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/26
 */
@interface AnimationView : NSView {
    
    /**
     * Boolean value that indicates whether the animation is running.
     */
    BOOL isRunning;
    
    /**
     * Boolean value that indicates whether the countdown, which is animated
     * before the actual animation, is running.
     */
    BOOL isCountingDown;
    
    /**
     *
     */
    BOOL isTestRun;
    
    /**
     * Integer value that indicates the position of the active and thus highlighted
     * circle.
     */
    int pos;
    
    /**
     * Integer value that indicates the length of the calibration animation in terms
     * of circle count.
     */
    int length;
    
    // NSDate *startDate;
    // NSDate *stopDate;
}

/**
 * Initialization method.
 */
- (id)initWithFrame:(NSRect)frame;

/**
 * This method performs the next step in the animation.
 */
- (void)nextStep:(id)sender;

/**
 * This methods starts a test animation.
 */
- (void)startTestAnimation;

/**
 * This method starts the calibration animation.
 */
- (void)startAnimation;

/**
 * Stop the animation.
 */
- (void)stopAnimation;

@end
