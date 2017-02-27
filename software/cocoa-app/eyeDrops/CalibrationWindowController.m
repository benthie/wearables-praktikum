/**
 * @file        CalibrationWindowController.m
 * @brief       Implementation file containing the calibration window controller class.
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

#import "CalibrationWindowController.h"

@interface CalibrationWindowController ()

/**
 * The AnimationViewController.
 */
@property IBOutlet AnimationViewController *animationViewController;

@end

@implementation CalibrationWindowController

@synthesize animationViewController;
@synthesize sensorDataViewController;
@synthesize blinkPredictionViewController;

@synthesize hysteresis;
@synthesize minValue;
@synthesize maxValue;
@synthesize minFall;
@synthesize maxFall;
@synthesize minRise;
@synthesize maxRise;
@synthesize riseTimeRangeMin;
@synthesize riseTimeRangeMax;
@synthesize eyeClosedTime;

@synthesize negativeThreshold;
@synthesize negativeThresholdSet;
@synthesize positiveThreshold;
@synthesize positiveThresholdSet;
@synthesize negativeThresholdTextField;
@synthesize positiveThresholdTextField;

@synthesize state;

@synthesize profileName;
@synthesize immediateUseCheckbox;
@synthesize immediateUse;

#define SCALING_FACTOR   10.0

/*
 * Initialization method.
 */
- (id)init {
    
    self = [super initWithWindowNibName:@"CalibrationWindowController"];
    //self = [super init];
    
    if (self) {
        
        state = CALIBRATION_STATE_INIT;
        
        immediateUse = true;
        
        profileName = nil;
        
        negativeThresholdSet = false;
        positiveThresholdSet = false;
        
        negativeThreshold   = nil;
        positiveThreshold   = nil;
        
        hysteresis          = 0.002;
        minValue            = -0.2;
        maxValue            = 0.2;
        minFall             = 4;
        maxFall             = 30;
        minRise             = 6;
        maxRise             = 35;
        riseTimeRangeMin    = 30;
        riseTimeRangeMax    = 105;
        eyeClosedTime       = 200;
        
        negativeThresholdTextField.placeholderString = @"Click on the graph";
        positiveThresholdTextField.placeholderString = @"Click on the graph";
        
        negativeThresholdTextField.stringValue = @"test";
        
        [_saveProfileButton setEnabled:false];
    }
    
    // Add observers for notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationFinished:) name:@"EDNotificationAnimationFinished" object:nil];
    
    return self;
}

/*
 * Sets the negative threshold.
 */
- (void)setNegativeThreshold:(NSNumber *)negThreshold {
    
    // NSLog(@"setNegativeThreshold: %f", [negThreshold floatValue]);
    
    if (!negativeThresholdSet) {
        [negativeThresholdTextField setFont:[NSFont systemFontOfSize:13]];
    }
    
    negativeThreshold      = negThreshold;
    negativeThresholdSet   = true;
    
    // Both thresholds have been set.
    if (positiveThresholdSet) {
        [self allParametersSet];
        [_saveProfileButton setEnabled:true];
    }
    
}

/*
 * Sets the positive threshold.
 */
- (void)setPositiveThreshold:(NSNumber *)posThreshold {
    
    // NSLog(@"setNegativeThreshold: %f", [posThreshold floatValue]);
    
    if (!positiveThresholdSet) {
        [positiveThresholdTextField setFont:[NSFont systemFontOfSize:13]];
    }
    
    positiveThreshold      = posThreshold;
    positiveThresholdSet   = true;
    
    // Both thresholds have been set.
    if (negativeThresholdSet) {
        [self allParametersSet];
        [_saveProfileButton setEnabled:true];
    }
}

/*
 * Invoked when both thresholds are set.
 */
- (void)allParametersSet {
    
    // Change the state.
    state = CALIBRATION_STATE_PARAMETERS_SET;
    
    // Enable the button.
    [_startCalibrationButton setEnabled:true];
    
    // Enable save profile button.
    
}

/*
 * Window did load.
 */
- (void)windowDidLoad {
    [super windowDidLoad];
    
    [sensorDataViewController       setParameters:9 titleSize:20];
    [blinkPredictionViewController  setParameters:9 titleSize:20];
    // animationView = [[AnimationView alloc] init];
    
    [_saveProfileButton setEnabled:false];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark
#pragma mark - IBAction methods for the buttons

/**
 * Action listener for cancel button pressed.
 */
- (IBAction)cancelPressed:(id)sender {
    //[self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
    
    [animationViewController stopAnimation];
    
    [[self window] orderOut:self];
}

/**
 * Action listener for startCalibration button pressed.
 */
- (IBAction)startCalibrationPressed:(id)sender {
    
    // If still in init state, start the animation.
    if (state == CALIBRATION_STATE_INIT) {
        
        // Send a notification in order to get the calibration started on the RFDuino.
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"EDNotificationStartCalibration" object:nil];
        
        // Start the animation.
        [animationViewController startAnimation];
    }
    
    // If calibration was done AND all parameters are set, try them.
    if (state == CALIBRATION_STATE_PARAMETERS_SET) {
        
        // Check if profile name is still nil
        // --> calibration has been done only once before
        if (!profileName) {
            
            // Ask for profile name.
            profileName = [self askForProfileName];
        }
        
        // Check if input of profile name was valid
        if (profileName) {
            
            NSLog(@"input valid ... set profile and start another cal");
            
            // Create profile with the set parameters
            UserProfile *newProfile = [self createProfile:profileName];
            
            // Reset graphs
            [sensorDataViewController resetGraph];
            [blinkPredictionViewController resetGraph];
            
            // Set the profile (automatically starts new calibration).
            [[BLEDeviceManager sharedInstance] setProfile:newProfile];
            
            // Start the animation.
            [animationViewController startAnimation];
            
        } else {
            NSLog(@"no valid profile name");
        }
    }
}

