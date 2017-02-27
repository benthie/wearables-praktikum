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

// General remark: One could consider doing the averaging with the raw data instead of the mm data.
//                 Result is not equal since the moving average is linear but the conversion in mm
//                 is not. Need to look into this.


// Moving average filter parameters
// maBufferSize has to be less than CYCLES otherwise the behaviour might be unpredictable.
#define MA_BUFFER  16
uint8_t iMa = 0;    // index for the moving average buffer. (circular array style).
double* maBuffer;   // moving average buffer
double maSum = 0;   // temporary moving average sum.

// Filtered data parameters
// Do everything with a max sample buffer size of 255 to be more efficient on the 8bit processor.
#define PROX_FILTERED_BUFFER 200

// i<Name> indicates an index for the sample buffer. Usually last occurence of certain event / condition.
int iZero = 0;            // last encountered zero crossing
int iZeroPrev = 0;        // Previous zero crossing
int zeroCount = 0;        // Counter for zero crossings. Will be reset more often than not. Will not overflow.
int iEdgeRisingPos = 0;   // Last encountered positive rising edge.
int iEdgeFallingPos = 0;  // Last encountered positive falling edge.
int iEdgeRisingNeg = 0;   // Last encountered negative rising edge.
int iEdgeFallingNeg = 0;  // Last encountered negative falling edge.
int iMax = 0;             // Index of last encountered maximum value above positive thresholds
int iMin = 0;             // Index of last encountered minimum value below negative thresholds
double maxVal = 0;        // Maximal valid maximum value.
double minVal = 0;        // Minimal valid minimum value.
int8_t edgeType = 0;      // updated every cycle.
//  1 means falling pos edge after rising pos edge detected
// -1 means rising neg edge after falling neg edge detected
// 0 otherwise.

// Initial conditions:
boolean lessZero = false;
boolean abovePos = false;
boolean belowNeg = false;


// BLINK DETECTION CONDITIONS
// blinkLevel is the three step procedure:
// blinkLevel=0 -> No blink matching in progress.
// blinkLevel=1 -> negative falling and rising edge detected and min value meets conditions.
// blinkLevel=2 -> poitive rising and falling edge detected, max value meets conditions conditions depending on min conditions.
// blinkLevel=3 -> overall length meets conditions.
uint8_t blinkLevel = 0;   // indicating blink level as described above.
uint8_t iBlinkLevel = 0;  // index of blinkLevel change
int lengths[] = {0,0,0};  // lengths of ongoing eye blink fragments.

/**
 * Initialize the eye blink detection algorithm.
 * Set certatin conditions and set initial values.
 */
void initBlinkdetection() {
  proxFilteredBuffer = new float[PROX_FILTERED_BUFFER];
  maBuffer = new double[MA_BUFFER];
  
  for (int i = 0; i < PROX_FILTERED_BUFFER; ++i) {
    proxFilteredBuffer[i] = 0;
  }
  
  for (int i = 0; i < MA_BUFFER; ++i) {
    maBuffer[i] = 0;
  }
  
  edgePosThresh = 0.0025; // need to have a look at the actual data!
  edgeNegThresh = -0.003;
  hyst = 0.0002; // not applied to zero crossing intentially (doesn't cross all the way all the time).
  max_max = 0.02; // everything bigger than this as maximum is ignored
  min_min = -0.02; // everything smaller than this as minimum is ignored.
  t_fall = new uint8_t[2]{4, 30};
  t_rise = new uint8_t[2]{6, 35};
  t_total = new uint16_t[2]{30, 105};
  allowedZeros = 4;
  iP = 0; // index for prox data
  proxFiltered = 0.0;
}

/**
 * Detect the blink itself.
 * 1. Get the differential value to remove DC offset.
 * 2. Apply a moving average filter on the differential values
 *    Through try and error: a moving average filter with a depth of 16 seemed to work best.
 * 3. Find zero crossings
 *    Analyse the values compared to the one before to detect a zero crossing.
 * 4. Find rising and falling edges
 * 5. Evaluate current edge and zero crossing situation
 */
