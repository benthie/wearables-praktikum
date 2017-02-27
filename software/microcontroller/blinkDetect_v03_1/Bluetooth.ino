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

// Incoming messages to RFduino
#define BLE_IN_MESSAGE_NORMAL_MODE                0x00 // Normal operation -> Send justBlinked messages.
#define BLE_IN_MESSAGE_START_CALIBRATION          0x01 // Request to send prefiltered proximity values additionally.
#define BLE_IN_MESSAGE_STOP_CALIBRATION           0x02 // Request to stop sending prefiltered proximity values.
#define BLE_IN_MESSAGE_SET_PARAMETRS              0x03 // Indicating that incoming message contains a tuning parameter value pair.
#define BLE_IN_MESSAGE_START_DEBUG                0x0E // Request to start sending debugging messages
#define BLE_IN_MESSAGE_STOP_DEBUG                 0x0F // Request to stop sending debugging messages
#define BLE_IN_MESSAGE_REQUEST_BATTERY_LEVEL      0x10 // Request battery voltage level.
#define BLE_IN_MESSAGE_RESET                      0xFF // Request system reset. Will be executet immediately.

// Outgoing Messages
#define BLE_OUT_MESSAGE_ALIVE                     0x00 // Indicating operation in normal mode.
#define BLE_OUT_MESSAGE_BLINK_DETECTED            0x01 // Indicating a just detected eye blink
#define BLE_OUT_MESSAGE_CALBIRATION_DATA          0x02 // indicating prefiltered proximity value eye blink detection data message.
#define BLE_OUT_MESSAGE_PARAMTERS_SET             0x03 // Sent after receiving last paramter allowed zeros (dirty wip)
#define BLE_OUT_MESSAGE_DEBUG                     0x0F // Followed by <data length max 255> <data> (NYI)
#define BLE_OUT_MESSAGE_REQUEST_BATTERY_LEVEL     0x10 // Indicating battery level data as float.
#define BLE_OUT_MESSAGE_ERROR_EXCEPTION           0xEE // Indicating Error or exception (NYI)
#define BLE_OUT_MESSAGE_RESET                     0xFF // Indicating start up or restart of system.

// Eye blink calibration Parameters
#define BLE_CALIBRATION_PARAMETERS_THRESH_NEG     0x10
#define BLE_CALIBRATION_PARAMETERS_THRESH_POS     0x11
#define BLE_CALIBRATION_PARAMETERS_HYSTERESIS     0x12
#define BLE_CALIBRATION_PARAMETERS_MIN_MIN        0x13
#define BLE_CALIBRATION_PARAMETERS_MAX_MAX        0x14
#define BLE_CALIBRATION_PARAMETERS_T_FALL_MIN     0x15
#define BLE_CALIBRATION_PARAMETERS_T_FALL_MAX     0x16
#define BLE_CALIBRATION_PARAMETERS_T_RISE_MIN     0x17
#define BLE_CALIBRATION_PARAMETERS_T_RISE_MAX     0x18
#define BLE_CALIBRATION_PARAMETERS_T_TOTAL_MIN    0x19
#define BLE_CALIBRATION_PARAMETERS_T_TOTAL_MAX    0x1A
#define BLE_CALIBRATION_PARAMETERS_ALLOWED_ZEROS  0x1B

// temporarily used to determine package loss.
// Counts number of sent packages during calibration
// Can be compared to number of received packages.
int packageCount = 0;

/**
 * Initialize the Bluetooth communication.
 * Set the name here.
 */
void initBLE() {
  RFduinoBLE.advertisementData = "eyeDrops_2";
  RFduinoBLE.deviceName = "eyeDrops_2";
  RFduinoBLE.begin();
  RFduinoBLE.txPowerLevel = +4;
}

/**
 * If there is data to be sent, it will be sent.
 * Such as eye blink events or calibration data.
 * 
 * If no bluetooth connected, The current information will be sent over Serial communication
 * to monitor data on computer with Processing or analyze with other software in real time.
 */
void updateBLE(boolean justBlinked) {
  if (ble_connected) {
    if (!mode_debug && !mode_calibration) {
      if (justBlinked) {
        RFduinoBLE.send(BLE_OUT_MESSAGE_BLINK_DETECTED);
      }
    } else if (mode_calibration) {
      ++packageCount;
      char* data = new char[6];
      data[0] = BLE_OUT_MESSAGE_CALBIRATION_DATA;
      memcpy(data + 1, &proxFiltered, sizeof(float));
      data[5] = justBlinked;
      RFduinoBLE.send(data, 6);
      free(data);
    }
  } else {
    Serial.print("S");
    Serial.print(proxFiltered*100, 4);
    Serial.print("\t");
    Serial.print(justBlinked);
    Serial.println();
  }
}

