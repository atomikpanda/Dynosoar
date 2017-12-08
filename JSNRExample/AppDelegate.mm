//
//  AppDelegate.m
//  JSNRExample
//
//  Created by Bailey Seymour on 11/29/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "AppDelegate.h"
#import "JavaScriptNativeRuntime.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSLog(@"This is ORIG@!!!!!!!!!!!!!!!!!!!");
}

- (NSString *)someMethodThatHasNSString {
    return @"AppNAME";
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (void)number:(float)theNum {
    NSLog(@"theNum: %g", theNum);
}
- (void)makeRed {
    [self.window setBackgroundColor:[NSColor redColor]];
}
- (void)boolSet:(bool)aBool {
    self.window.title = aBool ? @"YES" : @"NO";
}
- (void)makePurple:(const char *)anArg {
    self.window.title = @(anArg);
    [self.window setBackgroundColor:[NSColor purpleColor]];
}
- (void)twoArgMethod:(id)arg1 arg2:(id)arg2 {
    NSLog(@"arg1=%@;arg2=%@;",arg1,arg2);
}

- (void)aMethodThatTakePrimitiveArray:(int [])array {
    // this doesnt work
    int first = array[0];
    int second = array[1];
    int third = array[2];
    int fourth = array[3];
    printf("the array: %d, %d, %d, %d\n", first, second, third, fourth);
}
@end

__attribute__((constructor))
static void init_hooks() {
    NSError *error = nil;
    
    NSString *scriptContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test.js" ofType:@""] encoding:NSUTF8StringEncoding error:&error];
    if (error) NSLog(@"script contents err: %@", error);
    
    JSNRContextManager *context = [JSNRContextManager sharedInstance];
    
    JSValue *retval = [context evaluateScript:scriptContents baseDirectoryPath:[[NSBundle mainBundle] resourcePath]];
}
