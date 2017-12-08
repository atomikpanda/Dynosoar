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

@implementation JSNRInstanceClass

+ (NSString *)JSClassName {
    return @"Instance";
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
    
    JSNRContainer *container = (id)[object privateData];
    JSNR::InvokeInfo *invokeInfo = static_cast<JSNR::InvokeInfo *>(container.data);
    invokeInfo->selector = selectorStr;
    //        InvokeInfo *methodCallInfo = new InvokeInfo(invokeInfo->target, selector.string());
    
    //    free(wrap);
    
    //        JSObjectSetPrivate(invokeFn, methodCallInfo); // appears not nessicary
    container.data = invokeInfo;
    
    return [JSValue valueWithJSValueRef:invokeFn inContext:context];
}

- (BOOL)setPropertyWithName:(NSString *)propertyName onObject:(JSValue *)object value:(JSValue *)value inContext:(JSContext *)context
{
    std::string selectorStr = JSNR::Invoke::parseSetSelector(propertyName.UTF8String);
    printf("should invoke from set %s",  selectorStr.c_str());
    
    JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback((JSContextRef)context.JSGlobalContextRef, NULL, JSNR::Invoke::invokeFunction);
    JSNRContainer *container = (id)[object privateData];
    
    JSNR::InvokeInfo *info = static_cast<JSNR::InvokeInfo *>(container.data);
    info->selector = selectorStr;
    
    //        JSObjectSetPrivate(invokeFn, methodCallInfo); // appears not nessicary
    container.data = info;
    JSValueRef setArguments[1]; // the set of args to be passed to the set method
    setArguments[0] = value.JSValueRef;
    JSObjectCallAsFunction((JSContextRef)context.JSGlobalContextRef, invokeFn, (JSObjectRef)object.JSValueRef, 1, setArguments, NULL);
    
    return NO;
}

- (JSValue *)calledAsFunction:(JSValue *)function thisObject:(JSValue *)thisObject argumentCount:(size_t)argumentCount argumentRefs:(const JSValueRef[])argumentRefs
{
    printf("Instance called as function\n");
    JSNRContainer *container = (id)[function privateData];
    
    JSNR::InvokeInfo *allocInfo = static_cast<JSNR::InvokeInfo *>(container.data);
    Class thisClass = allocInfo->target;
    printf("looks like %s\n", class_getName(thisClass));
    
    //    free(wrap);
    id firstObject = [[thisClass alloc] init];
    JSNR::InvokeInfo *invokeInfo = new JSNR::InvokeInfo(firstObject, "");
    
    container.data = invokeInfo;
    
    return function;
}

- (void)finalizeWithObject:(JSValue *)object {
    JSNRContainer *container = (id)[object privateData];
    JSNR::InvokeInfo *info = static_cast<JSNR::InvokeInfo *>(container.data);
    delete info;
}

- (JSObjectRef)createObjectRefWithContext:(JSContextRef)ctx object:(void *)obj {
    JSObjectRef objectRef = [super createObjectRefWithContext:ctx];
    
    JSNRContainer *container = [self _createContainer];
    JSObjectSetPrivate(objectRef, container);
    
    JSNR::InvokeInfo *invokeInfo = new JSNR::InvokeInfo((id)obj, "");
    invokeInfo->targetIsClass = false;
    container.data = invokeInfo;
    
    return objectRef;
}

- (JSValue *)convertObject:(JSValue *)object toType:(JSType)type inContext:(JSContext *)context {
    JSNRContainer *container = (id)[object privateData];
    JSNR::InvokeInfo *info = static_cast<JSNR::InvokeInfo *>(container.data);
    
    id target = info->target;
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