boolean detectBlinks() {
  boolean justBlinked = false;
  
  // 1. Get the differential value to remove DC offset.
  double diff_prox = -lastProximity + proximity;

  // 2. Apply a moving average filter on the differential values
  maSum -= maBuffer[iMa];
  maBuffer[iMa] = diff_prox;
  maSum += maBuffer[iMa];

  // store value in analysing buffer.
  proxFilteredBuffer[iP] = maSum / MA_BUFFER;
  proxFiltered = proxFilteredBuffer[iP];

  // 3. Find zero crossings
  detectZeroCrossing();

  // 4. Find rising and falling edges
  performEdgeDetectionAndExtremeValueDetermination();
  
  // 5. Evaluate current edge and zero crossing situation
  // Three step blink validation...
  if (blinkLevel != 0 && 
      (iP < iBlinkLevel ? iP + PROX_FILTERED_BUFFER - iBlinkLevel : iP - iBlinkLevel) > t_total[1]) {
    // last blink fragment detect event is more than max blink duration ago.
    // reset current blink detection progress.
    blinkLevel = 0;
  }

  if (edgeType == -1 && blinkLevel == 0) {
    // Is the first step condition met?
    // Rising negative edge after falling negative edge detected and min value meets conditions.
    if (iZero == iP) {
      lengths[0] = iMin < iZeroPrev ? iMin + PROX_FILTERED_BUFFER - iZeroPrev : iMin - iZeroPrev;
    } else {
      lengths[0] = iMin < iZero ? iMin + PROX_FILTERED_BUFFER - iZero : iMin - iZero;
    }
    if (lengths[0] >= t_fall[0] && lengths[0] <= t_fall[1]) {
      // the min part of the curve has the correct length.
      blinkLevel = 1;
      zeroCount = 0;
      iBlinkLevel = iP;
    } else {
      // reset current blink detection progress.
      blinkLevel = 0;
    }
  } else if (edgeType == 1 && blinkLevel == 1) {
    // is the second step condition met?
    // Falling positive edge after rising positive edge detected and max value meets conditions.
    // In current version the blink detection is finished here, otherwise the eye is fully open and one would see the blurry screen after opening the eyes.
    lengths[1] = iMax < iMin ? iMax + PROX_FILTERED_BUFFER - iMin : iMax - iMin;
    if (lengths[1] >= t_rise[0] && lengths[1] <= t_rise[1] && zeroCount < allowedZeros) {
      blinkLevel = 2;
      iBlinkLevel = iP;
      justBlinked = true;
    } else {
      blinkLevel = 0;
    }
  } else if (iZero == iP && blinkLevel == 2) {
    // Final zero crossing detected (eye is fully open)
    // does the overall blink meet the requiremnts?
    lengths[2] = iP < iMax ? iP + PROX_FILTERED_BUFFER - iMax : iP - iMax;
    int sum = lengths[0] + lengths[1] + lengths[2];
    if (sum >= t_total[0] && sum <= t_total[1] && maxVal <= max_max && minVal >= min_min) {
      blinkLevel = 0;
//      justBlinked = true;
    } else {
      blinkLevel = 0;
    }
  }

  // Some cleanup and preparation for next round.
  
  // increase moving average buffer index
  iMa = (iMa + 1) % MA_BUFFER;

  // increase proximity buffer index
  iP = (iP + 1) % PROX_FILTERED_BUFFER;

  // make sure that old indexes are removed if outdated.
  // (required for min max detection and other stuff)
  if (iP == iMin) {
    iMin = -1;
  }
  if (iP == iMax) {
    iMax = -1;
  }
  if (iP == iBlinkLevel) {
    blinkLevel = 0;
    iBlinkLevel = iP;
  }
  if (iP == iEdgeRisingPos) {
    iEdgeRisingPos = -1;
  }
  if (iP == iEdgeFallingPos) {
    iEdgeFallingPos = -1;
  }
  if (iP == iEdgeRisingNeg) {
    iEdgeRisingNeg = -1;
  }
  if (iP == iEdgeFallingNeg) {
    iEdgeFallingNeg = -1;
  }
  // store current 'raw' proximity value for next function execution.
  lastProximity = proximity;
  return justBlinked;
}

/**
 * Detects zero crossing in proxFilteredBuffer[iP]
 * All variables are modified globally.
 */
void detectZeroCrossing() {
  if (lessZero &&  proxFilteredBuffer[iP] >= 0) {
    lessZero = false;
    iZeroPrev = iZero;
    iZero = iP;
  } else if ( !lessZero && proxFilteredBuffer[iP] <= 0) {
    lessZero = true;
    iZeroPrev = iZero;
    iZero = iP;
  }
}

