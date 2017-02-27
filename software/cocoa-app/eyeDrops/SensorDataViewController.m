/**
 * @file        SensorDataViewController.m
 * @brief       Implementation file containing the sensor data view controller class.
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

#import "SensorDataViewController.h"
#import "CalibrationWindowController.h"

#define SCALING_FACTOR  10
#define MAX_X           8
#define X_PADDING       100
#define Y_PADDING       148

static NSString *const kPlotIdentifier  = @"RealTimePlot";
static NSString *const kHLIdentifier    = @"Horizontal Line";

static NSString *const kNegativeTresholdLine = @"Negative Threshold Line";
static NSString *const kPositiveTresholdLine = @"Positive Threshold Line";

@interface SensorDataViewController ()

@property NSMutableArray *plotDataX;
@property NSMutableArray *plotDataY;

@property (nonatomic, readwrite, assign) NSUInteger currentIndex;
@property (nonatomic, readwrite, strong, nullable) NSTimer *dataTimer;

@property (strong, nonatomic, nonnull) IBOutlet CalibrationWindowController *windowController;

@end

@implementation SensorDataViewController

@synthesize windowController;

@synthesize hostingView;
@synthesize currentIndex;
@synthesize dataTimer;
@synthesize plotDataX;
@synthesize plotDataY;

/*
 * View did load.
 */
- (void)viewDidLoad {
    
    // Init the plot data arrays.
    plotDataY = [[NSMutableArray alloc] init];
    plotDataX = [[NSMutableArray alloc] init];
    
    // Add observers for notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingCalibrationData:) name:@"EDNotifictaionCalibrationData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showData:) name:@"EDNotificationStopCalibration" object:nil];
    
    // Init index.
    self.currentIndex = 0;
    
    // Init threshold lines
    negativeThresholdValue = 0;
    positiveThresholdValue = 0;
    negativeThresholdLine = nil;
    positiveThresholdLine = nil;
}

/*
 * Reset the graph.
 */
- (void)resetGraph {
    
    // Delete all data.
    [plotDataX removeAllObjects];
    [plotDataY removeAllObjects];
    
    // Reset index.
    self.currentIndex = 0;
    
    // Reset threshold values.
    negativeThresholdValue = 0;
    positiveThresholdValue = 0;
    
    // Remove and nil the threshold lines.
    [graph removePlot:negativeThresholdLine];
    [graph removePlot:positiveThresholdLine];
    negativeThresholdLine = nil;
    positiveThresholdLine = nil;
    
    // Reload the data.
    [sensorDataPlot reloadData];
}

/*
 * Sets the parameters. Called after view was loaded.
 */
- (void)setParameters:(NSUInteger)time titleSize:(NSUInteger)aTitleSize {
    plotMaxTime = time;
    titleSize = aTitleSize;
    // Now generate the plot.
    [self generatePlotInView:self.view];
}

/*
 * Draws the plot in the view.
 */
