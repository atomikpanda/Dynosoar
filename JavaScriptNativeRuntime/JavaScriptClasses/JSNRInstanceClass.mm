//
//  JSNRInstanceClass.m
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/7/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRInstanceClass.h"
#import "JSNRInvoke.h"
#import <objc/runtime.h>
#import "JSNRValue.h"
#import "JSNRInvokeInfo.h"

@implementation JSNRInstanceClass

+ (NSString *)JSClassName {
    return @"Instance";
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
    
    std::string selectorStr = JSNR::Invoke::parseGetSelector(propertyName.UTF8String);
    
    printf("should invoke %s\n", selectorStr.c_str());
    
    JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback((JSContextRef)context.JSGlobalContextRef, NULL, JSNR::Invoke::invokeFunction);
    
    JSNRContainer *container = object.container;
    JSNRInvokeInfo *invokeInfo = container.info;
    invokeInfo.selectorString = @(selectorStr.c_str());
    //        InvokeInfo *methodCallInfo = new InvokeInfo(invokeInfo->target, selector.string());
    
    //    free(wrap);
    
    //        JSObjectSetPrivate(invokeFn, methodCallInfo); // appears not nessicary
    container.info = invokeInfo;
    
    
    return [JSValue valueWithJSValueRef:invokeFn inContext:context];
}

- (BOOL)setPropertyWithName:(NSString *)propertyName onObject:(JSValue *)object value:(JSValue *)value inContext:(JSContext *)context
{
    std::string selectorStr = JSNR::Invoke::parseSetSelector(propertyName.UTF8String);
    printf("should invoke from set %s",  selectorStr.c_str());
    
    JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback((JSContextRef)context.JSGlobalContextRef, NULL, JSNR::Invoke::invokeFunction);
    JSNRContainer *container = object.container;
    
    JSNRInvokeInfo *info = container.info;
    info.selectorString = @(selectorStr.c_str());
    
    //        JSObjectSetPrivate(invokeFn, methodCallInfo); // appears not nessicary
    container.info = info;
    JSValueRef setArguments[1]; // the set of args to be passed to the set method
    setArguments[0] = value.JSValueRef;
    JSObjectCallAsFunction((JSContextRef)context.JSGlobalContextRef, invokeFn, (JSObjectRef)object.JSValueRef, 1, setArguments, NULL);
    
    return NO;
}

- (JSValue *)calledAsFunction:(JSValue *)function thisObject:(JSValue *)thisObject argumentCount:(size_t)argumentCount argumentRefs:(const JSValueRef[])argumentRefs
{
    printf("Instance called as function\n");
    JSNRContainer *container = function.container;
    
    JSNRInvokeInfo *allocInfo = container.info;
    
    Class thisClass = allocInfo.target;
    printf("looks like %s\n", class_getName(thisClass));
    
    //    free(wrap);
    id firstObject = [[thisClass alloc] init];
    allocInfo.target = firstObject;
    allocInfo.targetIsClass = NO;
    allocInfo.selectorString = nil;
    
    return function;
}

- (void)initializeWithObject:(JSValue *)object inContext:(JSContext *)context {
    
    if (!object.container) {
        JSNRContainer *container = [JSNRContainer containerForClass:[JSNRInstanceClass sharedReference] info:nil];
        object.container = container;
    }
    
    [object.container retain];
}

- (void)finalizeWithObject:(JSValue *)object {
    JSNRContainer *container = [object container];
    if (container) {
        [container release];
    }
}

- (JSValue *)convertObject:(JSValue *)object toType:(JSType)type inContext:(JSContext *)context {
    JSNRContainer *container = (id)[object privateData];
    JSNRInvokeInfo *info = (id)container.info;
    
    id target = info.target;
    BOOL targetIsClass = class_isMetaClass(object_getClass(target));
    
    if (targetIsClass) {
        return [@(class_getName(target)) valueInContext:context];
    } else {
        // need to store void *target not id target and access return
        //            return JSValueMakeNumber(ctx, 100);
        return [[target description] valueInContext:context];
        
    }
    
    return [@"unknown" valueInContext:context];
}

@end
