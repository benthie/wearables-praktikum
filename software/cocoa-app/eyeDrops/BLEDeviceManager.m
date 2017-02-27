/**
 * @file        BLEDeviceManager.m
 * @brief       Implementation file containing the Bluetooth low energy device manager class.
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

#import "BLEDeviceManager.h"


@implementation BLEDeviceManager

/*
 * This method returns the shared instance of this singleton class.
 */
+ (instancetype)sharedInstance {
    
    // The static shared instance.
    static BLEDeviceManager *sharedInstance = nil;
    
    // Singleton token.
    static dispatch_once_t onceToken;
    
    // Check if token already existing.
    dispatch_once(&onceToken, ^{
        
        // Create instance once.
        sharedInstance = [[BLEDeviceManager alloc] init];
        
    });
    
    // Return the single instance.
    return sharedInstance;
}

/*
 Initialize the BLE Device Manager. All variables are set here.
 */
- (id)init {
    
    // Call super contrusctor.
    self = [super init];
    
    // Initialize the manager's state.
    state = CON_STATE_BOOT_UP;
    
    // Initialize bluetooth hardware state.
    hardwareState = @"Bluetooth state unknown";
    
    // Create container for found bluetooth devices.
    BLEDevices = [NSMutableArray array];
    
    // Set user profile to nil until one has been selected.
    userProfile = nil;
    
    // Set last known device to saved value.
    lastKnownDevice = [[Settings sharedInstance] lastKnownDevice];
    
    // Initialize setting variables.
    autoScan        = [[Settings sharedInstance] autoScan];
    autoConnect     = [[Settings sharedInstance] autoConnect];
    
    // Initialize status variables.
    wantsBlurring   = false;
    loadedService   = false;
    isConnected     = false;
    isCalibrating   = false;
    
    // Initialize package counter.
    packageCounter = 0;
    
    // Create CoreBluetooth Central Manager.
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // Initialize enforced blinks.
    enforcedBlinks = 0;
    
    // Initialize allowed time interval without a blink.
    noBlinkTimeInterval = 4;
    
    // Return the instance.
    return self;
}


#pragma mark
#pragma mark - Hardware check methods.

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) hardwareIsBLECapable {
    
    switch ([manager state])
    {
        case CBCentralManagerStateUnsupported:
            hardwareState = @"BLE not supported";
            break;
        case CBCentralManagerStateUnauthorized:
            hardwareState = @"No BLE permission";
            break;
        case CBCentralManagerStatePoweredOff:
            hardwareState = @"Bluetooth is turned off";
            break;
        case CBCentralManagerStatePoweredOn:
            hardwareState = @"ON";
            return TRUE;
        case CBCentralManagerStateUnknown:
            hardwareState = @"Bluetooth status unknown";
        default:
            return FALSE;
            
    }
    
    return FALSE;
}

#pragma mark
#pragma mark - Bluetooth Scanning methods.

/*
 * Scans for devices.
 */
- (void)scanForDevices {
    
    // Check if there is already a connection.
    if (peripheral) {
        
        // And if so, disconnect the currently connected device.
        [manager cancelPeripheralConnection:peripheral];
    }
    
    // Without any connected device check if hardware is still capale.
    if ( [self hardwareIsBLECapable] ) {
        
        // And then start scaning.
        [self startScan];
    }
}

/*
 * Cancels the current scanning process.
 */
- (void)abortScanning {
    
    // Stop scanning.
    [self stopScan];
    
    // Get all peripherals that were found so far.
    NSMutableArray *peripherals = [self mutableArrayValueForKey:@"BLEDevices"];
    
    // Update the Menu.
    [[[NSApplication sharedApplication] delegate] performSelector:@selector(updateMenuWithFoundDevices:) withObject:peripherals];
}

/*
 * Request CBCentralManager to scan for BLE peripherals using service UUID 0x2220
 */
