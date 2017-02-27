/**
 * @file        PreferencesWindowController.m
 * @brief       Implementation file containing the preferences window controller class.
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/27
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

#import "PreferencesWindowController.h"

@interface PreferencesWindowController ()

@property CalibrationWindowController *calibrationWindowController;
@property Settings *settings;

@end


@implementation PreferencesWindowController

@synthesize generalView;
@synthesize profilesView;
@synthesize segmentedControl;
@synthesize maxBlurRadius;
@synthesize blurStep;
@synthesize blurSpeed;
@synthesize blinkTimerValue;
@synthesize autoScan;
@synthesize autoConnect;
@synthesize settings;
@synthesize autoSelectXMLFileCheckbox;
@synthesize selectFile;
@synthesize path;
@synthesize xmlFile;
@synthesize profiles;
@synthesize calibrationWindowController;
@synthesize autoSelect;
@synthesize batteryLevel;
@synthesize levelIndicator;
@synthesize textView;
@synthesize tableView;

/*
 * Initialzation method.
 */
- (id)init {
    
    self = [super initWithWindowNibName:@"PreferencesWindowController"];
    
    if (self) {
        
        // Load settings.
        settings = [Settings sharedInstance];
        
        // Initialize values for bindings.
        maxBlurRadius   = settings.maxBlurRadius;
        blurStep        = settings.blurStep;
        blurSpeed       = settings.blurSpeed;
        blinkTimerValue = settings.blinkTimerValue;
        autoScan        = settings.autoScan;
        autoConnect     = settings.autoConnect;
        xmlFile         = settings.xmlFile;
        autoSelect      = settings.autoSelectXMLFile;
        batteryLevel    = settings.batteryLevel;
        
        // Retrieve profiles from profiles manager.
        profiles = [[UserProfileManager sharedInstance:nil] getProfiles];
        
        // Add observers for notifications.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profilesNeedUpdate:) name:@"EDNotificationProfileCreated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profilesNeedUpdate:) name:@"EDNotificationProfileDeleted" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelUpdate:) name:@"EDNotificationBatteryLevelChanged" object:nil];
    }
    
    return self;
}

/*
 * Update the battery level.
 */
- (void)batteryLevelUpdate:(id)sender {
    
    batteryLevel = [[Settings sharedInstance] batteryLevel];
    batteryLevel *= 1000;
    [levelIndicator setIntValue:(int)batteryLevel];
}

/*
 * Window did load.
 */
- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.titleVisibility = NSWindowTitleHidden;
}

/*
 * Switch view.
 */
- (IBAction)segmentSwitch:(id)sender {
    
    switch ([(NSSegmentedControl *)sender selectedSegment]) {
        case 0:
            //toggle the correct view to be visible
            [generalView setHidden:NO];
            [profilesView setHidden:YES];
            // [bluetoothView setHidden:YES];
            break;
        case 1:
            //toggle the correct view to be visible
            [generalView setHidden:YES];
            [profilesView setHidden:NO];
            // [bluetoothView setHidden:NO];
            break;
    }
}

/*
 * Switch view from outside before opening preferences window.
 */
- (void)setView:(NSString *)view {
    
    if ([view isEqualToString:@"General"]) {
        [generalView setHidden:NO];
        [profilesView setHidden:YES];
        [segmentedControl setSelectedSegment:0];
    } else {
        [generalView setHidden:YES];
        [profilesView setHidden:NO];
        [segmentedControl setSelectedSegment:1];
    }
}

/*
 * Awake from nib interrupt.
 */
- (void)awakeFromNib {    
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView reloadData];
}

/*
 * Draw rect method.
 */
//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//}


#pragma mark
#pragma mark - IBAction methods for the XML file selection

/*
 * Opens a file dialog to select a new xml file.
 */
- (IBAction)openExistingXMLFile:(id)sender {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    NSArray *fileType = [[NSArray alloc] initWithObjects:@"xml", nil];
    [panel setAllowedFileTypes:fileType];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:YES];
    [panel setPrompt:@"OK"];
    
    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    [panel beginWithCompletionHandler:^(NSInteger result){
        
        if (result == NSFileHandlingPanelOKButton) {
            
            NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
            
            xmlFile = [theDoc path];
            [path setStringValue:xmlFile];
            
            settings.xmlFile = xmlFile;
            
            // Tell profiles manager to load new file
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"EDxmlFileChanged" object:xmlFile];
            [[UserProfileManager sharedInstance:nil] changeFile:xmlFile];
        }
    }];    
}

#pragma mark
#pragma mark - IBAction methods for the buttons

/*
 * Opens the calibration window.
 */
- (IBAction)createNewProfileClicked:(id)sender {
 
    //calibrationWindowController = [[CalibrationWindowController alloc] init];
    //[calibrationWindowController showWindow:self];
    
    if ([[BLEDeviceManager sharedInstance] hasConnection]) {
        [[BLEDeviceManager sharedInstance] wantsBlurring:NO];
        calibrationWindowController = [[CalibrationWindowController alloc] init];
        [calibrationWindowController showWindow:self];
    } else {
        NSLog(@"Not connected.");
    }
}

