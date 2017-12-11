//
//  JSNRInstanceClass.m
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/7/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRObjCClassClass.h"
#import "JSNRInvoke.h"
#import <objc/runtime.h>
#import "JSNRValue.h"
#import "JSNRInstanceClass.h"
#import "JSNRInvokeInfo.h"

@implementation JSNRObjCClassClass

+ (NSString *)JSClassName {
    return @"ObjCClass";
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
    
    JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback((JSContextRef)context.JSGlobalContextRef, NULL, JSNR::Invoke::invokeFunction);
    
    JSNRContainer *container = object.container;
    JSNRInvokeInfo *invokeInfo = container.info;
    invokeInfo.selectorString = propertyName;
    printf("should invoke %s\n", invokeInfo.selectorString.UTF8String);
    
    invokeInfo.targetIsClass = YES;
    //        InvokeInfo *methodCallInfo = new InvokeInfo(invokeInfo->target, selector.string());
    
    //    free(wrap);
    
    //        JSObjectSetPrivate(invokeFn, methodCallInfo); // appears not nessicary
    container.info = invokeInfo;
    
    return [JSValue valueWithJSValueRef:invokeFn inContext:context];
}

- (BOOL)setPropertyWithName:(NSString *)propertyName onObject:(JSValue *)object value:(JSValue *)value inContext:(JSContext *)context
{
    
    JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback((JSContextRef)context.JSGlobalContextRef, NULL, JSNR::Invoke::invokeFunction);
    JSNRContainer *container = object.container;
    
    JSNRInvokeInfo *info = container.info;
    info.selectorString = propertyName;
    [info parseSelectorAsSetSelector];
    printf("should invoke from set %s",  info.selectorString.UTF8String);
    
    info.targetIsClass = YES;
    
    //        JSObjectSetPrivate(invokeFn, methodCallInfo); // appears not nessicary
    container.info = info;
    
    JSValueRef setArguments[1]; // the set of args to be passed to the set method
    setArguments[0] = value.JSValueRef;
    JSObjectCallAsFunction((JSContextRef)context.JSGlobalContextRef, invokeFn, (JSObjectRef)object.JSValueRef, 1, setArguments, NULL);
    
    return NO;
}

- (JSValue *)calledAsFunction:(JSValue *)function thisObject:(JSValue *)thisObject argumentCount:(size_t)argumentCount argumentRefs:(const JSValueRef[])argumentRefs inContext:(JSContext *)context
{
    printf("Class called as function\n");
    JSNRContainer *container = function.container;
    
    JSNRInvokeInfo *allocInfo = container.info;
    Class thisClass = allocInfo.target;
    printf("looks like %s\n", class_getName(thisClass));
    
    //    free(wrap);
    id firstObject = [[thisClass alloc] init];
    JSNRInvokeInfo *invokeInfo = [JSNRInvokeInfo info];
    invokeInfo.target = firstObject;
    
//    JSObjectRef instanceObjectRef = [[JSNRInstanceClass sharedReference] createObjectRefWithContext:ctx info:invokeInfo];
    JSValue *instanceObject = [JSNRSuperClass createEmptyObjectWithContext:context classRef:[JSNRInstanceClass sharedReference]];
//    container.data = invokeInfo;
    instanceObject.container.info = invokeInfo;
    
    return instanceObject;
    
    return function;
}

- (JSValue *)calledAsConstructor:(JSValue *)constructor argumentCount:(size_t)argumentCount argumentRefs:(const JSValueRef[])argumentRefs inContext:(JSContext *)context
{
    
    JSValueRef classNameValueRef = argumentRefs[0];
    
    NSString *className = [[JSValue valueWithJSValueRef:classNameValueRef inContext:context] toString];
    printf("returning class: %s\n", className.UTF8String);
    
    Class cls = objc_getClass(className.UTF8String);
    
    JSNRInvokeInfo *allocInfo = [JSNRInvokeInfo infoWithTarget:cls selector:nil isClass:YES];
    
    constructor.container.info = allocInfo;
    
    return constructor;
}

- (void)initializeWithObject:(JSValue *)object inContext:(JSContext *)context {
    JSNRContainer *container = [JSNRContainer containerForClass:[JSNRObjCClassClass sharedReference] info:nil];
    
    object.container = [container retain];
}

- (void)finalizeWithObject:(JSValue *)object {
    JSNRContainer *container = [object container];
    if (container) {
        [container release];
    }
}

- (JSValue *)convertObject:(JSValue *)object toType:(JSType)type inContext:(JSContext *)context {
    JSNRContainer *container = object.container;
    JSNRInvokeInfo *info = container.info;
    
    id target = info.target;
    
    
    return [@(class_getName(target)) valueInContext:context];

}

@end
