/**
 * @file        AnimationView.m
 * @brief       Implementation file containing the animation view class.
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/26
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


#import "AnimationView.h"


@interface AnimationView()

@property (strong) NSImage *imgDigit1;
@property (strong) NSImage *imgDigit2;
@property (strong) NSImage *imgDigit3;
@property (strong) NSImage *imgEyeOpen;
@property (strong) NSImage *imgEyeShut;

@property (strong) NSMutableArray *circles;
@property (strong) NSMutableArray *colorsFill;
@property (strong) NSMutableArray *colorsStroke;

@property (strong) NSBezierPath *separator;

@property (strong, nonatomic) NSColor *green1;
@property (strong, nonatomic) NSColor *green2;
@property (strong, nonatomic) NSColor *green3;
@property (strong, nonatomic) NSColor *green4;
@property (strong, nonatomic) NSColor *green1a;
@property (strong, nonatomic) NSColor *green2a;
@property (strong, nonatomic) NSColor *green3a;
@property (strong, nonatomic) NSColor *green4a;

@property (strong, nonatomic) NSColor *red1;
@property (strong, nonatomic) NSColor *red4;
@property (strong, nonatomic) NSColor *red1a;
@property (strong, nonatomic) NSColor *red4a;

@property (strong, nonatomic) NSColor *yellow1;
@property (strong, nonatomic) NSColor *yellow4;
@property (strong, nonatomic) NSColor *yellow1a;
@property (strong, nonatomic) NSColor *yellow4a;

@property (strong, nonatomic) NSColor *activeStroke;
@property (strong, nonatomic) NSColor *inactiveStroke;
@property (strong, nonatomic) NSColor *activeFill;
@property (strong, nonatomic) NSColor *inactiveFill;

@end

@implementation AnimationView

@synthesize imgEyeOpen, imgEyeShut, imgDigit1, imgDigit2, imgDigit3;
@synthesize circles;
@synthesize colorsFill;
@synthesize colorsStroke;
@synthesize separator;
@synthesize green1, green2, green3, green4, green1a, green2a, green3a, green4a;
@synthesize red1, red1a, red4, red4a;
@synthesize yellow1, yellow1a, yellow4, yellow4a;
@synthesize activeFill, inactiveFill, activeStroke, inactiveStroke;

#define OFFSET_Y        45
#define OFFSET_X        10
#define CENTER_Y        70
#define DIAMETER        50
#define DIAMETER2       67
#define GAP_WIDTH       8
#define IMAGE_OFFSET    5
#define LINE_WIDTH      3

#define INTRO_GAP       100
#define SEPARATOR_HEIGHT    100

#define PLOT_AREA_WIDTH 770

// CIRCLE COUNT
#define BLINKS          4
#define START_DELAY     0
#define GAP_DELAY       1
#define END_DELAY       1

/*
 * Initialization method.
 */
- (id)initWithFrame:(NSRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialize state.
        isRunning = false;
        isCountingDown = false;
        isTestRun = false;

        // Initialize the colors.
        [self initColors];
        
        // Set active and inactive colors.
        inactiveFill    = green1a;
        inactiveStroke  = green4a;
        activeFill      = green1;
        activeStroke    = green4;
        
        // Initialize the images.
        imgDigit1   = [NSImage imageNamed:@"digit1.png"];
        imgDigit2   = [NSImage imageNamed:@"digit2.png"];
        imgDigit3   = [NSImage imageNamed:@"digit3.png"];
        imgEyeOpen  = [NSImage imageNamed:@"eye_open.png"];
        imgEyeShut  = [NSImage imageNamed:@"eye_shut.png"];
        
        // Initialize array for circles and their colors.
        circles = [[NSMutableArray alloc] init];
        colorsFill = [[NSMutableArray alloc] init];
        colorsStroke = [[NSMutableArray alloc] init];
        
        // Initialize x position.
        float positionX = OFFSET_X;
        
        // Determine the gap to the next centering point for a circle.
        float circleGap = (PLOT_AREA_WIDTH / (BLINKS + BLINKS * GAP_DELAY));
        
        // NSLog(@"circle gap = %f", circleGap);
        
        //positionX += DIAMETER + GAP_WIDTH;
        positionX = INTRO_GAP;
        
        // Determine number of circles.
        int circlesCount = START_DELAY + BLINKS + (GAP_DELAY) * BLINKS + END_DELAY;
        
        // Initialize gap counter.
        int gapCounter = 0;
        
        // Create the rest of the circles
        for (int i=START_DELAY; i<circlesCount; i++) {
            
            // Check for open eye circle.
            if (gapCounter < GAP_DELAY) {
                NSBezierPath *newCircle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(positionX - (DIAMETER /2), OFFSET_Y, DIAMETER, DIAMETER)];
                [newCircle setLineWidth:LINE_WIDTH];
                [colorsFill addObject:inactiveFill];
                [colorsStroke addObject:inactiveStroke];
                [circles addObject:newCircle];
                //positionX += DIAMETER + GAP_WIDTH;
                gapCounter++;
            } else {
                NSBezierPath *newCircle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(positionX  - (DIAMETER2 / 2), OFFSET_Y - (DIAMETER2 - DIAMETER) / 2 , DIAMETER2, DIAMETER2)];
                [newCircle setLineWidth:LINE_WIDTH];
                [colorsFill addObject:inactiveFill];
                [colorsStroke addObject:inactiveStroke];
                [circles addObject:newCircle];
                //positionX += DIAMETER2 + GAP_WIDTH;
                gapCounter = 0;
            }
            positionX += circleGap;
        }
        
        length = (int)[circles count];
    }

    return self;
}