- (void) startScan {
    
    [manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2220"]] options:nil];
}

/*
 * Request CBCentralManager to stop scanning for heart rate peripherals
 */
- (void) stopScan {
    
    [manager stopScan];
}


#pragma mark
#pragma mark - Bluetooth Connection methods.

/*
 * Returns the connection state.
 */
- (bool)hasConnection {
    return isConnected;
}

/*
 * Connects to the given device.
 */
- (void)connectToDevice:(CBPeripheral *)device {
    
    NSLog(@"BLE Manager: connect to device %@", device);
    
    // Save device identifier as last known device.
    lastKnownDevice = [[device identifier] UUIDString];
    
    // And change the settings appropriately.
    Settings *settings = [Settings sharedInstance];
    settings.lastKnownDevice = lastKnownDevice;
    
    // No device connected yet, connect to the given device.
    if (!isConnected) {
        
        NSLog(@"BLE Manager: no device connected so far");
        [[[NSApplication sharedApplication] delegate] performSelector:@selector(updateMenuWithConnectionAttempt)];
        
        [self stopScan];
        [manager connectPeripheral:device options:nil];
        
        peripheral = device;
        
    } else {
        
        // The selected device is already connected, so disconnect it.
        if (peripheral == device) {
            NSLog(@"Disconnect device: %@", [device name]);
            [[[NSApplication sharedApplication] delegate] performSelector:@selector(updateMenuWithDisconnection:) withObject:device];
            [manager cancelPeripheralConnection:peripheral];
            peripheral = nil;
        }
        // The selected device is not connected, so disconnect the current
        // one and connect to the selected.
        else {
            NSLog(@"Change connection from: %@ to: %@", [peripheral name], [device name]);
            [manager cancelPeripheralConnection:peripheral];
            [manager connectPeripheral:device options:nil];
            peripheral = device;
        }
    }
}

/*
 * Disconnects from the given device.
 */
- (void)disconnectFromDevice {
    
    // Stop blurring in case screen is blurred right now.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EDNotificationStopBlurring" object:nil];
    
    // Stop running timer.
    [self stopTimer];
    
    // [self communicateMessage:BLE_OUT_MESSAGE_RESET withData:nil];
    [manager cancelPeripheralConnection:peripheral];
    
    // Reset the state.
    state = CON_STATE_BOOT_UP;
}

/*
 * Returns the connected device.
 */
- (CBPeripheral *)getConnectedDevice {
   
    return peripheral;
}

/*
 * Connects to the last known device.
 */
- (void)connectToLastKnownDevice {
    
    // Check if there is a last known device.
    if (lastKnownDevice != nil) {
   
        // Check if last known device is currently available.
        for (CBPeripheral *aPeripheral in BLEDevices) {
            
            // If device is available, connect to it.
            if ( [[[aPeripheral identifier] UUIDString] isEqualToString:lastKnownDevice] ) {
                [self connectToDevice:aPeripheral];
            }
        }
    }
}


#pragma mark
#pragma mark - CBCentralManager delegate methods

/*
 Invoked whenever the central manager's state is updated.
 */
- (void) centralManagerDidUpdateState:(CBCentralManager *)central {

    // Check hardware again to update the state message.
    [self hardwareIsBLECapable];
    
    // Then update the menu content to the new bluetooth state.
    [[[NSApplication sharedApplication] delegate] performSelector:@selector(updateMenuWithNewBluetoothStatus:) withObject:hardwareState];
    
    // Automatically scan for new devices if option is selected.
    if ( [hardwareState isEqualToString:@"ON"] && autoConnect ) {
        [self startScan];
    }    
}

/*
 Invoked when the central discovers BLE peripheral while scanning.
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSMutableArray *peripherals = [self mutableArrayValueForKey:@"BLEDevices"];
    if( ![BLEDevices containsObject:aPeripheral] ) {
        
        [peripherals addObject:aPeripheral];
        
        // Update the Menu
        [[[NSApplication sharedApplication] delegate] performSelector:@selector(updateMenuWithFoundDevices:) withObject:peripherals];
        
        // Show user Notification pop up.
        [self showUserNotification:USER_NOTIFICATION_DEVICE_FOUND withInfo:nil];
    
        // DEBUG: Print found devices
        NSLog(@"Devices found: %@", BLEDevices);
    }
    
    // Automatically connect to last known device if option is selected.
    if(autoConnect) {
        [self connectToLastKnownDevice];
    }
}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"Retrieved peripheral: %lu - %@", [peripherals count], peripherals);
    // NSMutableArray *peripherals = [self mutableArrayValueForKey:@"BLEDevices"];
    // Update the Menu
    [[[NSApplication sharedApplication] delegate] performSelector:@selector(updateMenuWithFoundDevices:) withObject:peripherals];
    
    [self stopScan];
    
    /* If there are any known devices, automatically connect to it.*/
    if([peripherals count] >=1)
    {
        
        // Automatically connect to last known device if option is selected.
        if(autoConnect) {
            [self connectToLastKnownDevice];
        }
        
        //change connectButton function to disconnect
//        [self.connectButton setTitle:@"Disconnect"];
        
//        peripheral = [peripherals objectAtIndex:0];
//        [manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral {
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
    
    NSLog(@"Now we want to get the connected device checked in the menu");
    
    // Connection established: mark device in menu as connected
    [[[NSApplication sharedApplication] delegate] performSelector:@selector(updateMenuWithConnection:) withObject:aPeripheral];
    
    // Show user Notification pop up.
    [self showUserNotification:USER_NOTIFICATION_DEVICE_CONNECTED withInfo:aPeripheral.name];
    
    state = CON_STATE_BOOT_UP;
    
    isConnected = true;
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
    // change connectButton function to connect
    //[self.connectButton setTitle:@"Connect"];
    isConnected = false;
    loadedService = false;
    
    //forget about any peripherals
    if (peripheral) {
        [peripheral setDelegate:nil];
        peripheral = nil;
    }
    
    // Connection shut down: mark device in menu as disconnected
    [[[NSApplication sharedApplication] delegate] performSelector:@selector(updateMenuWithDisconnection:) withObject:aPeripheral];
    
    // Show user Notification pop up.
    [self showUserNotification:USER_NOTIFICATION_DEVICE_DISCONNECTED withInfo:aPeripheral.name];
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    //    change connectButton function to connect
    //    [self.connectButton setTitle:@"Connect"];
    
    //forget about any peripherals
    if (peripheral) {
        
        [peripheral setDelegate:nil];
        
        peripheral = nil;
    }
}

#pragma mark
#pragma mark - CBPeripheral delegate methods

/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    
    for (CBService *aService in aPeripheral.services) {
        
        NSLog(@"Service found with UUID: %@", aService.UUID);
        
        /* RFduino Service */
        // @"2221" receive
        // @"2222" send
        // @"2223" disconnect
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"2220"]]) {
            
            NSArray *characteristics = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"2221"], [CBUUID UUIDWithString:@"2222"], [CBUUID UUIDWithString:@"2223"], nil];
            [aPeripheral discoverCharacteristics:characteristics forService:aService];
        }
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"2220"]]) {
            
            loadedService = true;
            
            NSLog(@"Service loaded with UUID: %@", service.UUID);
            
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2221"]]) {
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2222"]]) {
                    send_characteristic = characteristic;
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2223"]]) {
                    disconnect_characteristic = characteristic;
                }
            }
            
        }
    }
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            /* Read device name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Name Characteristic");
            }
        }
    }
    
    NSLog(@"Send a BLE_OUT_MESSAGE_NORMAL_MODE");
    
    // Connection completely established. Now send a "normal mode" to
    // signalize the device that PC is ready for communictation.
    [self communicateMessage:BLE_OUT_MESSAGE_NORMAL_MODE withData:nil];
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 --> Data received from RFD.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // Data was received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2221"]]) {
        
        // Handle incoming data if no error occurred
        if( (characteristic.value)  || !error ) {
            
            // NSLog(@"Incoming data: %@", characteristic.value);
            [self handleIncomingData:characteristic.value];

        }
    }
    /* Value for device Name received */
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
    {
        NSString * deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Device Name = %@", deviceName);
    }
    
}

