/**
 * @file        BlinkPredictionViewController.h
 * @brief       Header file containing the blink data view controller class.
 *
 * @author      Benjamin Thiemann
 * @date        2017/02/04
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
#import <CorePlot/CorePlot.h>

/**
 * @brief       Blink data view controller class class.
 *
 * @class       BlinkPredictionViewController
 * @discussion  This class contains the plot for the blink data.
 *
 * @author      Benjamin Thiemann
 * @date        2016/11/16
 */
@interface BlinkPredictionViewController : NSViewController <CPTPlotAreaDelegate, CPTPlotSpaceDelegate, CPTPlotDataSource, CPTPlotDelegate> {
    
    /**
     * The title size.
     */
    CGFloat titleSize;
    
    /**
     * Maximum plot time (scaling of x axis).
     */
    CGFloat plotMaxTime;
    
    /**
     * The grapph.
     */
    CPTGraph *graph;
    
    /**
     * The blink data plot.
     */
    CPTScatterPlot *blinkDataPlot;
}

/**
 * The hosting view for the graph.
 */
@property (strong, nonatomic, nonnull) IBOutlet CPTGraphHostingView *hostingView;

/**
 * This method sets the given parameters.
 *
 * @param   time
 *      The maximum time (x axis).
 * @param   aTitleSize
 *      The title size.
 */
- (void)setParameters:(NSUInteger)time titleSize:(NSUInteger)aTitleSize;

/**
 * This method draws the graphs with all it's plots in the given view.
 *
 * @param   view
 *      The view to draw in.
 */
- (void)generatePlotInView:(nonnull NSView *)view;

/**
 * This method shows the data in the plot. Invoked when a data acquisition is completed.
 *
 * @param   sender
 *      The sending instance.
 */
- (void)showData:(nonnull id)sender;

// - (NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot;

/**
 * This method handles incoming calibraion data.
 *
 * @param sender
 *      The sending instance.
 */
- (void)incomingCalibrationData:(nonnull id)sender;

/**
 * This method resets the graph.
 */
- (void)resetGraph;

@end
