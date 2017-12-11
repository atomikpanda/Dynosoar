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
#import "JSNRString.h"
#import "JSNRSigType.hpp"

@interface JSNRDelegateForwarder : NSProxy {
    JSValue *_object;
    NSString *_protocolName;
}
- (id)initWithJSValue:(JSValue *)object protocol:(NSString *)protocolName;
@end

@implementation JSNRDelegateForwarder
//@synthesize object;//objectRef, ctx;

- (id)initWithJSValue:(JSValue *)object protocol:(NSString *)protocolName {
    
    if (self) {
        self->_object = [object retain];
        self->_protocolName = [protocolName copy];
        NSLog(@"OBJE: %@", self->_object.toString);
        //        JSValueProtect(ctx, object);
        //        self.objectRef = object;
        //        self.ctx = ctx;
    }
    
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return YES;
}

//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    return nil;
//}

- (NSDictionary *)requiredInstanceMethods {
    unsigned int count = 0;
    struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(NSProtocolFromString(_protocolName), NO, YES, &count);
    
    NSMutableDictionary *protoMethods = [NSMutableDictionary dictionary];
    
    if (methodDescriptions != NULL) {
        for (int i=0; i < count; i++) {
            struct objc_method_description methodDescription = methodDescriptions[i];
            SEL selector = methodDescription.name;
            NSString *typeEncoding = [NSString stringWithUTF8String:methodDescription.types];
            [protoMethods setObject:typeEncoding forKey:NSStringFromSelector(selector)];
        }
        
        free(methodDescriptions);
    }
    
    return protoMethods;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    if (aProtocol == NSProtocolFromString(_protocolName))
        return YES;
    else
        return [super conformsToProtocol:aProtocol];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSDictionary *methods = [self requiredInstanceMethods];
    if ([[methods allKeys] containsObject:NSStringFromSelector(aSelector)]) {
        NSString *typeEncoding = [methods objectForKey:NSStringFromSelector(aSelector)];
        
        return [NSMethodSignature signatureWithObjCTypes:typeEncoding.UTF8String];
    }
    else
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
}

//+ (BOOL)instancesRespondToSelector:(SEL)aSelector {
//    return YES;
//}
//
//- (BOOL)respondsToSelector:(SEL)aSelector {
//    return YES;
//}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    SEL cmd = anInvocation.selector;
    
    
    
    
    NSString *stringSelector = NSStringFromSelector(cmd);
    stringSelector = [stringSelector stringByReplacingOccurrencesOfString:@":" withString:@"$"];
    
    JSObjectRef objectRef = (JSObjectRef)self->_object.JSValueRef;
    JSContextRef ctx = self->_object.context.JSGlobalContextRef;
    if (objectRef == NULL || ctx == NULL) return;
    JSNR::Value obj = JSNR::Value(ctx, objectRef);
    
    BOOL hasProp = [self->_object hasProperty:stringSelector];
    
    
    //    if (self->_object.isObject) return;
    
    
    if (!hasProp) return;
    
    JSValueRef function = [self->_object valueForProperty:stringSelector].JSValueRef;
    
    JSValue *fn = [JSValue valueWithJSValueRef:function inContext:self->_object.context];
    
    if (JSValueIsObject(ctx, function) && JSObjectIsFunction(ctx, (JSObjectRef)function)) {
        NSMethodSignature *signature = anInvocation.methodSignature;
        
        
//        JSValueRef *args = (JSValueRef *)malloc(sizeof(JSValueRef)*signature.numberOfArguments);
        NSMutableArray *argsArr = [NSMutableArray array];
        
        for (int i=0; i < signature.numberOfArguments; i++) {
            JSNR::SigType sigInfo = JSNR::SigType(std::string([signature getArgumentTypeAtIndex:i]));
            void *originalArgument = NULL;
            [anInvocation getArgument:&originalArgument atIndex:i];
            
            if (i==1 && originalArgument == NULL) originalArgument = cmd;
            
            if (originalArgument == NULL) {
                originalArgument = malloc(sigInfo.sizeOfType());
                [anInvocation getArgument:&originalArgument atIndex:i];
            }
            
            JSNR::Value val = JSNR::Value(ctx, sigInfo, originalArgument);
            
            [argsArr addObject:[JSValue valueWithJSValueRef:val.valueRef inContext:[JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)]]];
            
            //            memcpy(args, &val.valueRef, sizeof(JSValueRef));
        }
        
        [fn callWithArguments:argsArr];
        //        JSObjectCallAsFunction(ctx, (JSObjectRef)function, objectRef, signature.numberOfArguments, args, NULL);
        //        free(args);
    }
}

- (void)finalize {
    if (_object) [_object release];
    if (_protocolName) [_protocolName release];
    //    JSValueUnprotect(ctx, objectRef);
    //    self.objectRef = nil;
    //    self.ctx = nil;
    
    //    [super dealloc];
}

@end

JSValueRef createDelegateFn(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef *exception)
{
    JSContext *context = [JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)];
    JSValue *function = [JSValue valueWithJSValueRef:functionRef inContext:context];
    JSValue *thisObject = [JSValue valueWithJSValueRef:thisObjectRef inContext:context];
    
    JSNRContainer *container = thisObject.container;
    
    NSString *protocolName = nil;
    
    if ([thisObject hasProperty:@"__protocolName__"]) {
        JSValue *arg0;
        arg0 = [thisObject valueForProperty:@"__protocolName__"];
        protocolName = arg0.toString;
        
    }
    
    id delegate = [[JSNRDelegateForwarder alloc] initWithJSValue:thisObject protocol:protocolName?protocolName:nil];

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
    JSNRContainer *container = constructor.container;
    NSMutableDictionary *info = container.info;
    if (!info)
        info = [NSMutableDictionary dictionary];
    
    if (argumentCount > 0) {
        JSValueRef arg0 = argumentRefs[0];
        [info setObject:[JSValue valueWithJSValueRef:arg0 inContext:context] forKey:@"__protocolName__"];
    }
    
    container.info = info;
    
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
