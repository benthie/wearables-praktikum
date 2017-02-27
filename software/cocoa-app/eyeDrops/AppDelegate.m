/**
 * @file        AppDelegate.m
 * @brief       Implementation file containing the application's delegate.
 *
 * @author      Benjamin Thiemann
 * @date        2016/11/22
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

#import "AppDelegate.h"


@interface AppDelegate ()

/*
 * Reference to the BLE device manager.
 */
@property (strong) BLEDeviceManager *bleDeviceManager;

/*
 * Reference to the profile manager.
 */
@property (strong) UserProfileManager *profileManager;

/*
 * The preferences window.
 */
@property (strong) PreferencesWindowController *preferencesWindowController;

/*
 * The about window.
 */
@property (strong) AboutWindowController *aboutWindowController;

@end


@implementation AppDelegate

@synthesize windowControllers;
@synthesize statusItem;
@synthesize mainMenu;
@synthesize subMenuDevices;
@synthesize subMenuProfiles;
@synthesize menuItemProfiles;
@synthesize menuItemActiveProfile;
@synthesize menuItemDevices;
@synthesize menuItemActiveDevice;
@synthesize menuItemScan;
@synthesize bleDeviceManager;
@synthesize profileManager;
@synthesize preferencesWindowController;
@synthesize aboutWindowController;
@synthesize appName;
@synthesize isBlurring;
@synthesize wantsBlurring;


#pragma mark
#pragma mark - NSApplication delegate methods

/*
 * Invoked when application will become active.
 */
- (void)applicationWillBecomeActive:(NSNotification *)aNotification {
    _oldApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
}

/*
 * Invoked when application did finish launching.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Create / Load settings
    Settings *settings = [Settings sharedInstance];
    
    // Set blur mode by default to false.
    wantsBlurring = true;
    
    // Initialize blur flag.
    isBlurring = false;
    
    // Set application name.
    appName = @"eyeDrops";
    
    // Initialize the UserProfileManager.
    profileManager = [UserProfileManager sharedInstance:settings.xmlFile];
    
    // menuItemActiveProfile = nil;
    NSLog(@"INIT PHASE >>> Profile Manager initialized.");

    // Initialize the BLE manager.
    bleDeviceManager = [BLEDeviceManager sharedInstance];
    
    // Check if there is a profile to use.
    if ([[profileManager getProfiles] count] > 0) {
        
        // By default use first profile in list.
        [bleDeviceManager setProfile:[[profileManager getProfiles] objectAtIndex:0]];
        NSLog(@"INIT PHASE >>> BLE Manager initialized.");
        
    } else {
        NSLog(@"INIT PHASE >>> BLE Manager not completely initialized. No profiles available to work on.");
    }
    
    
    // Initialize the menu
    [self initMenu];
    NSLog(@"INIT PHASE >>> Menu initialized.");

    // Create a menu bar item with icon
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setAction:@selector(appIconClicked:)];
    statusItem.highlightMode = NO;
    statusItem.button.image = [NSImage imageNamed:@"statusItemOff.png"];
    [self updateToolTip];
    
    NSLog(@"INIT PHASE >>> Menubar status item initialized.");
    
    // Prepare all connected screens for blurring
    [self prepareScreensForBlurring];
    NSLog(@"INIT PHASE >>> Screens prepared for blurring.\n\n");

    // Make the app stay on top especially when blur mode is active
    [_oldApp activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    
    // Create Preferences Window
    preferencesWindowController = [[PreferencesWindowController alloc] init];
    // [preferencesWindowController showWindow:self];
    //[preferencesWindowController.window orderFront:self];
    // [preferencesWindowController.window orderOut:self];
}

/*
 * Invoked when application will terminate.
 */
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    // Path and file name for the settings
    NSString *settingsFile = [[NSString alloc] initWithString:NSHomeDirectory()];
    settingsFile = [settingsFile stringByAppendingString:[NSString stringWithFormat:@"/%@/settings.txt", appName]];
    
    Settings *settings = [Settings sharedInstance];
    
    // Write settings to disk
    [NSKeyedArchiver archiveRootObject:settings toFile:settingsFile];
    
    // Save the profiles.
    [profileManager saveProfiles];
}


#pragma mark
#pragma mark - Menu item click actions

/*
 * Show about window.
 */
- (void)showAbout {
    aboutWindowController = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindowController"];
    [aboutWindowController showWindow:self];
}