/*
 Invoked when you write data to a characteristic’s value.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    // Print the error if one occurred.
    if (error != nil) {
        NSLog(@"Data written. Error: %@", [error userInfo]);
    }
    // Else nothing happends here.
}


#pragma mark
#pragma mark - Methods for communication with connected device

/*
 * Sends data to the connected device.
 */
- (void)send:(NSData *)data
{
    NSInteger max_data = 20;
    
    if (! loadedService) {
        @throw [NSException exceptionWithName:@"sendData" reason:@"please wait for ready callback" userInfo:nil];
    }
    
    if ([data length] > max_data) {
        @throw [NSException exceptionWithName:@"sendData" reason:@"max data size exceeded" userInfo:nil];
    }
    
    //    [peripheral writeValue:data forCharacteristic:send_characteristic type:CBCharacteristicWriteWithoutResponse];
    [peripheral writeValue:data forCharacteristic:send_characteristic type:CBCharacteristicWriteWithResponse];
    //NSLog(@"rfduino send data");
}

/*
 * Send the given message with the given data to the connected device.
 */
- (void)communicateMessage:(BLE_OUT_MESSAGE)message withData:(NSNumber *)data {
    
    // No data to send means we just have to communicate one byte.
    if (data == nil) {
        
        // NSLog(@"Message to send is: %i", message);
        
        // Send data (just the given message)
        [self send:[[NSData alloc] initWithBytes:&message length:sizeof(message)]];
    } else {
        
        float floatData = [data floatValue];
        
        // Create byte buffer for message indentifier plus given data
        unsigned char byteBuffer[2 + sizeof(floatData)];
        byteBuffer[0] = BLE_OUT_MESSAGE_SET_PARAMETERS;
        byteBuffer[1] = message;
        memcpy(byteBuffer+2, &floatData, sizeof(floatData));
        
        NSData *data =[[NSData alloc] initWithBytes:byteBuffer length:sizeof(byteBuffer)];
        
        NSLog(@"Data to send looks like: %@", [data description]);
        
        // Send data
        [self send:data];
    }
}

