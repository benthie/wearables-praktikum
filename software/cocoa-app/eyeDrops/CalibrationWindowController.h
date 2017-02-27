/**
 * @file        CalibrationWindowController.h
 * @brief       Header file containing the calibration window controller class.
 *
 * @author      Benjamin Thiemann
 * @date        2017/02/07
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

#import "BlinkPredictionViewController.h"
#import "SensorDataViewController.h"
#import "AnimationViewController.h"
#import "UserProfileManager.h"
#import "AnimationView.h"
#import "UserProfile.h"

/**
 * This enumeration contains the different states the calibration window can be in.
 *
 * @enum    CON_STATE
 */
typedef enum CALIBRATION_STATE : NSInteger {
    CALIBRATION_STATE_INIT,                     /*!< Boot up. Device freshly connected. */
    CALIBRATION_STATE_PARAMETERS_SET,           /*!< Normal mode. Waiting for user to blink. */
} CALIBRATION_STATE;


/**
 * @brief       The calibration window (controller).
 *
 * @class       CalibrationWindowController
 * @discussion  This class represents the calibration window where all the calibration takes place.
 *      From here a test or normal calibration is started, the corresponding data from the RFDuino
 *      will be plotted and afterwards calibration parameters can be set or changed. Finally a
 *      user profile can be created with the just collected calibration data.
 *
 * @author      Benjamin Thiemann
 * @date        2017/02/07
 */
@interface CalibrationWindowController : NSWindowController

/**
 * The SemsorDataViewController.
 */
@property IBOutlet SensorDataViewController *sensorDataViewController;

/**
 * The BlinkPredictionViewController.
 */
@property IBOutlet BlinkPredictionViewController *blinkPredictionViewController;

/**
 * The left button to cancel the calibration and close the sheet.
 */
@property IBOutlet NSButton *cancelButton;

/**
 * The middle button to test the calibration.
 */
@property IBOutlet NSButton *testCalibrationButton;

/**
 * The right button to start the calibration.
 */
@property IBOutlet NSButton *startCalibrationButton;

/**
 * The save profile button.
 */
@property IBOutlet NSButton *saveProfileButton;

/**
 * Bindings reference for negative threshold. (NSNumber in order to be able to present placeholder
 * string if number is not set yet, i.e. nil).
 */
@property (readwrite, nonatomic, setter=setNegativeThreshold:) NSNumber *negativeThreshold;

/**
 * Bindings reference for positive threshold. (NSNumber in order to be able to present placeholder
 * string if number is not set yet, i.e. nil).
 */
@property (readwrite, nonatomic, setter=setPositiveThreshold:) NSNumber *positiveThreshold;

/**
 * Bindings reference for hysteresis.
 */
@property float hysteresis;

/**
 * Bindings reference for min value.
 */
@property float minValue;

/**
 * Bindings reference for max value.
 */
@property float maxValue;

/**
 * Bindings reference for min fall time.
 */
@property float minFall;

/**
 * Bindings reference for max fall time.
 */
@property float maxFall;

/**
 * Bindings reference for min rise time.
 */
@property float minRise;

/**
 * Bindings reference for max rise time.
 */
@property float maxRise;

/**
 * Bindings reference for min total time.
 */
@property float riseTimeRangeMin;

/**
 * Bindings reference for max total time.
 */
@property float riseTimeRangeMax;

/**
 * Bindings reference for eye closed time.
 */
@property float eyeClosedTime;

/**
 * Boolean value that indicates whether the positive threshold has been set.
 */
@property BOOL positiveThresholdSet;

/**
 * Boolean value that indicates whether the negative threshold has been set.
 */
@property BOOL negativeThresholdSet;

/**
 * Boolean value that indicates whether the newly created profile is being used immediately.
 */
@property BOOL immediateUse;

/**
 * The state the window is in.
 */
@property NSInteger state;

/**
 * The name the new profile is going to have.
 */
@property NSString *profileName;

/**
 * The textfield displaying the positive threshold.
 */
@property IBOutlet NSTextField *positiveThresholdTextField;

/**
 * The textfield displaying the negative threshold.
 */
@property IBOutlet NSTextField *negativeThresholdTextField;

/**
 * The checkbox to selecct immediateUse.
 */
@property (weak) IBOutlet NSView *immediateUseCheckbox;

/**
 * Initialization method.
 */
- (id)init;

/**
 * This method sets the negative threshold.
 *
 * @param   negativeThreshold
 *      The value to set.
 */
- (void)setNegativeThreshold:(NSNumber*)negativeThreshold;

/**
 * This method sets the positive threshold.
 *
 * @param   positiveThreshold
 *      The value to set.
 */
- (void)setPositiveThreshold:(NSNumber*)positiveThreshold;

@end