- (void)generatePlotInView:(NSView *)view {
    
    // Init the graph.
    graph = [[CPTXYGraph alloc] initWithFrame:self.view.frame];
    
    // Init the hosting view.
    hostingView = [[CPTGraphHostingView alloc] initWithFrame:view.bounds];
    [view addSubview:hostingView];
    
    // Add graph to hosting view.
    hostingView.hostedGraph = graph;
    
    // Apply theme.
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [graph applyTheme:theme];
    
    // Text style object.
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    
    // Padding
    CGFloat boundsPadding = 10;
    graph.paddingLeft   = boundsPadding * 4;
    graph.paddingTop    = boundsPadding;
    graph.paddingRight  = boundsPadding;
    graph.paddingBottom = boundsPadding;
    
    // Axis labels
    CGFloat axisTitleSize = 10;
    CGFloat labelSize     = 10;
    
    for ( CPTAxis *axis in graph.axisSet.axes ) {
        // Axis title
        textStyle          = [axis.titleTextStyle mutableCopy];
        textStyle.fontSize = axisTitleSize;
        
        axis.titleTextStyle = textStyle;
        
        // Axis labels
        textStyle          = [axis.labelTextStyle mutableCopy];
        textStyle.fontSize = labelSize;
        
        axis.labelTextStyle = textStyle;
        
        textStyle          = [axis.minorTickLabelTextStyle mutableCopy];
        textStyle.fontSize = labelSize;
        
        axis.minorTickLabelTextStyle = textStyle;
    }
    
    // Plot labels
    for ( CPTPlot *plot in graph.allPlots ) {
        textStyle          = [plot.labelTextStyle mutableCopy];
        textStyle.fontSize = labelSize;
        
        plot.labelTextStyle = textStyle;
    }
    
    // Set plotAreaFrame paddings
    graph.plotAreaFrame.paddingLeft   += titleSize * 3;
    graph.plotAreaFrame.paddingTop    += 10;
    graph.plotAreaFrame.paddingRight  += titleSize;
    graph.plotAreaFrame.paddingBottom += 20;
    graph.plotAreaFrame.masksToBorder  = NO;
    
    // Plot area delegate
    graph.plotAreaFrame.plotArea.delegate = self;
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0 length:[NSNumber numberWithFloat:plotMaxTime]];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@-0.1 length:@0.2];
    plotSpace.allowsUserInteraction = NO;
    plotSpace.delegate              = self;
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.75)];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];
    
    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];
    
    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet   = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x            = axisSet.xAxis;
    x.labelingPolicy        = CPTAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength   = @1.0;
    x.minorTicksPerInterval = 5;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    x.axisConstraints       = [CPTConstraints constraintWithRelativeOffset:0.0];
    
    x.title       = @"X Axis";
    x.title       = @"";
    
    // Label y with an automatic label policy.
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyFixedInterval;
    y.majorIntervalLength   = @0.1;
    y.minorTicksPerInterval = 5;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    y.labelOffset                 = titleSize * CPTFloat(0.25);
    y.alternatingBandFills        = @[[[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)], [NSNull null]];
    y.alternatingBandAnchor       = @0.0;
    
    y.title       = @"Sensor data";
    y.titleOffset = titleSize * CPTFloat(1.25);
    
    // Set axes
    graph.axisSet.axes = @[x, y];
    
    // Create a plot that uses the data source method
    sensorDataPlot = [[CPTScatterPlot alloc] init];
    sensorDataPlot.identifier = kPlotIdentifier;
    
    // Set plot appearence
    CPTMutableLineStyle *lineStyle = [sensorDataPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor blackColor];
    sensorDataPlot.dataLineStyle = lineStyle;
    
    // Set plot data source.
    sensorDataPlot.dataSource = self;
    
    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    sensorDataPlot.delegate = self;
    
    // Enable click detection on plot.
    sensorDataPlot.plotSymbolMarginForHitDetection = 5.0;
}

/*
 * Handler for incoming calibraiton data.
 */
- (void)incomingCalibrationData:(nonnull id)sender {
    
    // Extract the sensor data (float)
    NSData *data = [[(NSNotification *)sender object] subdataWithRange:NSMakeRange(0, 4)];
    float sensorData;
    [data getBytes:&sensorData length:sizeof(float)];
    
    // Scale the incoming data.
    sensorData = sensorData * SCALING_FACTOR;
    
    // Add the data to the plot
    if (sensorDataPlot) {
        self.currentIndex++;
        [self.plotDataY addObject:[NSNumber numberWithFloat:sensorData]];
    }
}

/*
 * Show the data (after data acquisition).
 */
- (void)showData:(nonnull id)sender {
    
    // Scale x values.
    for (int i=0; i<self.currentIndex; i++) {
        float xValue = (float)(plotMaxTime / (float)self.currentIndex) * (float)i;
        [self.plotDataX addObject:[NSNumber numberWithFloat:xValue]];
    }
    
    // Add the plot to the graph.
    [graph addPlot:sensorDataPlot];
    
    // Redraw the graph.
    [graph reloadData];
}


#pragma mark
#pragma mark - CPTScatterPlotDataSource methods

