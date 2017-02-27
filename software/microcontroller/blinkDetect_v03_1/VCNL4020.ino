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

boolean isContinuous = false;

uint8_t initVCNL4020() {
  Wire.beginTransmission(VCNL_ADDRESS);
  Wire.write(0x83); // IR LED current register
  Wire.write(B00001010); // set led_current = val*10mA max 200mA
  delay(20); // TODO can be removed or reduced in final version
  Serial.print(".");
  Wire.write(0x82); // Proximity rate register
  Wire.write(B00000111); // set prox_rate to 250 samples /s
  delay(20); // TODO can be removed or reduced in final version
  Serial.print(",");
  Wire.write(0x84); // Ambient light register
  Wire.write(B10011101); // cont_conv, als_rate= 10/s, auto_offset_comp, 32 conversions/sample
  delay(20);
  Serial.print("-");
  Wire.write(0x80);
  Wire.write(B00001000); // prox_od: Just enable the on demand measurements
  uint8_t transmitResult = Wire.endTransmission();
  setContinuousMode(true);
  return transmitResult;
}

void setContinuousMode(boolean isCont) {
  if (isCont) {
    Wire.beginTransmission(VCNL_ADDRESS);
    Wire.write(0x82); // Proximity rate register
    Wire.write(B00000111); // set prox_rate to 250 samples /s
    delay(50); // TODO can be removed or reduced in final version
    Wire.write(0x84);
    Wire.write(B10001010); // cont mode, 1s/s, auto offset enabled, 4 conv averaging
    Wire.endTransmission();
    delay(50);
    Wire.beginTransmission(VCNL_ADDRESS);
    Wire.write(0x80);
    Wire.write(B10011000); // als_en, prox_en, selftimed_en
    Wire.endTransmission();
    delay(100);
    isContinuous = true;
  } else {
    Wire.beginTransmission(VCNL_ADDRESS);
    Wire.write(0x80);
    Wire.write(B00001000); // prox_od: Just enable the on demand measurements
    Wire.endTransmission();
    delay(100);
    trigger_prox_od_VCNL4020();
    isContinuous = false;
  }
}


/**
 * Updates the measurement.
 * Returns true if new data were obtained succesfully.
 * If last measurement is older than CYCLE_TIME,
 * new values are read and a new measurment is triggered.
 * If not nothing happens and false is returned.
 */
boolean updateVCNL4020() {
  boolean new_data = false;
  if (millis() - updateTime > CYCLE_TIME) {
    if (isContinuous) {
      if (newVCNL4020_data()) {
        // read measurements
        Wire.beginTransmission(VCNL_ADDRESS);
        Wire.write(0x85); // amb light results and prox results following.
        Wire.endTransmission();
        Wire.requestFrom(VCNL_ADDRESS, 4);
        if (Wire.available()) {
          ambient = (double)(Wire.read()<<8 | Wire.read()) / 4;
          proximity = exp(log(68000.0 / (uint16_t)(Wire.read() << 8 | Wire.read())) / 1.765);
        }
        trigger_od_VCNL4020();
        new_data = true;
      } else {
        trigger_od_VCNL4020();
      }
    } else {
      if (newVCNL4020_prox_data()) {
        // read old measurement.
        proximity = getVCNL4020Proximity_mm();
        // Initiate new measurement.
        trigger_prox_od_VCNL4020();
      } else {
        trigger_prox_od_VCNL4020();
      }
      new_data = true;
    }
  }
  return new_data;
}

/**
 * Returns true if new prox data are available and can be read and false otherwise.
 */
boolean newVCNL4020_prox_data() {
  boolean isNewData = false;
  Wire.beginTransmission(VCNL_ADDRESS);
  Wire.write(0x80);
  Wire.endTransmission();
  Wire.requestFrom(VCNL_ADDRESS, 1);
  if (Wire.available()) {
    char val = Wire.read();
    isNewData = (val & B00100000);
  }
  while(Wire.available()) {
    Wire.read();
  }
  return isNewData;
}

/**
 * Returns true if new data (prox and amb) are available and can be read and false otherwise.
 */
boolean newVCNL4020_data() {
  boolean isNewData = false;
  Wire.beginTransmission(VCNL_ADDRESS);
  Wire.write(0x80);
  Wire.endTransmission();
  Wire.requestFrom(VCNL_ADDRESS, 1);
  if (Wire.available()) {
    char val = Wire.read();
    isNewData = (val & B00100000 && val & B01000000);
  }
  while(Wire.available()) {
    // remove any stuck data.
    Wire.read();
  }
  return isNewData;
}

/**
 * triggers a new proximity measurement for the VCNL4020
 */
void trigger_prox_od_VCNL4020() {
  Wire.beginTransmission(VCNL_ADDRESS);
  Wire.write(0x80);
  Wire.write(B00001000); // als_od, prox_od als_en prox_en ( od = on demand)
  Wire.endTransmission();
  updateTime = millis();
}

/**
 * triggers a new set of prox and amb light measurements for the VCNL4020
 */
void trigger_od_VCNL4020() {
  Wire.beginTransmission(VCNL_ADDRESS);
  Wire.write(0x80);
  Wire.write(B00011000); // als_od, prox_od ( od = on demand)
  Wire.endTransmission();
  updateTime = millis();
}

/**
 * gets the raw data from the VCNL4020 and returns them normalized to mm.
 */
double getVCNL4020Proximity_mm() {
  
  double proximity = -1;
  Wire.beginTransmission(VCNL_ADDRESS);
  Wire.write(0x87); // Proximity measurement result register
  Wire.endTransmission();
  Wire.requestFrom(VCNL_ADDRESS, 2);
  if (Wire.available()) {
    // should be converted to mm according to:
    // https://forums.adafruit.com/viewtopic.php?f=19&t=89699
    proximity = exp(log(68000.0 / (uint16_t)(Wire.read() << 8 | Wire.read())) / 1.765);
//    result = Wire.read() << 8 | Wire.read();
  }
  Wire.endTransmission();
  return proximity;
}
