/**
 * @file        BLEDeviceManager.h
 * @brief       Header file containing the Bluetooth low energy device manager class.
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/21
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

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "UserProfile.h"
#import "Protocol.h"
#import "Settings.h"

/**
 * @brief   This enumeration contains the connection state the device manger is currently in.
 *
 * @enum    CON_STATE
 */
typedef enum CON_STATE : NSInteger {
    CON_STATE_BOOT_UP,                      /*!< Boot up. Device freshly connected. */
    CON_STATE_SETTING_PROFILE,              /*!< Currently sending the profile  to the RFDuino. */
    CON_STATE_NORMAL_MODE,                  /*!< Normal mode. Waiting for user to blink. */
    CON_STATE_BLURRING,                     /*!< Screen is blurred, too long without blinking. */
    CON_STATE_CALIBRATION_INCOMING_DATA,    /*!< Calibration mode. Data is coming in. */
    CON_STATE_CALIBRATION,                  /*!< Calibration mode. Data has been sent. Visual calibration is in progress. */
} CON_STATE;

/**
 * @brief   This enumeration contains the different user notification identifiers.
 *
 * @enum    USER_NOTIFICATION
 */
typedef enum USER_NOTIFICATION : NSInteger {
    USER_NOTIFICATION_DEVICE_FOUND,         /*!< Devices found. */
    USER_NOTIFICATION_DEVICE_CONNECTED,     /*!< Device connected. */
    USER_NOTIFICATION_DEVICE_DISCONNECTED,  /*!< Device disconnected. */
    USER_NOTIFICATION_PROFILE_SET,          /*!< Profile successfully sent to RFDuino. */
    USER_NOTIFICATION_CALIBRATION_DONE,     /*!< Calibration process completed. */
    USER_NOTIFICATION_BLE_NOT_SUPPORTED,    /*!< Bluetooth Low Energy not supported. */
} USER_NOTIFICATION;

/**
 * @brief       The Bluetooth low energy device manager.
 *
 * @class       BLEDeviceManager
 * @discussion  This class manages the connection and communication with a BLE device. It uses the
 *      defined protocol to decode and encode the sent messages between the RFDuino and the PC.
 *      <p>
 *      Since the device manager is handling the imcoming messages, blink detection messages are
 *      recognized here. In normal operating mode (blink detection) a timer is used to start
 *      blurring the screen if there was no blink in a user defined time interval. Every incoming
 *      blink message from the RFDuino will reset this timer. If the user wants a blurring screen
 *      depends on the global setting made by control-clicking the ApplicationIcon in the menubar.
 *      <p>
 *      Based on the BLE-Chat-Demo: https://github.com/nandev/BLE-Chat-Demo
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/17
 */
@interface BLEDeviceManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
    
    /**
     * The CoreBluetooth central manager.
     */
    CBCentralManager *manager;
    
    /**
     * The CoreBluetooth peripheral a connection is established to.
     */
    CBPeripheral *peripheral;
    
    /**
     * The last known CoreBluetooth peripheral's UUID string.
     */
    NSString *lastKnownDevice;

    /**
     * The last known CoreBluetooth peripheral a connection has been established to.
     */
    CBPeripheral *lastKnownPeripheral;
    
    /**
     * The bluetooth hardware state (turned off, not supported and so on)
     */
    NSString *hardwareState;
    
    /**
     * The state the instance of this class is currently in.
     */
    NSInteger state;

    /**
     * Boolean value that indicates whether an autoscan is desired.
     */
    bool autoScan;
    
    /**
     * Boolean value that indicates whether an autoconnect to the last known device is desired.
     */
    bool autoConnect;
    
    /**
     * CoreBluetooth characteristic for sending.
     * Stores additional information about the device.
     */
    CBCharacteristic *send_characteristic;

    /**
     * CoreBluetooth characteristic for disconnecting.
     * Stores additional information about the device.
     */
    CBCharacteristic *disconnect_characteristic;
    
    /**
     * Boolean value that indicates whether a service is loaded.
     */
    bool loadedService;
    
    /**
     * Boolean value that indicates whether a connection to a device is established.
     */
    bool isConnected;

    /**
     * Boolean value that indicates whether a calibration is ongoing.
     */
    bool isCalibrating;
    
    /**
     * Boolean value that indicates whether blurring is desired.
     */
    bool wantsBlurring;
    
    /**
     * Stores all found BLE devices.
     */
    NSMutableArray *BLEDevices;
    
    /**
     * The timer to stop time with a blink.
     */
    NSTimer *repeatingTimer;
    
    /**
     * The counter for enforced blinks.
     */
    NSUInteger enforcedBlinks;
    
    /**
     * The current user profile.
     */
    UserProfile *userProfile;
    
    /**
     * The allowed time interval without a blink.
     */
    NSUInteger noBlinkTimeInterval;
    
    /**
     * Package counter
     */
    NSUInteger packageCounter;
    
    /**
     * The battery level.
     */
    float batteryLevel;
}