/*
 * (Re)draws the view.
 */
- (void)drawRect:(NSRect)dirtyRect {
    
    // Draw the circles.
    for (int i=0; i<[circles count]; i++) {
        [[colorsStroke objectAtIndex:i] setStroke];
        [[colorsFill objectAtIndex:i] setFill];
        
        NSBezierPath *currentCircle = [circles objectAtIndex:i];
        [currentCircle fill];
        [currentCircle stroke];
        
        if (isRunning && i==pos) {
            if (currentCircle.bounds.size.height == DIAMETER) {
                // Draw open eye.
                [imgEyeOpen drawInRect:[currentCircle bounds] fromRect:NSMakeRect(0, 0, imgEyeShut.size.width, imgEyeShut.size.height) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:nil];
            } else {
                // Draw shut eye.
                [imgEyeShut drawInRect:[currentCircle bounds] fromRect:NSMakeRect(0, 0, imgEyeShut.size.width, imgEyeShut.size.height) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:nil];
            }
        }
        
        if (isCountingDown && i==0) {
            switch (pos) {
                case -3:
                    [imgDigit3 drawInRect:[currentCircle bounds] fromRect:NSMakeRect(0, 0, imgDigit3.size.width, imgDigit3.size.height) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:nil];
                    pos++;
                    break;
                case -2:
                    [imgDigit2 drawInRect:[currentCircle bounds] fromRect:NSMakeRect(0, 0, imgDigit2.size.width, imgDigit2.size.height) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:nil];
                    pos++;
                    break;
                case -1:
                    [imgDigit1 drawInRect:[currentCircle bounds] fromRect:NSMakeRect(0, 0, imgDigit1.size.width, imgDigit1.size.height) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:nil];
                    //pos++;
                    isCountingDown = false;
                    isRunning = true;
                    break;
                    
                default:
                    break;
            }
        }
    }
}

/*
 * Enables / disables the circle at pos i.
 */
- (void)enableCirle:(BOOL)active atPos:(int)i {
    
    // If counting down is active.
    if (isCountingDown) {
        [colorsFill    replaceObjectAtIndex:0 withObject:red1];
        [colorsStroke  replaceObjectAtIndex:0 withObject:red4];
        return;
    }
    
    // If countdown expired.
    if (active) {
        [colorsFill    replaceObjectAtIndex:i withObject:activeFill];
        [colorsStroke  replaceObjectAtIndex:i withObject:activeStroke];
    } else {
        [colorsFill    replaceObjectAtIndex:i withObject:inactiveFill];
        [colorsStroke  replaceObjectAtIndex:i withObject:inactiveStroke];
    }
}

/*
 * Performs the next step.
 */
