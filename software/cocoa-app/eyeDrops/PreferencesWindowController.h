/**
 * @file        PreferencesWindowController.h
 * @brief       Header file containing the preferences window controller class.
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

#import <Cocoa/Cocoa.h>
#import "Settings.h"
#import "CalibrationWindowController.h"

/**
 * @brief       The preferences window (controller).
 *
 * @class       PreferencesWindowController
 * @discussion  This class represents the preferences window where all the settings are stored. It
 *      also visualizes the user profile manager in a tableview and a textview. All changed settings
 *      will be automatically stored to a file called settings.txt if the application is terminated.
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/17
 */
@interface PreferencesWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>

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
 * Integer value that represents the allowed time without a blink.
 */
@property NSUInteger blinkTimerValue;

/**
 * Boolean value that indicates whether the app automatically selects the XML file.
 */
@property BOOL autoSelect;

/**
 * The checkbox to selecct XML file autoSelect.
 */
@property (strong) IBOutlet NSButton *autoSelectXMLFileCheckbox;

/**
 * The button to select a XML file from disk.
 */
@property (strong) IBOutlet NSButton *selectFile;

/**
 * The textfield displaying the XML file path.
 */
@property (strong, nonatomic) IBOutlet NSTextField *path;

/**
 * The table view displaying the profiles.
 */
@property IBOutlet NSTableView *tableView;

/**
 * The text view displaying a profiles content.
 */
@property IBOutlet NSTextView *textView;

/**
 * The path to the XML file.
 */
@property NSString *xmlFile;

/**
 * The container for the profiles.
 */
@property NSMutableArray *profiles;

/**
 * The general preferences view.
 */
@property IBOutlet NSView *generalView;

/**
 * The profiles preferences view.
 */
@property IBOutlet NSView *profilesView;

/**
 * The button to create a new profile.
 */
@property IBOutlet NSButton *createNewProfileButton;

/**
 * The button to delete a profile.
 */
@property IBOutlet NSButton *deleteProfileButton;

/**
 * The checkbox to selecct autoScan.
 */
@property (weak) IBOutlet NSButton *autoScanCheckbox;

/**
 * The checkbox to selecct autoConnect.
 */
@property (weak) IBOutlet NSButton *autoConnectCheckbox;

/**
 * The levelIndicator to show the battery level.
 */
@property (weak) IBOutlet NSLevelIndicator *levelIndicator;

/**
 * The segmented control to swtich between general and profiles view.
 */
@property (weak) IBOutlet NSSegmentedControl *segmentedControl;

/**
 * This method is called when the profiles have changed.
 *
 * @param   sender
 *      The sending instance.
 */
- (void)profilesNeedUpdate:(id)sender;

/**
 * This method changes the active view (general or profiles).
 *
 * @param   view
 *      The view to activate.
 */
- (void)setView:(NSString *)view;

/**
 * Initialization method.
 */
- (id)init;

/**
 * Invoked when value of maxBlurRadius changed.
 */
- (IBAction)maxBlurRadiusChanged:(id)sender;

/**
 * Invoked when value of blurStep changed.
 */
- (IBAction)blurStepChanged:(id)sender;

/**
 * Invoked when value of blurSpeed changed.
 */
- (IBAction)blurSpeedChanged:(id)sender;

/**
 * Invoked when value of blinkTimerValue changed.
 */
- (IBAction)blinkTimerValueChanged:(id)sender;

/**
 * Invoked when value of autoScan changed.
 */
- (IBAction)autoScanChanged:(id)sender;

/**
 * Invoked when value of autoConnect changed.
 */
- (IBAction)autoConnectChanged:(id)sender;

@end