/*
 * Inoked when data came in. The corresponding message and the data bytes will be
 * extracted. This method will control the states the App is in.
 */
- (void)handleIncomingData:(NSData *)incomingData {
    
    // The incoming message identifier.
    unsigned char message;
    
    // Extract first byte as message identifier into variable 'message'.
    [incomingData getBytes:&message length:1];
    
    // Handle the message.
    switch (message) {
            
        case BLE_IN_MESSAGE_BLINK_DETECTED:
            
            if (state == CON_STATE_NORMAL_MODE) {
                
                // A blink was detected. Reset the timer. FIRST!!! Otherwise timer could expire and start blurring again
                // right after blurring was stopped due to a blink.
                [self resetTimer];
                
                // Stop blurring even if it is off. Does not matter. We have to be fast!
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EDNotificationStopBlurring" object:nil];
                
                NSLog(@"BLINK DETECTED");
            }
            
            if (state == CON_STATE_BLURRING) {
                
                // Screen is currently blurred and the releasing blink was detected.
                // So clear the screen ...
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EDNotificationStopBlurring" object:nil];
                
                // ... and restart the timer.
                [self startTimer];
                
                state = CON_STATE_NORMAL_MODE;
            }
            
            break;
            
        case BLE_IN_MESSAGE_ALIVE:
            
            // Here should:
            // a) happen the boot up and initialization procedure and
            // b) the handling of general alive messages.
            
            NSLog(@"ALIVE");
            
            // If freshly booted, set profile if there exists one.
            if (state == CON_STATE_BOOT_UP) {
                
                // Check for valid user profile.
                if (userProfile != nil) {
                    
                    // Send the profile to the RFDuino.
                    [self setProfile:userProfile];
                    
                } else {
                    NSLog(@"NO USER PROFILE HAS BEEN SET YET!!!");
                }
            }
            
            // If general alive message appears in normal mode react to taht.
            if (state == CON_STATE_NORMAL_MODE) {
                
                // Maybe start a timer and detect when the device crashed.
            }
            
            break;
            
        case BLE_IN_MESSAGE_CAL_DATA:
            
            // Handle incoming calibration data. There are incoming data packages as long as
            // the calibration process is running. The length depends on the user settings.
            // We have extract the data (a float for the derivative of the sensor data and an
            // bollean value for blinked/not blinked). Message consists of 1 byte for
            // identifier and 5 bytes for the current calibraiton data --> total 6 bytes.
            
        {
            packageCounter = packageCounter + 1;
            NSLog(@"Package counter: %li", packageCounter);
            
            // Cut the first byte off and collect the rest as one calibration parameter.
            NSData *data  = [incomingData subdataWithRange:NSMakeRange(1, 5)];
            //NSData *blink = [incomingData subdataWithRange:NSMakeRange(5, 5)];
            
            // NSLog(@"Cutted data has length: %i", [data length]);
            
            if (state != CON_STATE_CALIBRATION) {
            
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EDNotifictaionCalibrationData" object:data];
            }
            
            // Send data to the CalibrationSheet 
            // blink = data;
        }
            
            break;
            
        case BLE_IN_MESSAGE_PARAMETERS_SET:
            
            // Calibration parameters successfully set.
            // Now set the corresponding state and start blurring if desired.
            
            packageCounter = 0;
            
            if (state == CON_STATE_NORMAL_MODE) {
                
                // Finally set RFD to normal mode.
                [self communicateMessage:BLE_OUT_MESSAGE_NORMAL_MODE withData:nil];
            }
            
            if (state == CON_STATE_BOOT_UP) {
                
                // Go into normal mode.
                state = CON_STATE_NORMAL_MODE;
                
                // Finally set RFD to normal mode.
                [self communicateMessage:BLE_OUT_MESSAGE_NORMAL_MODE withData:nil];
            }
            
            [[[NSApplication sharedApplication] delegate] performSelector:@selector(updateMenuWithProfiles)];
            
            // Check if blurring is enabled.
            if (wantsBlurring) {
                
                // Start the timer.
                [self startTimer];
            }
            
            break;
            
        case BLE_IN_MESSAGE_BATTERY_LEVEL:
            
            // Battery level data is incoming. Store it to batteryLevel.
            
            NSLog(@"BATTERY LEVEL");
            [[incomingData subdataWithRange:NSMakeRange(1, 4)] getBytes:&batteryLevel length:sizeof(float)];
            // NSLog(@"battery level in ble dev manager = %f", batteryLevel);
        {
            Settings *settings = [Settings sharedInstance];
            settings.batteryLevel = batteryLevel;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EDNotificationBatteryLevelChanged" object:nil];
        }
            break;
            
        case BLE_IN_MESSAGE_DEBUG:
            NSLog(@"DEBUG");
            break;
            
        case BLE_IN_MESSAGE_ERROR_EXCEPTION:
            NSLog(@"ERROR EXCEPTION");
            break;
            
        case BLE_IN_MESSAGE_RESET:
            NSLog(@"RESET");
            
            break;
            
        default:
            break;
    }
}

