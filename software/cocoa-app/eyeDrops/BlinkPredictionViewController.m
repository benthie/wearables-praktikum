/**
 * @file        BlinkPredictionViewController.m
 * @brief       Implementation file containing the blink data view controller class.
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

#import "BlinkPredictionViewController.h"

static NSString *const kPlotIdentifier  = @"RealTimePlot";

@interface BlinkPredictionViewController ()

@property NSMutableArray *plotDataX;
@property NSMutableArray *plotDataY;
@property (nonatomic, readwrite, assign) NSUInteger currentIndex;
@property (nonatomic, readwrite, strong, nullable) NSTimer *dataTimer;

@end

@implementation BlinkPredictionViewController

@synthesize hostingView;
@synthesize currentIndex;
@synthesize dataTimer;
@synthesize plotDataX;
@synthesize plotDataY;

/*
 * View did load.
 */
- (void)viewDidLoad {
    
    // Init plot data arrays.
    plotDataX = [[NSMutableArray alloc] init];
    plotDataY = [[NSMutableArray alloc] init];
    dataTimer = nil;
    
    // Init index.
    self.currentIndex = 0;
    
    // Add observers for notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(incomingCalibrationData:)
                                                 name:@"EDNotifictaionCalibrationData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showData:) name:@"EDNotificationStopCalibration" object:nil];
}

/*
 * Reset the graph.
 */
- (void)resetGraph {
    
    // Delete all data.
    plotDataX = [[NSMutableArray alloc] init];
    plotDataY = [[NSMutableArray alloc] init];
    
    // Reset index.
    self.currentIndex = 0;
    // Reload the data.
    [blinkDataPlot reloadData];
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
    textStyle.fontName = @"Arial";
    
    // Padding
    CGFloat boundsPadding = 10;
    graph.paddingLeft   = boundsPadding * 4;
    graph.paddingTop    = boundsPadding;
    graph.paddingRight  = boundsPadding;
    graph.paddingBottom = boundsPadding * 3;
    
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
    
    graph.plotAreaFrame.paddingLeft   += titleSize * 3;
    graph.plotAreaFrame.paddingTop    += 10;
    graph.plotAreaFrame.paddingRight  += titleSize;
    graph.plotAreaFrame.paddingBottom += 20;
    graph.plotAreaFrame.masksToBorder  = NO;
    
    // Plot area delegate
    graph.plotAreaFrame.plotArea.delegate = self;
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:[NSNumber numberWithFloat:plotMaxTime]];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@1.0];
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
    
    x.title       = @"time [seconds]";
    
    // Label y with an automatic label policy.
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.minorTicksPerInterval       = 0;
    y.preferredNumberOfMajorTicks = 1;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    y.labelOffset                 = titleSize * CPTFloat(0.25);
    y.alternatingBandFills        = @[[[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)], [NSNull null]];
    y.alternatingBandAnchor       = @0.0;
    
    y.title       = @"Blink";
    y.titleOffset = titleSize * CPTFloat(1.25);
    
    // Set axes
    graph.axisSet.axes = @[x, y];
    
    // Create a plot that uses the data source method
    blinkDataPlot = [[CPTScatterPlot alloc] init];
    blinkDataPlot.identifier = kPlotIdentifier;
    
    // Make the data source line use curved interpolation
    // dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationCurved;
    
    CPTMutableLineStyle *lineStyle = [blinkDataPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor blackColor];
    blinkDataPlot.dataLineStyle = lineStyle;

    // Set plot data source.
    blinkDataPlot.dataSource = self;
    
    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    blinkDataPlot.delegate = self;
    
    // Enable click detection on plot.
    blinkDataPlot.plotSymbolMarginForHitDetection = 5.0;    
}

/*
 * Handler for incoming calibraiton data.
 */
- (void)incomingCalibrationData:(nonnull id)sender {
    
    // Extract the blink data (bool)
    NSData *data = [[(NSNotification *)sender object] subdataWithRange:NSMakeRange(4, 1)];
    bool blinkData;
    [data getBytes:&blinkData length:sizeof(bool)];
    
    if (blinkDataPlot) {
        self.currentIndex++;        
        [self.plotDataY addObject:[NSNumber numberWithFloat:blinkData]];
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
    
    [graph addPlot:blinkDataPlot];
    
    // Redraw the graph.
    [graph reloadData];    
}


#pragma mark
#pragma mark - CPTScatterPlotDataSource methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot {
    
    if (plot.identifier == kPlotIdentifier) {
        return plotDataY.count;
    }
    
    return 0;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSNumber *num = nil;
    
    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            
            if (plot.identifier == kPlotIdentifier) {
                num = [self.plotDataX objectAtIndex:index];
                break;
            }
            
        case CPTScatterPlotFieldY:
            
            if (plot.identifier == kPlotIdentifier) {
                num = [plotDataY objectAtIndex:index];
                break;
            }
            
        default:
            break;
    }
    
    return num;
}

@end
