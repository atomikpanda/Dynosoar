//
//  JSNRInvokeInfo.m
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/10/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRInvokeInfo.h"

@implementation JSNRInvokeInfo

@synthesize target, selectorString, targetIsClass;

- (id)initWithTarget:(id)target selectorString:(NSString *)selectorStr isClass:(BOOL)targetIsClass {
    self = [super init];
    
    if (self) {
        self.target = target;
        self.selectorString = selectorStr;
        self.targetIsClass = targetIsClass;
    }
    
    return self;
}

+ (instancetype)infoWithTarget:(id)target selector:(NSString *)selStr isClass:(BOOL)targetIsClass {
    return [[[self alloc] initWithTarget:target selectorString:selStr isClass:targetIsClass] autorelease];
}

+ (instancetype)info {
    return [[[self alloc] initWithTarget:nil selectorString:nil isClass:NO] autorelease];
}

- (void)parseSelectorAsSetSelector {

    NSString *selectorStr = self.selectorString;
    
    selectorStr = [NSString stringWithFormat:@"set%c%@:", toupper([selectorStr characterAtIndex:0]), [selectorStr substringFromIndex:1]];
    
    self.selectorString = selectorStr;
}
- (void)parseSelectorAsGetSelector {
    NSString *selectorStr = [self.selectorString stringByReplacingOccurrencesOfString:@"$" withString:@":"];
    self.selectorString = selectorStr;
}

- (SEL)selector {
    return NSSelectorFromString(self.selectorString);
}

- (void)dealloc {
    self.target = nil;
    self.selectorString = nil;
    
    [super dealloc];
}

@end