/*
 * Open preferences.
 */
- (void)openPreferences {
    [[BLEDeviceManager sharedInstance] requestBatteryLevel];
    [preferencesWindowController setView:@"General"];
    [preferencesWindowController showWindow:self];
    //[preferencesWindowController.window orderFront:self];
}

/*
 * Open the profile manager.
 */
- (void)manageProfiles {
    [[BLEDeviceManager sharedInstance] requestBatteryLevel];
    [preferencesWindowController setView:@"Profiles"];
    [preferencesWindowController showWindow:self];
    //[preferencesWindowController.window orderFront:self];
}

/*
 * Open the menu or change blur mode on control-click.
 */
- (void)appIconClicked:(id)sender {
    
    // Get last click event.
    NSEvent *event = [NSApp currentEvent];
    
    // Check for control-click.
    if([event modifierFlags] & NSControlKeyMask) {
        
        // Control-click was performed, change item and turn blurring on
        if (wantsBlurring) {
            
            // Set new image.
            statusItem.button.image = [NSImage imageNamed:@"statusItemOn.png"];
            [statusItem.button.image setTemplate:YES];
            [statusItem.button updateLayer];
            
            // Set to false. Seems wrong. But is kind of flag for the next click.
            wantsBlurring = false;
            
            // Set blurring to true in BLE device manager.
            [[BLEDeviceManager sharedInstance] wantsBlurring:YES];
            
        // Control-click was performed, change item and turn blurring off
        } else {
            // Set new image.
            statusItem.button.image = [NSImage imageNamed:@"statusItemOff.png"];
            
            //[statusItem.button.image setTemplate:YES];
            [statusItem.button updateLayer];
            
            // Set to true. Seems wrong. But is kind of flag for the next click.
            wantsBlurring = true;
            
            // Set blurring to false in BLE device manager.
            [[BLEDeviceManager sharedInstance] wantsBlurring:NO];
        }
        
        [self updateToolTip];
        
        return;
    }
    
    // Normal click will show menu.
    [self.statusItem popUpStatusItemMenu:mainMenu];
}

/*
 * Scan for devices clicked.
 */
- (void)scanForDevices:(id)sender {
    
    menuItemScan.title = @"Stop Scanning";
    [menuItemScan setAction:@selector(stopScanning:)];
    menuItemDevices.title = @"Scanning ...";
    menuItemDevices.enabled = NO;
    
    [bleDeviceManager scanForDevices];
}

/*
 * Stop scanning clicked.
 */
- (void)stopScanning:(id)sender {
    
    menuItemScan.title = @"Scan for devices";
    [menuItemScan setAction:@selector(scanForDevices:)];
    menuItemDevices.title = @"No devices discovered";
    
    [bleDeviceManager abortScanning];
}

/*
 * Device selected from menu.
 */
- (void)deviceSelectedFromMenu:(id)sender {
    
    // check if selected device is connected
    if ( [sender state] == NSOnState ) {
        [bleDeviceManager disconnectFromDevice];
        [sender setState:NSOffState];
    } else {
        [bleDeviceManager connectToDevice:[sender representedObject]];
        menuItemDevices.title = @"Connecting ...";
        menuItemDevices.enabled = NO;
    }
}

/*
 * Profile selected from menu.
 */
- (void)profileSelectedFromMenu:(id)sender {
    
    if ( [sender state] == NSOffState ) {
        
        [bleDeviceManager setProfile:[sender representedObject]];
        [sender setState:NSOnState];
        
        // Disable last active profile if there is one.
        if (menuItemActiveProfile != nil) {
            [menuItemActiveProfile setState:NSOffState];
            menuItemActiveProfile = sender;
        } else {
            menuItemActiveProfile = sender;
        }
    }
}


#pragma mark
#pragma mark - Menu initialization

/*
 * Initialize the menu.
 */