/*
 * Ask RFDuino for battery level.
 */
- (void)requestBatteryLevel {
    if (isConnected) {
        [self communicateMessage:BLE_OUT_MESSAGE_REQUEST_BATTERY_LEVEL withData:nil];
    }
}

/*
 * Change in wantsBlurring. Enable timer if normal mode is active and a device is connected.
 */
- (void)wantsBlurring:(BOOL)blurring {
    
    // Set new value.
    wantsBlurring = blurring;
    
    if (CON_STATE_NORMAL_MODE && isConnected) {
        if (wantsBlurring) {
            [self startTimer];
        }
    }
    
    if (!wantsBlurring) {
        
        // Stop blurring in case screen is blurred right now.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EDNotificationStopBlurring" object:nil];

        // Stop timer
        [self stopTimer];
    }
}

/*
 * Return the current user profile.
 */
- (UserProfile *)getCurrentProfile {
    return userProfile;
}

/*
 * Return the enforced blinks counter.
 */
- (NSUInteger)getEnforcedBlinks {
    return enforcedBlinks;
}

/*
 * Sends the given profile's calibration data to the connected device.
 */
- (void)setProfile:(UserProfile *)profile {
    
    // For initialization purposes, set the profile to work with but do not flash it.
    if (!isConnected) {
        
        userProfile = profile;
        
    // If connected, change the profile and send calibration data to RFDuino.
    } else {
        
         // NSLog(@"User profile name: %@", [profile getName]);
         // [self printStatus];
        
        // Set the user profile.
        userProfile = profile;
        
        // Reset enforced blink counter.
        enforcedBlinks = 0;
        
        // Set first parameter so we can iterate over the rest.
        unsigned char firstParameter = BLE_OUT_MESSAGE_CAL_PARAM_THRESH_NEG;
        
        // Now send all the calibration parameters.
        for (int i=0; i<12; i++) {
            
            // Send current calibration parameter to RFD.
            [self communicateMessage:(firstParameter+i) withData:[profile getParameter:i]];
        }
    }
}