- (NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot {
    
    if (plot.identifier == kPlotIdentifier) {
        return plotDataY.count;
    }
    
    if (plot.identifier == kNegativeTresholdLine) {
        return 2;
    }
    
    if (plot.identifier == kPositiveTresholdLine) {
        return 2;
    }
    
    return 0;
}

- (nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    NSNumber *num = nil;
    
    switch ( fieldEnum ) {
            
        case CPTScatterPlotFieldX:
            
            if (plot.identifier == kPlotIdentifier) {
                // Return the saved xValue from plotDataX
                num = [self.plotDataX objectAtIndex:index];
                break;
            }
            
            if (plot.identifier == kNegativeTresholdLine) {
                // If index == 0, xValue is 0
                // If index == 1, xValue is MAX_X
                num = [NSNumber numberWithInteger:index * plotMaxTime];
                break;
            }
            
            if (plot.identifier == kPositiveTresholdLine) {
                // If index == 0, xValue is 0
                // If index == 1, xValue is MAX_X
                num = [NSNumber numberWithInteger:index * plotMaxTime];
                break;
            }
            
        case CPTScatterPlotFieldY:
            
            if (plot.identifier == kPlotIdentifier) {
                num = [self.plotDataY objectAtIndex:index];
                break;
            }
            
            if (plot.identifier == kNegativeTresholdLine) {
                num = [NSNumber numberWithFloat:negativeThresholdValue];
                break;
            }
            
            if (plot.identifier == kPositiveTresholdLine) {
                num = [NSNumber numberWithFloat:positiveThresholdValue];
                break;
            }
            
        default:
            break;
    }
    
    return num;
}

#pragma mark
#pragma mark - CPTPlotSpaceDelegate methods

/*
 * Plot space was clicked. Create a threshold line.
 */
- (BOOL)plotSpace:(nonnull CPTPlotSpace*) thePlotSpace shouldHandlePointingDeviceDownEvent:(nonnull CPTNativeEvent*)theEvent atPoint:(CGPoint)thePoint {
    float value = (thePoint.y - Y_PADDING) / 1000;
    [self createThresholdLineFromValue:value];
    return true;
}


#pragma mark
#pragma mark - Methods for marking calibration parameters

/*
 * Create threshold line from given value.
 */
- (void)createThresholdLineFromValue:(float)value {
    
    // check if value is positive or negative
    if (value < 0) {
        
        NSLog(@"Negative value");
        
        // Create a negative threshold line
        if (!negativeThresholdLine) {
            
            NSLog(@"Initialize negative threshold line");
            
            // Initialize the line.
            negativeThresholdLine = [[CPTScatterPlot alloc] init];
            
            // Set identifier.
            negativeThresholdLine.identifier = kNegativeTresholdLine;
            
            // Setup the line style.
            CPTMutableLineStyle *lineStyle   = [sensorDataPlot.dataLineStyle mutableCopy];
            lineStyle.lineWidth              = 1.0;
            lineStyle.lineColor              = [CPTColor redColor];
            lineStyle.dashPattern            = @[@5, @5];
            negativeThresholdLine.dataLineStyle = lineStyle;
            
            // Add the plot to the graph.
            negativeThresholdLine.dataSource = self;
            [graph addPlot:negativeThresholdLine];
        }
        
        // Set or reset the value for the line.
        negativeThresholdValue = value;
        
        // Transmit value to window controller in order to update the textfield.
        [windowController setNegativeThreshold:[NSNumber numberWithFloat:value]];
        
    } else {
        
        NSLog(@"Positive value");
        
        // Create a positive threshold line
        if (!positiveThresholdLine) {
            
            NSLog(@"Initialize positive threshold line");
            
            // Initialize the line.
            positiveThresholdLine = [[CPTScatterPlot alloc] init];
            
            // Set identifier.
            positiveThresholdLine.identifier = kPositiveTresholdLine;
            
            // Setup the line style.
            CPTMutableLineStyle *lineStyle   = [sensorDataPlot.dataLineStyle mutableCopy];
            lineStyle.lineWidth              = 1.0;
            lineStyle.lineColor              = [CPTColor blueColor];
            lineStyle.dashPattern            = @[@5, @5];
            positiveThresholdLine.dataLineStyle = lineStyle;
            
            // Add the plot to the graph.
            positiveThresholdLine.dataSource = self;
            [graph addPlot:positiveThresholdLine];
        }
        
        // Set or reset the value for the line.
        positiveThresholdValue = value;
        
        // Transmit value to window controller in order to update the textfield.
        [windowController setPositiveThreshold:[NSNumber numberWithFloat:value]];
        
        NSLog(@"Change value for positive threshold line. Value is now %f", positiveThresholdValue);
    }
    
    // Redraw the graph.
    [graph reloadData];
}

@end