- (void)initMenu {

    // Create the menu
    mainMenu = [[NSMenu alloc] initWithTitle:@""];
    [mainMenu setAutoenablesItems:NO];
    
    [mainMenu addItemWithTitle:@"About" action:@selector(showAbout) keyEquivalent:@""];
    // [mainMenu addItemWithTitle:@"Calibrate" action:@selector(onHandleFour:) keyEquivalent:@""];
    
    subMenuProfiles = [[NSMenu alloc] init];
    [subMenuProfiles addItemWithTitle:@"Manage profiles" action:@selector(manageProfiles) keyEquivalent:@""];
    
    menuItemProfiles = [[NSMenuItem alloc] initWithTitle:@"Select profile" action:nil keyEquivalent:@""];
    [menuItemProfiles setEnabled:NO];
    [mainMenu addItem:menuItemProfiles];
    [self updateMenuWithProfiles];
    
    // -------------------------------------------
    [mainMenu addItem:[NSMenuItem separatorItem]];
    // -------------------------------------------
    
    subMenuDevices = [[NSMenu alloc] init];
    
    menuItemScan = [[NSMenuItem alloc] initWithTitle:@"Scan for devices" action:@selector(scanForDevices:) keyEquivalent:@""];
    [mainMenu addItem:menuItemScan];
    
    menuItemDevices = [[NSMenuItem alloc] initWithTitle:@"No devices discovered" action:nil keyEquivalent:@""];
    menuItemDevices.enabled = NO;
    [mainMenu addItem:menuItemDevices];
    
    menuItemActiveDevice = nil;
    
    // -------------------------------------------
    [mainMenu addItem:[NSMenuItem separatorItem]];
    // -------------------------------------------
    
    [mainMenu addItemWithTitle:@"Preferences" action:@selector(openPreferences) keyEquivalent:@""];
    [mainMenu addItem:[NSMenuItem separatorItem]];
    [mainMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
}


#pragma mark
#pragma mark - Update menu methods

- (void)updateToolTip {
    
    NSMutableString *toolTipString = [NSMutableString stringWithFormat:@"eyeDrops v2.3\n"];
    
    // Check for connection.
    if ([[BLEDeviceManager sharedInstance] hasConnection]) {
        [toolTipString appendString:[NSString stringWithFormat:@"\nCurrently connected to %@", [menuItemActiveDevice title]]];
    } else {
        [toolTipString appendString:[NSString stringWithFormat:@"\nNo active bluetooth connection."]];
    }
    
    // Check for profile.
    if ([[BLEDeviceManager sharedInstance] getCurrentProfile]) {
        [toolTipString appendString:[NSString stringWithFormat:@"\nWorking with profile: %@ - Enforced blinks: %li",
                                     [menuItemActiveProfile title],
                                     [[BLEDeviceManager sharedInstance] getEnforcedBlinks]]];
    } else {
        [toolTipString appendString:[NSString stringWithFormat:@"\nNo profile was uploaded."]];
    }
    
    
    
    // Print the parameters
    if (wantsBlurring) {
        [toolTipString appendString:[NSString stringWithFormat:@"\n\nControl click to enable blur mode."]];
    } else {
        [toolTipString appendString:[NSString stringWithFormat:@"\n\nControl click to disable blur mode."]];
    }
    
    [statusItem setToolTip:toolTipString];
    
}


/*
 * Update the menu.
 */
- (void)updateMenuWithProfiles {
    
    [subMenuProfiles removeAllItems];
    
    [subMenuProfiles addItemWithTitle:@"Manage profiles" action:@selector(manageProfiles) keyEquivalent:@""];
    [subMenuProfiles addItem:[NSMenuItem separatorItem]];
    
    NSMutableArray *profiles = [profileManager getProfiles];
    
    UserProfile *currentProfile = [[BLEDeviceManager sharedInstance] getCurrentProfile];
    
    if ( [profiles count] > 0 ) {
        for (UserProfile* p in profiles) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[p name] action:@selector(profileSelectedFromMenu:) keyEquivalent:@""];
            menuItem.representedObject = p;
            if (p == currentProfile) {
                [menuItem setState:NSOnState];
                menuItemActiveProfile = menuItem;
            }
            [subMenuProfiles addItem:menuItem];
        }
        
        // Add the submenu.
        [menuItemProfiles setSubmenu:subMenuProfiles];
        
        // Enable the supermenu.
        menuItemProfiles.enabled = YES;
        
    } else {
        menuItemProfiles.enabled = NO;
    }
    
    [self updateToolTip];
}

/*
 * Update the menu.
 */
- (void)updateMenuWithNewBluetoothStatus:(NSString *)state {
    
    if ( [state isEqualToString:@"ON"] ) {
        menuItemScan.title = @"Scan for devices";
        menuItemScan.enabled = YES;
        [menuItemDevices setHidden:NO];
        menuItemDevices.title = @"No devices discovered";
        menuItemDevices.enabled = NO;
    } else {
        menuItemScan.title = state;
        menuItemScan.enabled = NO;
        [menuItemDevices setHidden:YES];
    }
}

