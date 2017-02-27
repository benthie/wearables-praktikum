/**
 * @file        Settings.m
 * @brief       Implementation file containing the shared settings class.
 *
 * @author      Benjamin Thiemann
 * @date        2017/01/17
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

#import "Settings.h"


@implementation Settings


/*
 * This method returns the shared instance of this singleton class.
 */
+ (instancetype)sharedInstance {
    
    // The static shared instance.
    static Settings *sharedInstance = nil;
    
    // Singleton token.
    static dispatch_once_t onceToken;
    
    // Check if token already existing.
    dispatch_once(&onceToken, ^{
        
        BOOL isDir = YES;
        
        // Setup the directory.
        NSString *appDir = [[NSString alloc] initWithString:NSHomeDirectory()];
        appDir = [appDir stringByAppendingString:@"/eyeDrops"];
        
        // Get directory existance status.
        BOOL dirExists = [[NSFileManager defaultManager] fileExistsAtPath:appDir isDirectory:&isDir];
        
        // Check
        if (!dirExists) {
            NSLog(@"INIT PHASE >>> App directory created.");
            [[NSFileManager defaultManager] createDirectoryAtPath:appDir
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:nil];
        }
        
        // Setup the path to the settings.
        NSString *settingsFile = [[NSString alloc] initWithString:NSHomeDirectory()];
        settingsFile = [settingsFile stringByAppendingString:[NSString stringWithFormat:@"/eyeDrops/settings.txt"]];
        
        // Get file existance status.
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:settingsFile];
        
        // Check if file is existing.
        if (fileExists) {
            
            // Read settings from disk
            sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:settingsFile];
            
        } else {
            NSLog(@"INIT PHASE >>> No settings fie extisting yet. Use standard values.");
        }
        
        // Check if settings could be restored.
        if (sharedInstance == nil) {
            
            // Create instance once.
            sharedInstance = [[Settings alloc] init];
        }
    });
    
    // Return the single instance.
    return sharedInstance;
}

/*
 * Initialization method.
 */
- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.autoScan           = true;
        self.autoConnect        = true;
        
        self.maxBlurRadius      = 20;
        self.blurStep           = 0.5;
        self.blurSpeed          = 0.01;
        self.blinkTimerValue    = 5;
        
        self.batteryLevel       = 1.65;
        
        self.autoSelectXMLFile  = true;
        self.xmlFile            = @"/Users/Benny/eyeDrops/profiles.xml";
        
        self.lastKnownDevice    = @"9FE24992-DDD8-45E7-AFD1-261D1357496A"; // eyeDrops (Lorenz)
    }
    
    return self;
}

/*
 * Save class.
 */
- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        
        self.autoScan           = [decoder decodeBoolForKey:@"autoScan"];
        self.autoConnect        = [decoder decodeBoolForKey:@"autoConnect"];
        
        self.maxBlurRadius      = [decoder decodeIntegerForKey:@"maxBlurRadius"];
        self.blurStep           = [decoder decodeFloatForKey:@"blurStep"];
        self.blurSpeed          = [decoder decodeFloatForKey:@"blurSpeed"];
        self.blinkTimerValue    = [decoder decodeIntegerForKey:@"blinkTimerValue"];
        
        self.autoSelectXMLFile  = [decoder decodeBoolForKey:@"autoSelectXMLFile"];
        self.xmlFile            = [decoder decodeObjectForKey:@"xmlFile"];
        
        self.lastKnownDevice    = [decoder decodeObjectForKey:@"lastKnownDevice"];
        
        self.batteryLevel       = 3.3;
    }
    
    return self;
}

/*
 * Load class.
 */
- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeBool:self.autoScan           forKey:@"autoScan"];
    [encoder encodeBool:self.autoConnect        forKey:@"autoConnect"];
    
    [encoder encodeInteger:self.maxBlurRadius   forKey:@"maxBlurRadius"];
    [encoder encodeFloat:self.blurStep          forKey:@"blurStep"];
    [encoder encodeFloat:self.blurSpeed         forKey:@"blurSpeed"];
    [encoder encodeInteger:self.blinkTimerValue forKey:@"blinkTimerValue"];
    
    [encoder encodeBool:self.autoSelectXMLFile  forKey:@"autoSelectXMLFile"];
    [encoder encodeObject:self.xmlFile          forKey:@"xmlFile"];
    
    [encoder encodeObject:self.lastKnownDevice  forKey:@"lastKnownDevice"];
}

@end