- (void)nextStep:(id)sender {
    
    if (isCountingDown) {
        
        // Redraw the content.
        [self setNeedsDisplay:YES];
        
        // After 1 secon do the next step.
        [self performSelector:@selector(nextStep:) withObject:self afterDelay:1.0];
        
        return;
    }
    
    if (pos == -1) {
        
        if (!isTestRun) {
            // Start calibration with RFDuino
            [[BLEDeviceManager sharedInstance] startCalibrationWithDevice];
            NSLog(@"AnimationView: StartCalibration");
        }
        
        // startDate = [NSDate date];
        
        // Enable first circle.
        [self enableCirle:true atPos:pos+1];
        
        // Redraw the content.
        [self setNeedsDisplay:YES];
        
        pos++;
        
        // After 1 secon do the next step.
        [self performSelector:@selector(nextStep:) withObject:self afterDelay:1.0];
        
        return;
        
    }
    
    // [self enableCirle:false atPos:pos];
    
    if (pos == length - 1) {
        
        if (!isTestRun) {
            
            // STOP CALIBRATION
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EDNotificationStopCalibration" object:nil];
            NSLog(@"AnimationView: StopCalibration");
            [[BLEDeviceManager sharedInstance] stopCalibrationWithDevice];
        }
        
        // stopDate = [NSDate date];
        
        // NSLog(@"Start time: %@", startDate);
        // NSLog(@"Stop  time: %@", stopDate);
        
        if (!isTestRun) {
            
            // Tell calibration window that animation has finished
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EDNotificationAnimationFinished" object:nil];
        }
        
        // Stop animation.
        isRunning = false;
        
        // Redraw the content.
        [self setNeedsDisplay:YES];
        
        // Reset the circles to inactive color.
        [self resetAnimation];
        
        return;
    }
    
    [self enableCirle:true atPos:(pos+1)];
    pos++;
    
    // Redraw the content.
    [self setNeedsDisplay:YES];
    
    
    if (isRunning) {
        
        // After 1 secon do the next step.
        [self performSelector:@selector(nextStep:) withObject:self afterDelay:1.0];
    }
    
}

/*
 * Start a test animation.
 */
- (void)startTestAnimation {
    
    isTestRun = true;
    
    [self startAnimation];
}

/*
 * Start the animation.
 */
- (void)startAnimation {
    
    isRunning = false;
    isCountingDown = false;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextStep:) object:nil];
    
    // Avoid second animation when the animation is currently runnin.
    if (!isRunning) {
    
        // Check is animation is reset.
        if (!isCountingDown) {
            
            // Initialize position.
            pos = -3;
            
            // Start the process.
            isCountingDown = true;
            
            // Activate first circle.
            [self enableCirle:true atPos:pos];
            
            // Redraw the content.
            [self setNeedsDisplay:YES];
            
            // After 1 secon do the next step.
            [self performSelector:@selector(nextStep:) withObject:nil afterDelay:1.0];
        }
    }
}

/*
 * Stop the animation.
 */
- (void)stopAnimation {
    
    NSLog(@"STOP Animation was called");
    
    isRunning = false;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextStep:) object:nil];
}

/*
 * Reset the animation.
 */
- (void)resetAnimation {
    
    for (int i=0; i<circles.count; i++) {
        [self enableCirle:false atPos:i];
    }
    
    isRunning = false;
    isCountingDown = false;
    isTestRun = false;
}

/*
 * Initialization of the colors.
 */
- (void)initColors {
    green1  = [NSColor colorWithRed:0.34 green:0.56 blue:0.47 alpha:1.0];
    green2  = [NSColor colorWithRed:0.20 green:0.45 blue:0.35 alpha:1.0];
    green3  = [NSColor colorWithRed:0.05 green:0.26 blue:0.17 alpha:1.0];
    green4  = [NSColor colorWithRed:0.00 green:0.15 blue:0.09 alpha:1.0];
    green1a = [NSColor colorWithRed:0.34 green:0.56 blue:0.47 alpha:0.6];
    green2a = [NSColor colorWithRed:0.20 green:0.45 blue:0.35 alpha:0.6];
    green3a = [NSColor colorWithRed:0.05 green:0.26 blue:0.17 alpha:0.6];
    green4a = [NSColor colorWithRed:0.00 green:0.15 blue:0.09 alpha:0.6];
    
    red1    = [NSColor colorWithRed:0.95 green:0.02 blue:0.18 alpha:1.0];
    red1a   = [NSColor colorWithRed:0.95 green:0.02 blue:0.18 alpha:0.6];
    red4    = [NSColor colorWithRed:0.58 green:0.00 blue:0.10 alpha:1.0];
    red4a   = [NSColor colorWithRed:0.58 green:0.00 blue:0.10 alpha:0.6];
    
    yellow1 = [NSColor colorWithRed:1.00 green:0.89 blue:0.20 alpha:1.0];
    yellow1a= [NSColor colorWithRed:1.00 green:0.89 blue:0.20 alpha:0.6];
    yellow4 = [NSColor colorWithRed:0.95 green:0.81 blue:0.00 alpha:1.0];
    yellow4a= [NSColor colorWithRed:0.95 green:0.81 blue:0.00 alpha:0.6];
}

@end