/*
 * Update the menu.
 */
- (void)updateMenuWithFoundDevices:(NSMutableArray *)devices {
    
    menuItemScan.title = @"Scan for devices";
    
    [subMenuDevices removeAllItems];
    [subMenuDevices addItemWithTitle:@"Select device to (dis)connect" action:nil keyEquivalent:@""];
    
    // -------------------------------------------------
    [subMenuDevices addItem:[NSMenuItem separatorItem]];
    // -------------------------------------------------
    
    for (CBPeripheral *p in devices) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[p name] action:@selector(deviceSelectedFromMenu:) keyEquivalent:@""];
        menuItem.representedObject = p;
        [subMenuDevices addItem:menuItem];
    }
    
    [menuItemDevices setSubmenu:subMenuDevices];
    
    menuItemDevices.title = @"Available Devices";
    menuItemDevices.enabled = YES;
    
    [self updateToolTip];
    
}

/*
 * Update the menu.
 */
- (void)updateMenuWithConnectionAttempt {
    
    menuItemDevices.title = @"Connecting ...";
    menuItemDevices.enabled = NO;
}

/*
 * Update the menu.
 */
- (void)updateMenuWithConnection:(CBPeripheral *)device {
    
    for (NSMenuItem *item in [subMenuDevices itemArray] ) {
        if ( [item representedObject] == device ) {
            item.state = NSOnState;
            menuItemActiveDevice = item;
        }
        else
            item.state = NSOffState;
    }
    
    menuItemDevices.title = @"Available Devices";
    menuItemDevices.enabled = YES;
    
    [self updateToolTip];
}

/*
 * Update the menu.
 */
- (void)updateMenuWithDisconnection:(CBPeripheral *)device {
    
    // Set new image.
    statusItem.button.image = [NSImage imageNamed:@"statusItemOff.png"];
    
    //[statusItem.button.image setTemplate:YES];
    [statusItem.button updateLayer];
    
    // Set to true. Seems wrong. But is kind of flag for the next click.
    wantsBlurring = true;
    
    // Set blurring to false in BLE device manager.
    [[BLEDeviceManager sharedInstance] wantsBlurring:NO];
    
    for (NSMenuItem *item in [subMenuDevices itemArray] ) {
        item.state = NSOffState;
        menuItemActiveDevice = nil;
    }
    
    [self updateToolTip];
}


#pragma mark
#pragma mark - Blurring methods

/*
 * Prepare the screens for blurring.
 */
- (void)prepareScreensForBlurring {
    
    NSArray *screens = [NSScreen screens];
    windowControllers = [[NSMutableArray alloc] init];
    
    for (NSScreen *screen in screens) {
        NSRect mainFrame = [screen frame];
        int height = (int)mainFrame.size.height;
        int width = (int)mainFrame.size.width;
        NSWindow *window = [[NSWindow alloc] init];
        
        // maximize frame
        NSRect frame = screen.visibleFrame;
        frame.origin = CGPointMake(frame.origin.x, frame.origin.y -10);
        frame.size = CGSizeMake(width, height+80);
        [window setFrame: frame display: YES animate: NO];
        BlurredWindow *windowController = [[BlurredWindow alloc] initWithWindow:window];
        
        // blur background
        [windowController showWindow:nil];
        [windowControllers addObject:windowController];
        
        NSUInteger collectionBehavior;
        
        // Gets the current collection behavior of the window
        collectionBehavior = [window collectionBehavior];
        
        // Adds the option to make the window visible on all spaces
        collectionBehavior |= NSWindowCollectionBehaviorCanJoinAllSpaces;
        
        // Sets the new collection behaviour
        [window setCollectionBehavior: collectionBehavior];
    }
}

/*
 * Start the blurring on all screens.
 */
- (void)startBlur {
    
    for (BlurredWindow *blurredWindow in windowControllers) {
        
        [blurredWindow showWindow:nil];
        [blurredWindow startBlur];
        isBlurring = true;
    }
}

/*
 * Stop the blurring on all screens.
 */
- (void)stopBlur {
    
    for (BlurredWindow *blurredWindow in windowControllers) {
        [blurredWindow showWindow:nil];
        [blurredWindow stopBlur];
        isBlurring = false;
    }
}

@end