/*
 * Deletes the selected profile.
 */
- (IBAction)deleteProfileClicked:(id)sender {
    
    NSUInteger selectedRow = [tableView selectedRow];
    
    // Check if a valid row is selected.
    if (selectedRow != -1) {
        
        // Get selected profile.
        UserProfile *currentProfile = [profiles objectAtIndex:selectedRow];
        
        NSString *messageText = [NSString stringWithFormat:@"Delete profile \"%@\" ?", currentProfile.getName];
        
        // Create alert.
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:messageText];
        [alert setInformativeText:@"This action cannot be withdrawn."];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        // Check if user really wants to delete the profile.
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            
            // Delete the current profile.
            [[UserProfileManager sharedInstance] deleteProfile:currentProfile];
            
            [textView setString:@"Profile Information - Select a profile from the left table to inspect the calibration parameters."];
        }
    } else {
        
        // Create alert.
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"No profile selected!"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
}


#pragma mark
#pragma mark - Table view data source protocol methods

/*
 * Returns the number of records managed for aTableView by the data source object.
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return profiles.count;
}


#pragma mark
#pragma mark - Table view delegate protocol methods

/*
 * Asks the delegate for a view to display the specified row and column.
 */
- (NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Set identifier string to same as in IB.
    NSString *identifier = [tableColumn identifier];
    
    // Check for "MainCell" identifier
    if ([identifier isEqualToString:@"MainCell"]) {
        
        // We pass us as the owner so we can setup target/actions into this main controller object
        NSTableCellView *cellView = [aTableView makeViewWithIdentifier:identifier owner:self];
        
        // Then setup properties on the cellView based on the column
        cellView.textField.stringValue = [[profiles objectAtIndex:row] name];
        cellView.objectValue = [profiles objectAtIndex:row];
        
        return cellView;
    } else if ([identifier isEqualToString:@"SizeCell"]) {
        NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
    }
    return nil;
}

/*
 * Tells the delegate that the table view’s selection has changed.
 */
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    NSUInteger selectedRow = [tableView selectedRow];
    
    // Check if a valid row is selected.
    if (selectedRow != -1) {
        
        // Get selected profile.
        UserProfile *currentProfile = [profiles objectAtIndex:selectedRow];
        
        // Parameter names as string array.
        NSString *paramNames[] = {
            @"thresh_neg\t",
            @"thresh_pos\t",
            @"hysteresis\t",
            @"min_min\t\t",
            @"max_max\t\t",
            @"t_fall_min\t",
            @"t_fall_max\t",
            @"t_rise_min\t",
            @"t_rise_max\t",
            @"t_total_min\t",
            @"t_total_max\t",
            @"allowed_zeros"
        };
        
        // Build up the info string for the text view.
        NSString *profileInfo = [NSString stringWithFormat:@"Name:\t%@\n", [currentProfile getName]];
        for (int i=0; i<12; i++) {
            profileInfo = [profileInfo stringByAppendingString:[NSString stringWithFormat:@"\n%@:\t%@", paramNames[i], [currentProfile getParameter:i]]];
        }
        
        // Set the string.
        [textView setString:profileInfo];
    }
}


#pragma mark
#pragma mark - Notification observer methods

/*
 * Called when a new profile was added, a profile was deleted or a profile was recalibrated.
 */
- (void)profilesNeedUpdate:(id)sender {
    
    profiles = [[UserProfileManager sharedInstance:nil] getProfiles];
    NSLog(@"Es wurde %lu Profile von AppDelegate geladen", (unsigned long)[profiles count]);
    
    [tableView reloadData];
}


#pragma mark
#pragma mark - Notification observer methods


- (IBAction)maxBlurRadiusChanged:(id)sender {
    settings.maxBlurRadius = [sender integerValue];
}

- (IBAction)blurStepChanged:(id)sender {
    settings.blurStep = [sender floatValue];
}

- (IBAction)blurSpeedChanged:(id)sender {
    settings.blurSpeed = [sender floatValue];
}

- (IBAction)blinkTimerValueChanged:(id)sender {
    settings.blinkTimerValue = [sender integerValue];
}

- (IBAction)autoScanChanged:(id)sender {
    if ([sender state] == NSOnState) {
        settings.autoScan = true;
        // Check if no device is connected and only if, scan for devices.
        if (! [[BLEDeviceManager sharedInstance] hasConnection] ) {
            [[BLEDeviceManager sharedInstance] scanForDevices];
        }
    } else {
        settings.autoScan = false;
    }
}

- (IBAction)autoConnectChanged:(id)sender {
    if ([sender state] == NSOnState) {
        settings.autoConnect = true;
        // Check if no device is connected and only if, scan for devices.
        if (! [[BLEDeviceManager sharedInstance] hasConnection] ) {
            [[BLEDeviceManager sharedInstance] scanForDevices];
        }
    } else {
        settings.autoConnect = false;
    }
}



@end