/**
 * Callback function for new bluetooth connection.
 * 
 * No bluetooth messages can be sent in that function.
 */
void RFduinoBLE_onConnect() {
  ble_connected = true;
  Serial.println("Connected");
}

/**
 * Callback function for stopped connection.
 */
void RFduinoBLE_onDisconnect() {
  // go back to discovery
  ble_connected = false;
  Serial.println("Disconnected");
  delay(100);
  resetSystemControlled();
}

/**
 * Callback function for incoming bluetooth messages.
 */
void RFduinoBLE_onReceive(char *data, int len) {

  // display incoming message for debgging only.
  for (int i = 0; i < len; ++i) {
    Serial.print(data[i], HEX);
    Serial.print("\t");
  }
  Serial.println();
  
  switch (data[0]) {
    case BLE_IN_MESSAGE_NORMAL_MODE:
      mode_calibration = false;
      mode_debug = false;
      delay(200); // TODO find out why needed otherwise no BLE_OUT_MESSAGE_ALIVE is sent.
      RFduinoBLE.send(BLE_OUT_MESSAGE_ALIVE);
      break;

    case BLE_IN_MESSAGE_SET_PARAMETRS:
      setParameter(data, len);
      break;

    case BLE_IN_MESSAGE_START_CALIBRATION:
      mode_calibration = true;
      packageCount = 0;
      Serial.println("Start Calibration mode");
      break;

    case BLE_IN_MESSAGE_STOP_CALIBRATION:
      mode_calibration = false;
      Serial.print("Stop Calibration mode: ");
      Serial.println(packageCount);
      break;

    case BLE_IN_MESSAGE_START_DEBUG:
      mode_debug = true;
      break;

    case BLE_IN_MESSAGE_STOP_DEBUG:
      mode_debug = false;
      break;

    case BLE_IN_MESSAGE_REQUEST_BATTERY_LEVEL: {
      char* batteryData = new char[5];
      batteryData[0] = BLE_OUT_MESSAGE_REQUEST_BATTERY_LEVEL;
      float batteryVoltage = readBatteryVoltage();
      Serial.print("Battery level: ");
      Serial.println(batteryVoltage);
      memcpy(batteryData + 1, &batteryVoltage, sizeof(float));
      RFduinoBLE.send(batteryData, 5);
      free(batteryData);
      break;
    }
    case BLE_IN_MESSAGE_RESET:
      resetSystemControlled();
    default:
#ifdef DEBUG_SERIAL
      Serial.print("ERROR BLE starting with unknown identifier: ");
      Serial.println(data[0], HEX);
#endif
      ;
  }
}

/**  
 *   Set parameter depending on specification in data[1].
 *   A paramter set request consists of a message with a length of 6 bytes
 *   <BLE_IN_MESSAGE_SET_PARAMETRS><Paramter type 0x10:0x1B> < 4 byte float>
 */
void setParameter(char *data, int len) {
  float f;
  memcpy(&f, data + 2, sizeof(float));
  Serial.print(data[0], HEX);
  Serial.print("\t");
  Serial.println(f, 5);
  switch (data[1]) {
    case BLE_CALIBRATION_PARAMETERS_THRESH_NEG:
      edgeNegThresh = f;
      break;
    case BLE_CALIBRATION_PARAMETERS_THRESH_POS:
      edgePosThresh = f;
      break;
    case BLE_CALIBRATION_PARAMETERS_HYSTERESIS:
      hyst = f;
      break;
    case BLE_CALIBRATION_PARAMETERS_MIN_MIN:
      min_min = f;
      break;
    case BLE_CALIBRATION_PARAMETERS_MAX_MAX:
      max_max = f;
      break;
    case BLE_CALIBRATION_PARAMETERS_T_FALL_MIN:
      t_fall[0] = (uint8_t)f;
      break;
    case BLE_CALIBRATION_PARAMETERS_T_FALL_MAX:
      t_fall[1] = (uint8_t)f;
      break;
    case BLE_CALIBRATION_PARAMETERS_T_RISE_MIN:
      t_rise[0] = (uint8_t)f;
      break;
    case BLE_CALIBRATION_PARAMETERS_T_RISE_MAX:
      t_rise[1] = (uint8_t)f;
      break;
    case BLE_CALIBRATION_PARAMETERS_T_TOTAL_MIN:
      t_total[0] = (uint16_t)f;
      break;
    case BLE_CALIBRATION_PARAMETERS_T_TOTAL_MAX:
      t_total[1] = (uint16_t)f;
      break;
    case BLE_CALIBRATION_PARAMETERS_ALLOWED_ZEROS:
      allowedZeros = (uint8_t)f;
      RFduinoBLE.send(BLE_OUT_MESSAGE_PARAMTERS_SET);
      break;
  }
}

