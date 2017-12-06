//
//  ViewController.m
//  JSNRIOSExample
//
//  Created by Bailey Seymour on 12/6/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "ViewController.h"
#import "JavaScriptNativeRuntime.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

__attribute__((constructor))
static void init_hooks() {
    NSError *error = nil;
    
    NSString *scriptContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iostest.js" ofType:@""] encoding:NSUTF8StringEncoding error:&error];
    if (error) NSLog(@"script contents err: %@", error);
    
    JSNRContext *context = [JSNRContext sharedInstance];
    
    JSValue *retval = [context evaluateScript:scriptContents baseDirectoryPath:[[NSBundle mainBundle] resourcePath]];
}