/**
 * Action listener for testCalibration button pressed.
 */
- (IBAction)testCalibrationPressed:(id)sender {
    
    [animationViewController startTestAnimation];
}

/*
 * Saves the profiles.
 */
- (IBAction)saveProfilePressed:(id)sender {
    
    NSLog(@"\n\n\nsaveProfilePressed is called");
    
    if (!profileName) {
        profileName = [self askForProfileName];
    }
    
    // Create user profile
    UserProfile *newProfile = [self createProfile:profileName];
    
    NSLog(@"new profile = %@", newProfile);
    
    // Add profile via notification.
    [[UserProfileManager sharedInstance] addProfile:newProfile];
    
    // End calibration mode.
    [[BLEDeviceManager sharedInstance] calibrationComplete];
    
    NSLog(@"immediate use = %d", immediateUse);
    
    // Set profile if option selected.
    if (immediateUse) {
        [[BLEDeviceManager sharedInstance] setProfile:newProfile];
    }
    
    // Close window.
    [[self window] orderOut:self];
}

/*
 * Shows an alert and asks for the profile name.
 */
- (NSString *)askForProfileName {
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Enter a name for the new profile:";
    [alert layout];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    input.placeholderString = @"ProfileName";
    input.stringValue = @"";
    //    [input autorelease];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    
    if (button == NSAlertFirstButtonReturn) {
        NSLog(@"OK was pressed");
        
        // If input is valid (not empty)
        if (![[input stringValue] isEqualToString:@""]) {
            NSLog(@"Create new profile with name: %@", [input stringValue]);
            return [input stringValue];
            
        } else {
            NSLog(@"No name entered");
            return nil;
        }
    }
    if (button == NSAlertSecondButtonReturn) {
        NSLog(@"Cancel was pressed");
    }
    
    return nil;
    
}

/*
 * Called when the animation has finished.
 */
- (void)animationFinished:(id)sender {
    
    // Create alert.
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Data Acquisition completed!"];
    [alert setInformativeText:@"Click on the graph in order to set the negative and positive threshold values. After doing so you can either save the profile or test it with the selected parameters."];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        
        [_startCalibrationButton setTitle:@"Try Parameters"];
        [_startCalibrationButton setEnabled:false];
    }
}

/*
 * Called when the calibration process is completed and the new user profile need to be created.
 */
- (UserProfile *)createProfile:(NSString *)name {
    
    // Build array with calibration parameters.
    NSMutableArray *parameters = [[NSMutableArray alloc] initWithCapacity:12];
    
    NSLog(@"NSNUmber neg float = %f", [negativeThreshold floatValue]);
    
    float negThreshold = [negativeThreshold floatValue] / (float)SCALING_FACTOR;
    float posThreshold = [positiveThreshold floatValue] / (float)SCALING_FACTOR;
    float hyst = (hysteresis/(float)SCALING_FACTOR);
    float minVal = (minValue / (float)SCALING_FACTOR);
    float maxVal = (maxValue / (float)SCALING_FACTOR);
    
    //NSLog(@"%f", negThreshold);
    //NSLog(@"%f", posThreshold);
    //NSLog(@"%f", hyst);
    //NSLog(@"%f", minValue);
    //NSLog(@"%f", maxValue);
    //NSLog(@"%f", riseTimeRangeMax);
    
    [parameters addObject:[NSNumber numberWithFloat:negThreshold]];
    [parameters addObject:[NSNumber numberWithFloat:posThreshold]];
    [parameters addObject:[NSNumber numberWithFloat:hyst]];
    [parameters addObject:[NSNumber numberWithFloat:minVal]];
    [parameters addObject:[NSNumber numberWithFloat:maxVal]];
    [parameters addObject:[NSNumber numberWithFloat:minFall]];
    [parameters addObject:[NSNumber numberWithFloat:maxFall]];
    [parameters addObject:[NSNumber numberWithFloat:minRise]];
    [parameters addObject:[NSNumber numberWithFloat:maxRise]];
    [parameters addObject:[NSNumber numberWithFloat:riseTimeRangeMin]];
    [parameters addObject:[NSNumber numberWithFloat:riseTimeRangeMax]];
    [parameters addObject:[NSNumber numberWithFloat:eyeClosedTime]];
    
    // Create profile id.
    NSNumber *profileId = [NSNumber numberWithInt:23];

    // Create new user profile
    UserProfile *newProfile = [UserProfile userProfileWithName:name andId:profileId andParameters:parameters];
    
    return newProfile;
}

@end
