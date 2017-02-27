/**
 * @file        Protocol.h
 * @brief       Header file containing the communication protocol.
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

#import <Foundation/Foundation.h>

/**
 * @brief   This enumeration contains the byte decoded message values for outgoing BLE mesages.
 *
 * @enum    BLE_OUT_MESSAGE
 */
typedef enum BLE_OUT_MESSAGE : unsigned char {
    BLE_OUT_MESSAGE_NORMAL_MODE             = 0x00,             /*!< Normal operation. Blink detection! */
    BLE_OUT_MESSAGE_START_CALIBRATION       = 0x01,             /*!< PC wants to start a calibration (due to creating new profile). */
    BLE_OUT_MESSAGE_STOP_CALIBRATION        = 0x02,             /*!< Data acquisition completed. Tell RFDuino to stop sending calibration data. */
    BLE_OUT_MESSAGE_SET_PARAMETERS          = 0x03,             /*!< Package identifier for calibration parameters. */
    BLE_OUT_MESSAGE_CAL_PARAM_THRESH_NEG    = 0x10,             /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_CAL_PARAM_THRESH_POS,                       /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_CAL_PARAM_HYSTERESIS,                       /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_CAL_PARAM_MIN_MIN,                          /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_CAL_PARAM_MAX_MAX,                          /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_CAL_PARAM_T_FALL_MIN,                       /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_CAL_PARAM_T_FALL_MAX,                       /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_CAL_PARAM_T_RISE_MIN,                       /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_CAL_PARAM_T_RISE_MAX,                       /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_CAL_PARAM_T_TOTAL_MIN,                      /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_CAL_PARAM_T_TOTAL_MAX,                      /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_CAL_PARAM_ALLOWED_ZEROS,                    /*!< Calibration parameter. */
    BLE_OUT_MESSAGE_REQUEST_BATTERY_LEVEL   = 0x10,             /*!< Tell RFDuino to send battery level. */
    BLE_OUT_MESSAGE_START_DEBUG             = 0x0E,             /*!< Tell RFDUino to enter debug mode. */
    BLE_OUT_MESSAGE_STOP_DEBUG              = 0x0F,             /*!< Tell RFDuino to leave debug mode. */
    BLE_OUT_MESSAGE_RESET                   = 0xFF              /*!< ACK for BLE_IN_MESSAGE_NEED_RESET. */
} BLE_OUT_MESSAGE;


/**
 * @brief   This enumeration contains the byte decoded messages values for incoming BLE messages.
 *
 * @enum    BLE_IN_MESSAGE
 */
typedef enum BLE_IN_MESSAGE : unsigned char {
    BLE_IN_MESSAGE_ALIVE                    = 0x00,             /*!< ACK for BLE_OUT_MESSAGE_NORMAL_OPERATION. */
    BLE_IN_MESSAGE_BLINK_DETECTED           = 0x01,             /*!< Blink detected. */
    BLE_IN_MESSAGE_CAL_DATA                 = 0x02,             /*!< Package identifier for incoming sensor data. */
    BLE_IN_MESSAGE_PARAMETERS_SET           = 0x03,             /*!< ACK for all paramerters received. */
    BLE_IN_MESSAGE_BATTERY_LEVEL            = 0x10,             /*!< The current battery level. */
    BLE_IN_MESSAGE_DEBUG                    = 0x0F,             /*!< Sending debug data (0x0F <data length max 255> <data>). */
    BLE_IN_MESSAGE_ERROR_EXCEPTION          = 0xEE,             /*!< Error / exeption occurred. */
    BLE_IN_MESSAGE_RESET                    = 0xFF              /*!< Reset happend / always on connect --> send calibration data to RFDuino. */
} BLE_IN_MESSAGE;
