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
 * Initialize the analog reading.
 */
void initBatteryVoltageMonitor() {
  analogReference(VBG);         // Sets the Reference to 1.2V band gap           
  analogSelection(VDD_1_3_PS);  // Selects VDD with 1/3 prescaling as the analog source
}


/**
 * Read the current supply voltage of the RFduino.
 * The 1.2V analog reference is used in combination with a prescaler to determine the supply voltage
 */
float readBatteryVoltage() {
  // the pin has no meaning, it uses VDD pin
  return analogRead(4) * (3.6 / 1023.0); // convert read value to meaningfull voltage.
}
