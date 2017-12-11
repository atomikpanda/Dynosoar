//
//  BaseClass.cpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRDelegateClass_old.h"
#import "JavaScriptNativeRuntime.h"
#import "JSNRInvoke.h"
#import "JSNRSigType.hpp"
#import <map>
#import "JSNRInstanceClass.h"
#import "JSNRInvokeInfo.h"
#import <objc/runtime.h>

@interface JSNRDelegateForwarder : NSProxy {
    JSValue *_object;
}
@end

@implementation JSNRDelegateForwarder
//@synthesize object;//objectRef, ctx;

- (id)initWithJSValue:(JSValue *)object {
    
    if (self) {
        self->_object = [object retain];
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
    struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(NSProtocolFromString(@"UIAlertViewDelegate"), NO, YES, &count);
    
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
    if (aProtocol == NSProtocolFromString(@"UIAlertViewDelegate"))
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
    NSLog(@"HAS %@ == %s", stringSelector, hasProp ?"Y":"N");
    
//    if (self->_object.isObject) return;
    
    
    if (!hasProp) return;
        
    JSValueRef function = [self->_object valueForProperty:stringSelector].JSValueRef;
    
    JSValue *fn = [JSValue valueWithJSValueRef:function inContext:self->_object.context];
    
    if (JSValueIsObject(ctx, function) && JSObjectIsFunction(ctx, (JSObjectRef)function)) {
        NSMethodSignature *signature = anInvocation.methodSignature;
        
        
        JSValueRef *args = (JSValueRef *)malloc(sizeof(JSValueRef)*signature.numberOfArguments);
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
//    JSValueUnprotect(ctx, objectRef);
//    self.objectRef = nil;
//    self.ctx = nil;
    
//    [super dealloc];
}

@end

namespace JSNR {
    
    typedef DelegateClass thisClass;
    
    typedef std::map<std::string, JSValueRef> ObjectMap;
    
    JSClassRef thisClass::classRef() {
        static JSClassRef ref;
        
        if (!ref) {
            JSClassDefinition classDef = kJSClassDefinitionEmpty;
            
            classDef.className = "DelegateClass";
            classDef.attributes = kJSClassAttributeNone;
            classDef.parentClass = BaseClass::classRef();
            
            classDef.getProperty = thisClass::getCallback;
            classDef.setProperty = thisClass::setCallback;
            classDef.callAsConstructor = thisClass::asConstructor;
            classDef.finalize = thisClass::finalize;
            
           ref = JSClassCreate(&classDef);
        }
        
        return ref;
    }
    
    void thisClass::finalize(JSObjectRef objectRef)
    { JSNRFinalizeCallbackCast
//        ObjectMap *objMap = (ObjectMap *)JSObjectGetPrivate(objectRef);
//        if (objMap == NULL || objMap == nullptr) return;
        
//        delete objMap;
    }
    
    JSValueRef thisClass::convertToType(JSContextRef ctx, JSObjectRef objectRef, JSType type, JSValueRef *exceptionRef)
    { JSNRConvertToTypeCallbackCast
        return String("unknown").value(ctx).valueRef;
    }
    
    JSObjectRef thisClass::asConstructor(JSContextRef ctx, JSObjectRef constructorRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exception)
    { JSNRConstructorCallbackCast
        ObjectMap *objMap = new ObjectMap;
        JSObjectSetPrivate(constructorRef, objMap);
        
        return constructorRef;
    }
    
    JSValueRef thisClass::asFunction(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exceptionRef)
    { JSNRFunctionCallbackCast
        
        
        return thisObjectRef;
    }
    
    JSValueRef thisClass::getCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef *exceptionRef)
    { JSNRGetCallbackCast
        
        if (propertyName.string() == "create") {
            
            JSValueProtect(ctx, objectRef);
            JSObjectRef fn =JSObjectMakeFunctionWithCallback(ctx, NULL, thisClass::createDelegateFn);
            JSObjectSetPrivate(fn, JSObjectGetPrivate(objectRef));
            return fn;
        }
        
        ObjectMap *objMap = (ObjectMap *)JSObjectGetPrivate(objectRef);
        try {
            return objMap->at(propertyName.string());
        } catch (std::exception e) {
            printf("std::exception::::: %s\n",e.what());
            return JSValueMakeNull(ctx);
        }
        
        return JSValueMakeNull(ctx);
        return propertyName.value(ctx).valueRef;
    }
    
    JSValueRef thisClass::createDelegateFn(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exceptionRef)
    { JSNRFunctionCallbackCast
        
//        JSValueIsObject(ctx, thisObjectRef);
        
        JSValue *thisObjectWrapped = [JSValue valueWithJSValueRef:thisObjectRef inContext:[JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)]];
        
        JSNRDelegateForwarder *delegate = [[JSNRDelegateForwarder alloc] initWithJSValue:thisObjectWrapped];
        
        BOOL hasProp = [thisObjectWrapped hasProperty:@"alertView$didDismissWithButtonIndex$"];
        NSLog(@"HHAS %@ == %s", @"alertView$didDismissWithButtonIndex$", hasProp ?"Y":"N");
        #warning --need to change Delegate hasPropertyCallback on a JSNRSuperclass
        
//        JSObjectRef delobj = [[JSNRInstanceClass sharedReference] createObjectRefWithContext:ctx info:(JSNRInvokeInfo *)delegate];
        JSObjectRef delobj = [JSNRSuperClass createEmptyObjectRefWithContext:ctx classRef:[JSNRInstanceClass sharedReference]];
        #warning bad code below
        
        JSNRContainer *container = (id)JSObjectGetPrivate(delobj);
        
        JSNRInvokeInfo *info = [JSNRInvokeInfo infoWithTarget:delegate selector:nil isClass:NO];
        container.info = info;
        
        
        return delobj;//JSNR::Instance::instanceWithObject(ctx, delegate);
    }

    bool thisClass::setCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef valueRef, JSValueRef *exceptionRef)
    { JSNRSetCallbackCast
        
        ObjectMap *objMap = (ObjectMap *)JSObjectGetPrivate(objectRef);
        
//        JSValueProtect(ctx, valueRef);
        if (objMap->find(propertyName.string()) == objMap->end()) {
            objMap->insert(std::make_pair(propertyName.string(), valueRef));
        } else {
            objMap->at(propertyName.string()) = valueRef;
        }
        
        return false;
    }
    
}

