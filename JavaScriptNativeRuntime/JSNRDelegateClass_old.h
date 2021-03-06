//
//  JSNRSuperClass.hpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#ifndef JSNRDelegateClass_hpp
#define JSNRDelegateClass_hpp

#import "JSNRInternal.h"
#include <string>
#import "JSNRCCallback.h"

namespace JSNR {
    class String; class Value;
    
    class DelegateClass {
    public:
        static JSClassRef classRef();
        
        static void finalize(JSObjectRef objectRef);
        static JSObjectRef asConstructor(JSContextRef ctx, JSObjectRef constructorRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exception);
        static JSValueRef asFunction(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exceptionRef);
        static JSValueRef convertToType(JSContextRef ctx, JSObjectRef objectRef, JSType type, JSValueRef *exceptionRef);
        static JSValueRef getCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef *exceptionRef);
        static bool setCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef valueRef, JSValueRef *exceptionRef);
        
        static JSValueRef createDelegateFn(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exceptionRef);
        
    };
    
}

#endif /* JSNRDelegateClass_hpp */
