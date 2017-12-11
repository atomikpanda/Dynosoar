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