/**
 * Very efficient edge detection based on thresholds and hysterises.
 * Works similar to a state machine.
 * 
 * The function looks much more complicated than it is:
 *  - If positive rising edge (pos threshold + hyst crossed upwards)
 *    Remember the crossing end return
 *  - If positive falling edge (pos threshold - hyst crossed downwards)
 *    Determine maximum value between last positive rising edge and now.
 *    If multiple occurences of max value the index center is taken as iMax.
 *    [1,4,7,5,4,3,7,2,3,1] -> iMax = (6 + 2) / 2 = 4 (index starting at 0)
 *  - If negative falling edge (neg threshold - hyst crossed downwards)
 *    Remember the crossing and return
 *  - If negative rising edge (neg threshold + hyst crossed upwards)
 *    Determine minimum value between last negative falling edge and now.
 *    If multiple occurences of min value, the index center is taken as iMin.
 */
void performEdgeDetectionAndExtremeValueDetermination() {
  edgeType = 0;
  
  // positive edges:
  if (!abovePos && proxFilteredBuffer[iP] > edgePosThresh + hyst) {
    // Positive rising edge
    iEdgeRisingPos = iP;
    abovePos = true;
  } else if (abovePos && proxFilteredBuffer[iP] < edgePosThresh - hyst) {
    // Positive falling edge
    if (iEdgeRisingPos >= 0) {
    // last rising edge is not more than PROX_FILTERED_BUFFER samples away
      iEdgeFallingPos = iP;
      
      // Find max value inbetween last rising and falling positive edges.
      int i = iEdgeRisingPos;
      maxVal = 0;
      int iAmax = -1; // first max val
      int iZmax = -1; // last max val
      while (i != iEdgeFallingPos) {
        if (proxFilteredBuffer[i]  > maxVal) {
          maxVal = proxFilteredBuffer[i];
          iAmax = i;
          iZmax = -1;
          i = (i + 1) % PROX_FILTERED_BUFFER;
        } else if (proxFilteredBuffer[i]  == maxVal) {
          iZmax = i;
        }
        i = (i + 1 + PROX_FILTERED_BUFFER) % PROX_FILTERED_BUFFER; 
      }
      if (iZmax > 0) {
      // multiple max found
        if (iZmax > iAmax) {
        // everything is normal no iP overflow inbetween max values
          iMax = (iZmax + iAmax) / 2;
        } else if (iZmax > iAmax) {
        // iP overflow inbetween max values
          iMax = (iAmax + (iZmax + PROX_FILTERED_BUFFER - iAmax) / 2) % PROX_FILTERED_BUFFER;
        }
      } else {
        iMax = iAmax;
      }
      edgeType = 1;
    }
    abovePos = false;
  } else if ( !belowNeg && proxFilteredBuffer[iP] < edgeNegThresh - hyst){
  
  // Negative falling edge
    iEdgeFallingNeg = iP;
    belowNeg = true;
  } else if (belowNeg && proxFilteredBuffer[iP] > edgeNegThresh + hyst) {
  // Negative rising edge
    iEdgeRisingNeg = iP;

    if (iEdgeFallingNeg >= 0) {
    // last rising edge is not more than PROX_FILTERED_BUFFER samples away
      int i = iEdgeFallingNeg;

      // Find minVal and position of that value between last negative falling edge and now.
      minVal = 0;
      int iAmin = -1; // first min val
      int iZmin = -1; // last min val
      while (i != iEdgeRisingNeg) {
        if (proxFilteredBuffer[i] < minVal) {
          minVal = proxFilteredBuffer[i];
          iAmin = i;
          iZmin = -1;
        } else if (proxFilteredBuffer[i] == maxVal) {
          iZmin = i;
        }
        i = (i + 1 + PROX_FILTERED_BUFFER) % PROX_FILTERED_BUFFER;
      }
      if (iZmin > 0) {
      // multiple point minimum detected. Let's find the middle of that.
        if (iZmin > iAmin) {
          // everything is normal, no iP overflow inbetween.
          iMin = (iZmin + iAmin) / 2;
        } else if (iZmin < iAmin) {
          iMin = (iAmin + (iZmin + PROX_FILTERED_BUFFER - iAmin) / 2) % PROX_FILTERED_BUFFER;
        }
      } else {
        iMin = iAmin;
      }
      edgeType = -1;
    }
    belowNeg = false;
  }
}

