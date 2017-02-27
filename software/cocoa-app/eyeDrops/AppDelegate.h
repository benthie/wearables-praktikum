/**
 * @file        AppDelegate.h
 * @brief       Header file containing the App Delegate class.
 *
 * @author      Benjamin Thiemann
 * @date        2016/11/16
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
#import <Foundation/Foundation.h>

#import "Settings.h"
#import "BLEDeviceManager.h"
#import "UserProfileManager.h"
#import "Protocol.h"
#import "BlurredWindow.h"
#import "PreferencesWindowController.h"
#import "AboutWindowController.h"

/**
 * @brief       The App Delegate class.
 *
 * @class       AppDelegate
 * @discussion  This class represents the application's delegate and takes cares of the 
 *      initialization process. It also manages the menu and thus the actual application.
 *
 * @author      Benjamin Thiemann
 * @date        2016/11/16
 */
@interface AppDelegate : NSObject <NSApplicationDelegate>

/**
 * The array containing all window controllers (screens).
 */
@property (strong) NSMutableArray *windowControllers;

/**
 * The menubar's status item.
 */
@property (strong, nonatomic) NSStatusItem *statusItem;

/**
 * The main menu.
 */
@property (strong, nonatomic) NSMenu *mainMenu;

/**
 * The submenu containing all profiles.
 */
@property (strong, nonatomic) NSMenu *subMenuProfiles;

/**
 * The submenu containing all devices.
 */
@property (strong, nonatomic) NSMenu *subMenuDevices;

/**
 * The menu item containing the submenu with all prpfiles.
 */
@property (strong, nonatomic) NSMenuItem *menuItemProfiles;

/**
 * The active profile in the menu.
 */
@property (strong, nonatomic) NSMenuItem *menuItemActiveProfile;

/**
 * The menu item containing the submenu with all devices.
 */
@property (strong, nonatomic) NSMenuItem *menuItemDevices;

/**
 * The active device in the menu.
 */
@property (strong, nonatomic) NSMenuItem *menuItemActiveDevice;

/**
 * The menu item containing the current scanning status.
 */
@property (strong, nonatomic) NSMenuItem *menuItemScan;

/**
 * The last active application.
 */
@property (weak) NSRunningApplication *oldApp;

/**
 * The application name.
 */
@property NSString *appName;

/**
 * Boolean value that indicates whether blurring is desired.
 */
@property bool wantsBlurring;

/**
 * Boolean value that indicates whether blurring currently activated.
 */
@property bool isBlurring;

/**
 * This method updates the menu with new profiles.
 */
- (void)updateMenuWithProfiles;

/**
 * This method updates the menu with a new bluetooth status.
 *
 * @param   state
 *      The new bluetooth state.
 */
- (void)updateMenuWithNewBluetoothStatus:(NSString *)state;

/**
 * This method updates the menu with new found devices.
 *
 * @param   devices
 *      The new devices.
 */
- (void)updateMenuWithFoundDevices:(NSMutableArray *)devices;

/**
 * This method updates the menu with a connection attempt.
 */
- (void)updateMenuWithConnectionAttempt;

/**
 * This method updates the menu with a new connection.
 *
 * @param   device
 *      The connected device.
 */
- (void)updateMenuWithConnection:(CBPeripheral *)device;

/**
 * This method updates the menu with a disconnection.
 *
 * @param   device
 *      The disconnected device.
 */
- (void)updateMenuWithDisconnection:(CBPeripheral *)device;

/**
 * This method updates the application icon's tooltip.
 */
- (void)updateToolTip;

/**
 * This method starts the blurring.
 */
- (void)startBlur;

/**
 * This method stops the blurring.
 */
- (void)stopBlur;

@end
