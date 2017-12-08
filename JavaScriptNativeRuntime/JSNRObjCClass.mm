//
//  JSNRExampleSubclass.cpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRObjCClass.h"
#import "JSNRInternal.h"
#import "JavaScriptNativeRuntime.h"
#import <iostream>
#import <objc/runtime.h>
#import "JSNRInvoke.h"
#import "JSNRInstanceClass.h"

using std::cout; using std::endl;

namespace JSNR {
    typedef ObjCClass thisClass;
    
    JSValueRef thisClass::getCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef *exceptionRef)
    { JSNRGetCallbackCast
        if (propertyName.string() == "Symbol.toPrimitive") {
            return String("string").value(ctx).valueRef;
        }
        if (propertyName.string() == "toString") {
            return propertyName.value(ctx).valueRef;
        }
        if (propertyName.string() == "valueOf") {
            return propertyName.value(ctx).valueRef;
        }
        if (propertyName.string() == "toCString") {
            return propertyName.value(ctx).valueRef;
        }
        
        std::string selectorStr = Invoke::parseGetSelector(propertyName.string());
        cout << "should invoke "<< selectorStr <<endl;
        
        JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback(ctx, NULL, Invoke::invokeFunction);
        
        InvokeInfo *invokeInfo = static_cast<InvokeInfo *>(object.getPrivate());
        invokeInfo->selector = selectorStr;
        invokeInfo->targetIsClass = true;

        object.setPrivate(invokeInfo);
        
        return invokeFn;
    }
    
    bool thisClass::setCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef valueRef, JSValueRef *exceptionRef)
    { JSNRSetCallbackCast
        
        std::string selectorStr = Invoke::parseSetSelector(propertyName.string());
        cout << "should invoke from set "+selectorStr<<endl;
        
        JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback(ctx, NULL, Invoke::invokeFunction);
        
        InvokeInfo *info = static_cast<InvokeInfo *>(object.getPrivate());

        info->selector = selectorStr;
        info->targetIsClass = true;

//        JSObjectSetPrivate(invokeFn, methodCallInfo); // appears not nessicary
        object.setPrivate(info);
        JSValueRef setArguments[1]; // the set of args to be passed to the set method
        setArguments[0] = value.valueRef;
        JSObjectCallAsFunction(ctx, invokeFn, object.objectRef, 1, setArguments, NULL);
        
        return false;
    }
    
    JSValueRef thisClass::asFunction(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exceptionRef)
    { JSNRFunctionCallbackCast
        cout << "ObjCClass called as function" << endl;
        
        JSNRContainer *container = (id)function.getPrivate();
        InvokeInfo *allocInfo = static_cast<InvokeInfo *>(container.data);
        Class thisClass = allocInfo->target;
        cout << "looks like: " << class_getName(thisClass) << endl;
        
        id firstObject = [[thisClass alloc] init];
        InvokeInfo *invokeInfo = new InvokeInfo(firstObject, "");
        
//        function.setPrivate(invokeInfo);
        
        
        JSNRInstanceClass *instance = [[JSNRInstanceClass alloc] init];
        JSNRContainer *container = [[JSNRContainer alloc] initWithJSNRClass:instance data:invokeInfo];
        JSObjectRef instanceObject = [instance createObjectRefWithContext:ctx object:container];
        JSValue *val = [JSValue valueWithJSValueRef:instanceObject inContext:[JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)]];
        val.privateData = invokeInfo;
        
        return val.JSValueRef;
    }
    
    JSObjectRef thisClass::asConstructor(JSContextRef ctx, JSObjectRef constructorRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exception)
    { JSNRConstructorCallbackCast
        
        String className = String(Value(ctx, argumentRefs[0]));
        cout << "returning class: " <<  className.string() << endl;
        
        Class cls = objc_getClass(className.c_str());
        InvokeInfo *allocInfo = new InvokeInfo(cls, "", true);
        
        constructor.setPrivate(allocInfo);
        
        return constructor.objectRef;
    }
    
    void thisClass::finalize(JSObjectRef objectRef)
    { JSNRFinalizeCallbackCast
        InvokeInfo *info = static_cast<InvokeInfo *>(object.getPrivate());
        delete info;
    }
    
    JSValueRef thisClass::convertToType(JSContextRef ctx, JSObjectRef objectRef, JSType type, JSValueRef *exceptionRef)
    { JSNRConvertToTypeCallbackCast
        
        // Since we are in ObjCClass target is always class
        InvokeInfo *info = static_cast<InvokeInfo *>(object.getPrivate());
        
        id target = info->target;
//        BOOL targetIsClass = class_isMetaClass(object_getClass(target));
        
//        if (targetIsClass) {
        
            return String(class_getName(target)).value(ctx).valueRef;
//        } else {
            // need to store void *target not id target and access return
//            return JSValueMakeNumber(ctx, 100);
//            return String([target description]).value(ctx).valueRef;
        
//        }
        
//        return String("unknown").value(ctx).valueRef;
    }
//    static bool setCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef valueRef, JSValueRef *exceptionRef);
    
    JSClassRef ObjCClass::classRef() {
        static JSClassRef ref;
        
        if (!ref) {
            JSClassDefinition classDef = kJSClassDefinitionEmpty;
            
            classDef.className = "ObjCClass";
            classDef.attributes = kJSClassAttributeNone;
            classDef.parentClass = BaseClass::classRef();
            
            classDef.getProperty = thisClass::getCallback;
            classDef.setProperty = thisClass::setCallback;
            classDef.convertToType = thisClass::convertToType;
            classDef.callAsFunction = thisClass::asFunction;
            classDef.callAsConstructor = thisClass::asConstructor;
            classDef.finalize = thisClass::finalize;
            
            ref = JSClassCreate(&classDef);
        }
        
        return ref;
    }
    
    JSObjectRef thisClass::instanceWithObjCClass(JSContextRef ctx, Class objCClass) {
        
        JSClassRef cls = JSNR::ObjCClass::classRef();
        JSNR::Value selfObj = JSNR::Value(ctx, JSObjectMake(ctx, cls, NULL));
        JSNR::InvokeInfo *invokeInfo = new JSNR::InvokeInfo(objCClass, "");
        invokeInfo->targetIsClass = true;
        selfObj.setPrivate(invokeInfo);
        return selfObj.objectRef;
    }
    
}