/*
 * Start a calibration process.
 */
- (void)startCalibrationWithDevice {
    
    [self stopTimer];
    
    state = CON_STATE_CALIBRATION_INCOMING_DATA;
    
    [self printStatus];
    
    NSLog(@"Send calibration message to device");
    
    if (isConnected) {
        [self communicateMessage:BLE_OUT_MESSAGE_START_CALIBRATION withData:nil];
    }
}

/*
 * Stop the calibration process.
 */
- (void)stopCalibrationWithDevice {
    
    state = CON_STATE_CALIBRATION;
    
    [self printStatus];
    
    NSLog(@"Calibration data sent, now calculate parameters");
    
    if (isConnected) {
        [self communicateMessage:BLE_OUT_MESSAGE_STOP_CALIBRATION withData:nil];
        
        // RFDUINO in NORMAL_MODE
    }
    
    NSLog(@"Package counter: %li", packageCounter);
    //packageCounter = 0;
}

/*
 * Go to normal mode.
 */
- (void)calibrationComplete {
    [self printStatus];
    if (isConnected) {
        state = CON_STATE_NORMAL_MODE;
        [self communicateMessage:BLE_OUT_MESSAGE_NORMAL_MODE withData:nil];
    }
}


#pragma mark
#pragma mark - Timer methods

/*
 * Start the timer.
 */
- (void)startTimer {
    
    // Create new timer (1 additional second)
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[[Settings sharedInstance] blinkTimerValue]
                                                      target:self selector:@selector(longTimeNoBlink:)
                                                    userInfo:@{ @"StartDate"  : [NSDate date]}
                                                     repeats:YES];
    // Start new timer.
    repeatingTimer = timer;
}

/*
 * Stop the timer.
 */
- (void)stopTimer {
    
    // Stop running timer.
    [repeatingTimer invalidate];
    
    // Delete the timer.
    repeatingTimer = nil;
}

/*
 * Reset the timer.
 */
