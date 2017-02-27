/**
 * @file        AnimationViewController.m
 * @brief       Implementation file containing the animation view controller class.
 *
 * @author      Benjamin Thiemann
 * @date        2017/02/07
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

#import "AnimationViewController.h"

@interface AnimationViewController ()

/*
 * The animation view this class is controlling.
 */
@property AnimationView *animationView;

@end

@implementation AnimationViewController

@synthesize animationView;

/*
 * View did load method.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [self.view initWithFrame:self.view.frame];
    animationView = (AnimationView*)self.view;
}

/*
 * Start a test animation.
 */
- (void)startTestAnimation {
    [animationView startTestAnimation];
}

/*
 * Start a normal animation.
 */
- (void)startAnimation {
    [animationView startAnimation];
}

/*
 * Stop the current animation.
 */
- (void)stopAnimation {
    [animationView stopAnimation];
}

@end
