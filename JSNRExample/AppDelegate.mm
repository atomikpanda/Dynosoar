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


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (void)number:(double)theNum {
    printf("theNum: %g\n", theNum);
}
- (void)makeRed {
    [self.window setBackgroundColor:[NSColor redColor]];
}
- (void)makePurple:(NSString *)anArg {
    self.window.title = anArg;
    [self.window setBackgroundColor:[NSColor purpleColor]];
}
- (void)twoArgMethod:(id)arg1 arg2:(id)arg2 {
    NSLog(@"arg1=%@;arg2=%@;",arg1,arg2);
}
@end

__attribute__((constructor))
static void init_hooks() {
    NSError *error = nil;
    
    NSString *scriptContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test.js" ofType:@""] encoding:NSUTF8StringEncoding error:&error];
    if (error) NSLog(@"script contents err: %@", error);
    
    JSNRContext *context = [JSNRContext sharedInstance];
    
    JSValue *retval = [context evaluateScript:scriptContents];
}
