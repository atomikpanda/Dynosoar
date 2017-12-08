//
//  JSNRHookedMap.m
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 11/29/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRClassMap.h"
#import "JSNRContextManager.h"
#import <objc/runtime.h>

@implementation JSNRClassMap
@synthesize map;

+ (instancetype)classMap {
    JSNRClassMap *map = [[[self alloc] init] autorelease];
    
    if (map) {
        map.map = [NSMutableDictionary dictionary];
    }
    
    return map;
}

- (void)dealloc {
    
    self.map = nil;
    [super dealloc];
}

@end

@implementation NSObject (_JSNRClassMap)
+ (JSNRClassMap *)_JSNRClassMap {
    JSNRContextManager *context = [JSNRContextManager sharedInstance];
   return [context mapForClass:self];
}

@end

//__attribute__((constructor))
//static void init_map_system() {
//    class_addMethod(NSClassFromString(@"NSObject"), @selector(_JSNRClassMap), <#IMP  _Nonnull imp#>, <#const char * _Nullable types#>)
//}

