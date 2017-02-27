/**
 * MIT License
 *
 * Copyright (c) 2017 University of Freiburg im Breisgau, Germany,
 * Marlene Fiedler <fiedlerm@informatik.uni-freiburg.de>,
 * Lorenz Miething <miethinl@informatik.uni-freiburg.de>,
 * Benjamin Thiemann <benjamin.thiemann@neptun.uni-freiburg.de>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/**
 *  Pin layout:
 *    SDA GPIO 6
 *    SCL GPIO 5
 *    INT
 */

#include <Arduino.h>
#include <Wire.h>
#include <math.h>
#include "RFduinoBLE.h"


#define VCNL_ADDRESS 0x13 // I2C Address of the VCNL 4020 Sensor
#define CYCLES 200        // Buffersize for the samples and preprocessing.
#define CYCLE_TIME 5      // (in ms) time step, in which samples are obtained processed.

// Comment to deactivate Serial communication.
#define SERIAL_DEBUG

double proximity = 0;             // current proximity value
double lastProximity = 0;         // last proximity value
double ambient = 0.0;             // ambient light measurement - not used
boolean new_data = false;         // flag set true if new data obtained.
boolean mode_calibration = false; // flag if calibration data should be sent.
boolean mode_debug = false;       // flag if debugging data should be sent.
boolean ble_connected = false;    // flag to indicate that RFduino is connected via BLE.

// Blink Profile paramters (can be set via computer app)
float edgePosThresh = 0.0025;     // pos threshold for blink detection
float edgeNegThresh = -0.0035;    // neg threshold for blink detection
float hyst = 0.0002;              // not applied to zero crossing intentionally (doesn't cross all the way all the time).
float max_max = 0.02;             // everything bigger than this as maximum is ignored
float min_min = -0.02;            // everything smaller than this as minimum is ignored.
uint8_t* t_fall;                  // two values indicating min and max samples allowed for falling edge
uint8_t* t_rise;                  // two values indicating min and max samples allowed for rising edge
uint16_t* t_total;                // two values indicating min and max samples allowed for total blink duration
uint8_t allowedZeros = 4;         // allowed sample number the eye is closed during an eye blink

// Internal data structure variables
float* proxFilteredBuffer;        // CYCLES is size of buffer. Proximity value samples from that buffer are analyzed to find blinks
uint8_t iP = 0;                   // index for proxFilteredBuffer used in circular array fashion.
float proxFiltered = 0.0;         // current filtered value (with moving average filter)

// other variables
int blinkAckAmount = 10;           // send blink message multiple times to accomodate package loss.
int blinkAckCounter = 0;           // counter used to keep track how often it was sent.
unsigned long updateTime = 0;     // Last time the a value was received from the sensor.

/**
 * Arduino default setup function.
 */
void setup() {
  // not used here...// Activate pulldown for unused pins to avoid leakage currents for floating pins.
  Wire.begin(); // start I2C interface
#ifdef SERIAL_DEBUG
  override_uart_limit = true; // allow fast serial communiation while using BLE.
  Serial.begin(115200);
#endif
  init_device();
}

/**
 * Arduino default Loop function
 */
void loop() {
  if (updateVCNL4020()) {
    boolean justBlinked = detectBlinks();
    updateBLE(justBlinked | blinkAckCounter);
    if (justBlinked) {
#ifdef SERIAL_DEBUG
      Serial.println("Blinked");
#endif
      blinkAckCounter = blinkAckAmount;
    }
    if (blinkAckCounter > 0) {
      --blinkAckCounter;
    }
    // send RFduino in power saving mode until cycle time is met.
    // Seems to fuck up calibration mode some times.
    if (!RFduinoBLE.radioActive && !mode_calibration && !mode_debug) {
      // Deactivated for now. Breakes the bluetooth comunication.
      //RFduino_ULPDelay(CYCLE_TIME - (millis() - updateTime));
    }
  }
}

/**
 * Initializes the device:
 *  - Battery voltage monitoring
 *  - VCNL 4020 proximity and ambient light sensor (multiple times if needed)
 *  - Blink detection algorithm
 *  - Bluetooth Low energy communication
 */
void init_device() {  // TODO remove bugs
#ifdef SERIAL_DEBUG
  Serial.println("\nINITIALIZE DEVICE:");
#endif
  // Set initial mode.
  mode_calibration = false;
  mode_debug = false;
  ble_connected = false;

  // Initialize battery voltage monitoring.
  initBatteryVoltageMonitor();

#ifdef SERIAL_DEBUG
  Serial.print("\tVCNL4020 . . . ");
#endif

  // Init VCNL 4020. In case of failure try 256 times. Finally restart system.
  int i;
  int r = 0;  // result error code
  for (i = 0; i < 256; ++i) {
    r = initVCNL4020();
    if (r == 0)
      break;
    if (i == 255) {
#ifdef SERIAL_DEBUG
      Serial.println("MAJOR ERROR - VCNL4020 Connection issue!");
#endif
      delay(1000);
      RFduino_systemReset(); // restart RFduino and try again.
    }
    delay(20);
  }

#ifdef SERIAL_DEBUG
  Serial.print("Done with code ");
  Serial.print(r);
  Serial.print(" in ");
  Serial.print(i + 1);
  Serial.println(" iterations.");
  Serial.print("\tBlinkdetection . . . ");
#endif

  // Init the blink detection functions such as filters and initial conditions.
  initBlinkdetection();
#ifdef SERIAL_DEBUG
  Serial.println("Done.");
  Serial.print("\tInit BLE . . . ");
#endif

  // Init the bluetooth communication.
  initBLE();
#ifdef SERIAL_DEBUG
  Serial.println("Done.");
  Serial.println("Initialization Successful.");
#endif
}

/**
 * Prerform controlled system reset
 * Terminate any I2C communication
 * Terminate any bluetooth communication
 */
 void resetSystemControlled() {
  // let Wire communication bleed off before resetting device
  if (Wire.available()) {
    while (Wire.available()) {
      Wire.read();
    }
    Wire.endTransmission();
  }

  // terminate bluetooth communication
  RFduinoBLE.end();

  // restart RFduino
  RFduino_systemReset(); 
 }