- (void)resetTimer {
    
    if (repeatingTimer && isConnected) {
    
        // Stop running timer.
        [repeatingTimer invalidate];
        
        // Create new timer.
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[[Settings sharedInstance] blinkTimerValue]
                                                          target:self selector:@selector(longTimeNoBlink:)
                                                        userInfo:@{ @"StartDate"  : [NSDate date]}
                                                         repeats:YES];
        // Start new timer.
        repeatingTimer = timer;
    }
}

/*
 * Method to be called when timer expires.
 */
- (void)longTimeNoBlink:(NSTimer*)theTimer {
    
    // NSDate *startDate = [[theTimer userInfo] objectForKey:@"StartDate"];
    enforcedBlinks++;
    // NSLog(@"Timer started on %@", startDate);
    
    // Update tooltip.
    [[[NSApplication sharedApplication] delegate] performSelector:@selector(updateToolTip)];
    
    // Start blurring.
    [[[NSApplication sharedApplication] delegate] performSelector:@selector(startBlur)];
    
    // Stop running timer.
    [self stopTimer];
    
    // Set blur flag.
    state = CON_STATE_BLURRING;
}


#pragma mark
#pragma mark - User Notification methods

/*
 * Shows a user notification with the given type and info string.
 */
- (void)showUserNotification:(USER_NOTIFICATION)type withInfo:(NSString *)info {
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.soundName = nil;
    
    switch (type) {
            
        case USER_NOTIFICATION_DEVICE_FOUND:
            NSLog(@"NOTIFICATION: New devices discoverd");
            notification.title = [NSString stringWithFormat:@"New devices discoverd"];
            break;
            
        case USER_NOTIFICATION_DEVICE_CONNECTED:
            NSLog(@"NOTIFICATION: Device connected");
            notification.title = [NSString stringWithFormat:@"Device connected"];
            notification.informativeText = [NSString stringWithFormat:@"Successfully connected to %@", info];
            break;
            
        case USER_NOTIFICATION_DEVICE_DISCONNECTED:
            NSLog(@"NOTIFICATION: Device disconnected");
            notification.title = [NSString stringWithFormat:@"Device disconnected"];
            notification.informativeText = [NSString stringWithFormat:@"Successfully disconnected from %@", info];
            break;
        
        case USER_NOTIFICATION_PROFILE_SET:
            NSLog(@"NOTIFICATION: profile uploaded");
            notification.title = [NSString stringWithFormat:@"Profile uploaded"];
            notification.informativeText = [NSString stringWithFormat:@"Profile %@ successfully set.", info];
            break;
        
        case USER_NOTIFICATION_CALIBRATION_DONE:
            NSLog(@"NOTIFICATION: calibration completed");
            notification.title = [NSString stringWithFormat:@"Calibration completed."];
            break;
        
        case USER_NOTIFICATION_BLE_NOT_SUPPORTED:
            NSLog(@"NOTIFICATION: BLE not supported");
            notification.title = [NSString stringWithFormat:@"BLE not supported"];
            break;
            
        default:
            break;
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

/*
 * Debug function. Used to print the current connection status.
 */
- (void)printStatus {
    
    switch (state) {
            
        case CON_STATE_BOOT_UP:
            NSLog(@">>> BOOT UP");
            break;
        case CON_STATE_NORMAL_MODE:
            NSLog(@">>> NORMAL MODE STATE");
            break;
        case CON_STATE_CALIBRATION:
            NSLog(@">>> CALIBRAION STATE");
            break;
        case CON_STATE_CALIBRATION_INCOMING_DATA:
            NSLog(@">>> CALIBRATION INCOMING DATA");
            break;
        case CON_STATE_SETTING_PROFILE:
            NSLog(@">>> SETTING PROFILE");
            break;
        default:
            NSLog(@">>> DEFAULT STATE ???");
            break;
    }
}

@end
