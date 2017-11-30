//
//  JSNRHookedMap.m
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 11/29/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRHookedMap.h"
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

@interface NSObject (JSNRHookedMap)
+ (JSNRHookedMap *)_JSNRMap;
@end

@implementation NSObject (JSNRHookedMap)
+ (JSNRHookedMap *)_JSNRMap {
    
}
@end

//__attribute__((constructor))
//static void init_map_system() {
//    class_addMethod(NSClassFromString(@"NSObject"), @selector(_JSNRMap), <#IMP  _Nonnull imp#>, <#const char * _Nullable types#>)
//}

