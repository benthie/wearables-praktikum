/**
 * @file        BlurredWindow.m
 * @brief       Implementation file containing the BlurredWindow class.
 *
 * @authors     Benjamin Thiemann, Benjamin Völker
 * @date        2016/12/08
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

#import "BlurredWindow.h"

#define BLUR_START 1

@implementation BlurredWindow

/*
 * Initialization method.
 */
- (id)initWithWindow:(NSWindow *)window {
    
    // Create self.
    self = [super initWithWindow:window];
    
    // If successfull, initialize.
    if (self) {
        
        // Configure the window.
        window.styleMask =  NSFullSizeContentViewWindowMask;
        window.titlebarAppearsTransparent = true;
        [window setStyleMask:NSBorderlessWindowMask];
        window.titleVisibility = NSWindowTitleHidden;
        self.window.level = NSPopUpMenuWindowLevel;
        [self.window setLevel:NSFloatingWindowLevel];
        [self.window setIgnoresMouseEvents:YES];
        
        // Set window background transparent.
        [self enableBlurForWindow:self.window withRadius:0];
        
        // Set variables.
        blurStep            = [[Settings sharedInstance] blurStep];
        blurStepDelay       = [[Settings sharedInstance] blurSpeed];
        currentBlurRadius   = BLUR_START;
        maxBlurRadius       = [[Settings sharedInstance] maxBlurRadius];
        isBlurring          = false;
        
        // Add observers for notifications.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopBlur) name:@"EDNotificationStopBlurring" object:nil];
    }
    
    return self;
}

/*
 * Window did load method.
 */
- (void)windowDidLoad {
    [super windowDidLoad];
}

/*
 * Stolen function from stackoverflow.
 */
- (void)enableBlurForWindow:(NSWindow *)window withRadius:(int) radius {
    [window setOpaque:NO];
    window.backgroundColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.01];
    
    CGSConnection connection = CGSDefaultConnectionForThread();
    CGSSetWindowBackgroundBlurRadius(connection, [window windowNumber], radius);
    [window.contentView setNeedsDisplay:YES];
}

/*
 * Return the current blur value.
 */
- (NSNumber *)getCurrentBlur {
    return [NSNumber numberWithFloat:currentBlurRadius];
}

/*
 * Increase the blur radius.
 */
- (void) increaseBlur {
    if (currentBlurRadius > [[Settings sharedInstance] maxBlurRadius]) {
        // NSLog(@"Blurring Finished");
        return;
    } else {
        currentBlurRadius += [[Settings sharedInstance] blurStep];
        CGSConnection connection = CGSDefaultConnectionForThread();
        CGSSetWindowBackgroundBlurRadius(connection, [self.window windowNumber], currentBlurRadius);
        [self.window.contentView setNeedsDisplay:YES];
        [self.window.contentView display];
        
        [self performSelector:@selector(increaseBlur) withObject:nil afterDelay:[[Settings sharedInstance] blurSpeed]];
    }
}

/*
 * Start the fading blurring.
 */
- (void) startBlur {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    isBlurring = true;
    
    // Blur background.
    [self enableBlurForWindow:self.window withRadius:BLUR_START];
    
    // Increase blurring.
    [self performSelector:@selector(increaseBlur) withObject:nil afterDelay:[[Settings sharedInstance] blurSpeed]];
}

/*
 * Immediately stop blurring.
 */
- (void) stopBlur {

    // Reset values.
    isBlurring = false;
    currentBlurRadius = BLUR_START;
    
    // Clear background.
    [self enableBlurForWindow:self.window withRadius:0];
    
    // Cancel all increase blur calls.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(increaseBlur) object:nil];
}

//- (void)setBlurStep:(float)step {
//    blurStep = step;
//}
//
//- (void)setBlurStepDelay:(float)delay {
//    blurStepDelay = delay;
//}
//
//- (void)setMaxBlurRadius:(float)maxRadius {
//    maxBlurRadius = maxRadius;
//}

@end