/**
 * This method returns the shared instance of this singleton class.
 */
+ (id)sharedInstance;

/**
 * This method scans for Bluetooth low energy devices.
 */
- (void)scanForDevices;

/**
 * This method aborts the current scan for Bluetooth low energy devices.
 */
- (void)abortScanning;

/**
 * This method establishes a connection to the given device.
 *
 * @param   device  The device to connect to.
 */
- (void)connectToDevice:(CBPeripheral *)device;

/**
 * This method disconnects from the current device.
 */
- (void)disconnectFromDevice;

/**
 * This method sets the current user profile to the given profile by sending the profiles
 * calibration data to the device. There it is stored and used from now on until this method
 * is called again or the device is reset. The RFDuino has no possibility to nonvolatile store
 * the parameters.
 *
 * @param   profile
 *      The user profile to set.
 */
- (void)setProfile:(UserProfile *)profile;

/**
 This methods returns the current user profile.
 *
 * @return
 *      The current user profile.
 */
- (UserProfile *)getCurrentProfile;

/**
 * This method returns the enforced blinks counter.
 *
 * @return  The current counter of enforced blinks.
 */
- (NSUInteger)getEnforcedBlinks;

/**
 * This method represents a message receiver. By calling this method and passing a
 * <b>BLE_OUT_MESSAGE</b> a corresponding communication with the connected device will take
 * place. If there is addional data to send, the data has to be passed via the <code>obj</code>
 * parameter.
 *
 * @see BLE_OUT_MESSAGE
 *
 * @param   message 
 *      The outgoing message to the connected device.
 * @param   data
 *      The data to be send.
 */
- (void)communicateMessage:(BLE_OUT_MESSAGE)message withData:(NSNumber *)data;

/**
 * This method returns the connected device as a CBPeripheral object.
 *
 * @return  The connected device.
 */
- (CBPeripheral *)getConnectedDevice;

/**
 * This methods starts a calibration process with the connected device. The RFDuino will now start
 * sending calibration data.
 */
- (void)startCalibrationWithDevice;

/**
 * This methods stop a calibration process with the connected device. The RFDuino will now stop
 * sending calibration data.
 */
- (void)stopCalibrationWithDevice;

/**
 * This method is invoked when the calibration process is completed. The BLE device manager will
 * go into normal mode and, depending on whether blurring is desired, the blurring timer will
 * be started.
 */
- (void)calibrationComplete;

/**
 * This method sets the current value of whethe the user wants to have the screen blurred or not.
 *
 *  @param  blurring
 *      The new value for wantsBlurring.
 */
- (void)wantsBlurring:(BOOL)blurring;

/**
 * This method returns the connection state.
 *
 * @return  The connection state.
 */
- (bool)hasConnection;

/**
 * This methods requests the battery level. The value sent by the RFDuino is stored in batterLevel.
 */
- (void)requestBatteryLevel;

@end
