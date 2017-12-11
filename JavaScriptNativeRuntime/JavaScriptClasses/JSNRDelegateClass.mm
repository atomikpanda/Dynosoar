//
//  JSNRDelegateClass.m
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/11/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRDelegateClass.h"
#import "JSNRInvokeInfo.h"
#import "JSNRSuperClass.h"
#import "JSNRValue.h"
#import "JSNRInstanceClass.h"
#import <objc/runtime.h>

JSValueRef createDelegateFn(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef *exception)
{
    JSContext *context = [JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)];
    JSValue *function = [JSValue valueWithJSValueRef:functionRef inContext:context];
    JSValue *thisObject = [JSValue valueWithJSValueRef:thisObjectRef inContext:context];
    
    JSNRContainer *container = thisObject.container;
    
    id delegate = [[objc_getClass("JSNRDelegateForwarder") alloc] initWithJSValue:thisObject];
    
    BOOL hasProp = [thisObject hasProperty:@"alertView$didDismissWithButtonIndex$"];
    NSLog(@"HHAS %@ == %s", @"alertView$didDismissWithButtonIndex$", hasProp ?"Y":"N");

    JSObjectRef delobj = [JSNRSuperClass createEmptyObjectRefWithContext:ctx classRef:[JSNRInstanceClass sharedReference]];
    JSValue *delobjValue = [JSValue valueWithJSValueRef:delobj inContext:context];
    
    JSNRInvokeInfo *info = [JSNRInvokeInfo infoWithTarget:delegate selector:nil isClass:NO];
    delobjValue.container.info = info;
    
    return delobj;
}

@implementation JSNRDelegateClass

+ (NSString *)JSClassName {
    return @"Delegate";
}

+ (instancetype)sharedReference
{
    static NSObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self alloc] init] autorelease];
        // Do any other initialisation stuff here
    });
    return (id)sharedInstance;
}

- (JSValue *)calledAsConstructor:(JSValue *)constructor argumentCount:(size_t)argumentCount argumentRefs:(const JSValueRef [])argumentRefs inContext:(JSContext *)context
{
    return constructor;
}

- (JSValue *)getPropertyWithName:(NSString *)propertyName fromObject:(JSValue *)object inContext:(JSContext *)context
{
    if ([propertyName isEqualToString:@"Symbol.toPrimitive"]) {
        
        return [@"" valueInContext:context];
    }
    if ([propertyName isEqualToString:@"toString"]) {
        return [propertyName valueInContext:context];
    }
    if ([propertyName isEqualToString:@"valueOf"]) {
        return [propertyName valueInContext:context];
    }
    if ([propertyName isEqualToString:@"toCString"]) {
        return [propertyName valueInContext:context];
    }
    
    if ([propertyName isEqualToString:@"create"]) {
        JSObjectRef fn = JSObjectMakeFunctionWithCallback(context.JSGlobalContextRef, NULL, createDelegateFn);
        return [JSValue valueWithJSValueRef:fn inContext:context];
    }
    
    JSNRContainer *container = object.container;
    NSMutableDictionary *info = container.info;
    
    if (!info || ![[info allKeys] containsObject:propertyName])
        return [JSValue valueWithNullInContext:context];
   
    return [info objectForKey:propertyName];
}

- (BOOL)setPropertyWithName:(NSString *)propertyName onObject:(JSValue *)object value:(JSValue *)value inContext:(JSContext *)context
{
    
    JSNRContainer *container = object.container;
    NSMutableDictionary *info = container.info;
    if (!info)
        info = [NSMutableDictionary dictionary];
    
    [info setObject:value forKey:propertyName];
    
    container.info = info;
    
    return NO;
}

- (void)initializeWithObject:(JSValue *)object inContext:(JSContext *)context {
    JSNRContainer *container = [JSNRContainer containerForClass:[JSNRDelegateClass sharedReference] info:nil];
    
    object.container = [container retain];
}

- (void)finalizeWithObject:(JSValue *)object {
    JSNRContainer *container = [object container];
    if (container) {
        [container release];
    }
}

@end
