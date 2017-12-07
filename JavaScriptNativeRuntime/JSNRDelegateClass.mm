//
//  BaseClass.cpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRDelegateClass.h"
#import "JavaScriptNativeRuntime.h"
#import "JSNRInvoke.h"
#import "JSNRSigType.hpp"
#import <map>

@interface JSNRDelegateForwarder : NSObject <UIAlertViewDelegate>
@property (nonatomic, retain) JSValue *object;
//@property (nonatomic, assign) JSContextRef ctx;
@end

@implementation JSNRDelegateForwarder
@synthesize object;//objectRef, ctx;

- (id)initWithJSValue:(JSValue *)object {
    self = [super init];
    
    if (self) {
        self.object = object;
//        JSValueProtect(ctx, object);
//        self.objectRef = object;
//        self.ctx = ctx;
    }
    
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
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
    
    JSObjectRef objectRef = (JSObjectRef)object.JSValueRef;
    JSContextRef ctx = object.context.JSGlobalContextRef;
    if (objectRef == NULL || ctx == NULL) return;
    JSNR::Value obj = JSNR::Value(ctx, objectRef);
    
    
    if (!obj.isObject()) return;
    
    if (!JSObjectHasProperty(ctx, objectRef, JSNR::String(stringSelector).JSStringRef())) return;
        
    JSValueRef function = JSObjectGetProperty(ctx, objectRef, JSNR::String(stringSelector).JSStringRef(), NULL);

    
    if (JSValueIsObject(ctx, function) && JSObjectIsFunction(ctx, (JSObjectRef)function)) {
        NSMethodSignature *signature = anInvocation.methodSignature;
        
        
        JSValueRef *args = (JSValueRef *)malloc(sizeof(JSValueRef)*signature.numberOfArguments);
        
        for (int i=0; i < signature.numberOfArguments; i++) {
            JSNR::SigType sigInfo = JSNR::SigType(std::string([signature getArgumentTypeAtIndex:i]));
            void *originalArgument = NULL;
            [anInvocation getArgument:&originalArgument atIndex:i];
            
            
            JSNR::Value val = JSNR::Value(ctx, sigInfo, originalArgument);
            memcpy(args, &val.valueRef, sizeof(JSValueRef));
        }
        
        JSObjectCallAsFunction(ctx, (JSObjectRef)function, objectRef, signature.numberOfArguments, args, NULL);
//        free(args);
    }
}

- (void)dealloc {
    self.object = nil;
//    JSValueUnprotect(ctx, objectRef);
//    self.objectRef = nil;
//    self.ctx = nil;
    
    [super dealloc];
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
            
            return fn;
        }
        
        ObjectMap *objMap = (ObjectMap *)JSObjectGetPrivate(objectRef);
        try {
            return objMap->at(propertyName.string());
        } catch (std::exception e) {
            return JSValueMakeNull(ctx);
        }
        
        return JSValueMakeNull(ctx);
        return propertyName.value(ctx).valueRef;
    }
    
    JSValueRef thisClass::createDelegateFn(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exceptionRef)
    { JSNRFunctionCallbackCast
        
//        JSValueIsObject(ctx, thisObjectRef);
        
        JSValue *thisObjectWrapped = [JSValue valueWithJSValueRef:thisObjectRef inContext:[JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)]];
        JSNRDelegateForwarder *delegate = [[[JSNRDelegateForwarder alloc] initWithJSValue:thisObjectWrapped] autorelease];
        
        return JSNR::Instance::instanceWithObject(ctx, delegate);
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

